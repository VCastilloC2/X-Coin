import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_api_service.dart' show ApiException;
import '../datasources/supplemental_rates_service.dart';

/// Decorador de [CurrencyRepository] que añade las monedas que
/// Frankfurter no publica (hoy: COP) sin tocar `CurrencyRepositoryImpl`.
///
/// Todo lo que no involucra una moneda suplementaria se delega tal cual.
/// Para lo que sí, la tasa se calcula por **cruce vía USD**:
///
/// ```
/// 1 base = (USD→quote) / (USD→base) quote
/// ```
///
/// donde `USD→COP` viene de [SupplementalRatesService] y `USD→X`
/// (X ≠ COP) de Frankfurter. La capa de presentación no se entera: sigue
/// dependiendo solo de la interfaz [CurrencyRepository].
class SupplementedCurrencyRepository implements CurrencyRepository {
  SupplementedCurrencyRepository({
    required CurrencyRepository delegate,
    SupplementalRatesService? supplemental,
  })  : _delegate = delegate,
        _supplemental = supplemental ?? SupplementalRatesService();

  final CurrencyRepository _delegate;
  final SupplementalRatesService _supplemental;

  /// Máximo de puntos del histórico de pares con COP. El dataset
  /// suplementario es un snapshot por día, así que en rangos largos
  /// (1Y, 2Y) se muestrea en vez de pedir cientos de archivos.
  static const int _maxHistoryPoints = 16;

  /// Entradas de catálogo para las monedas suplementarias. Los nombres
  /// siguen el idioma de `/v1/currencies` (inglés) para que el buscador
  /// de "Moneda Base" se comporte igual con todas.
  static final List<Currency> _extraCurrencies = [
    Currency(
      isoCode: 'COP',
      name: 'Colombian Peso',
      symbol: CurrencyFormatter.symbolFor('COP'),
      flagEmoji: '🇨🇴',
    ),
  ];

  bool _isSupplemental(String iso) =>
      SupplementalRatesService.supportedCodes.contains(iso);

  bool _involvesSupplemental(String a, String b) =>
      _isSupplemental(a) || _isSupplemental(b);

  // ---------------------------------------------------------------------------
  // Catálogo
  // ---------------------------------------------------------------------------

  @override
  Future<List<Currency>> getAvailableCurrencies() async {
    final fromApi = await _delegate.getAvailableCurrencies();
    final known = fromApi.map((c) => c.isoCode).toSet();
    final merged = <Currency>[
      ...fromApi,
      ..._extraCurrencies.where((c) => !known.contains(c.isoCode)),
    ]..sort((a, b) => a.isoCode.compareTo(b.isoCode));
    return List.unmodifiable(merged);
  }

  // ---------------------------------------------------------------------------
  // Tasa actual
  // ---------------------------------------------------------------------------

  @override
  Future<ExchangeRate> getLatestRate({
    required String base,
    required String quote,
  }) async {
    if (!_involvesSupplemental(base, quote)) {
      return _delegate.getLatestRate(base: base, quote: quote);
    }
    if (base == quote) {
      return ExchangeRate(
        baseCurrency: base,
        quoteCurrency: quote,
        rateValue: 1,
        date: DateTime.now(),
      );
    }
    final (usdToBase, usdToQuote) =
        await (_usdTo(base), _usdTo(quote)).wait;
    return ExchangeRate(
      baseCurrency: base,
      quoteCurrency: quote,
      rateValue: usdToQuote / usdToBase,
      date: DateTime.now(),
    );
  }

  /// Cuántas unidades de [iso] equivalen a 1 USD, hoy.
  Future<double> _usdTo(String iso) async {
    if (iso == 'USD') return 1;
    if (_isSupplemental(iso)) return _supplemental.fetchUsdRate(iso);
    final rate = await _delegate.getLatestRate(base: 'USD', quote: iso);
    if (rate.rateValue <= 0) {
      throw ApiException('Tasa inválida para USD/$iso.');
    }
    return rate.rateValue;
  }

  // ---------------------------------------------------------------------------
  // Ranking ("Tasas Globales")
  // ---------------------------------------------------------------------------

  @override
  Future<Map<String, double>> getRanking({required String base}) async {
    final Map<String, double> ranking;

    if (_isSupplemental(base)) {
      // Base = COP: Frankfurter no la conoce, se parte del ranking en USD
      // y se reexpresa: 1 COP = (1 USD → X) / (1 USD → COP) X.
      final (usdToBase, usdRanking) = await (
        _supplemental.fetchUsdRate(base),
        _delegate.getRanking(base: 'USD'),
      ).wait;
      ranking = {
        for (final entry in usdRanking.entries)
          if (entry.key != base) entry.key: entry.value / usdToBase,
        'USD': 1 / usdToBase,
      };
    } else {
      // Base normal: se conserva el ranking de Frankfurter y se le suman
      // las monedas suplementarias: 1 base = (USD→COP) / (USD→base) COP.
      final (delegated, usdToBase) =
          await (_delegate.getRanking(base: base), _usdTo(base)).wait;
      ranking = Map.of(delegated);
      for (final iso in SupplementalRatesService.supportedCodes) {
        if (iso == base) continue;
        ranking[iso] = await _supplemental.fetchUsdRate(iso) / usdToBase;
      }
    }

    // Mismo orden alfabético que devuelve Frankfurter.
    final sorted = ranking.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(sorted);
  }

  // ---------------------------------------------------------------------------
  // Histórico
  // ---------------------------------------------------------------------------

  @override
  Future<List<RatePoint>> getHistoricalRange({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    if (!_involvesSupplemental(base, quote)) {
      return _delegate.getHistoricalRange(
        base: base,
        quote: quote,
        from: from,
        to: to,
      );
    }
    if (base == quote) return const [];

    final supplementalIsBase = _isSupplemental(base);
    final supplementalIso = supplementalIsBase ? base : quote;
    final otherIso = supplementalIsBase ? quote : base;
    final dates = _sampleDates(from, to);

    // Lado suplementario: un snapshot por fecha muestreada (los que
    // fallen se omiten). Lado Frankfurter: una sola petición de rango.
    final (supplementalRates, otherSeries) = await (
      Future.wait(dates.map((d) => _tryUsdRate(supplementalIso, d))),
      otherIso == 'USD'
          ? Future.value(const <RatePoint>[])
          : _delegate.getHistoricalRange(
              base: 'USD',
              quote: otherIso,
              from: from,
              to: to,
            ),
    ).wait;

    final points = <RatePoint>[];
    for (var i = 0; i < dates.length; i++) {
      final usdToSupplemental = supplementalRates[i];
      final usdToOther =
          otherIso == 'USD' ? 1.0 : _valueOnOrBefore(otherSeries, dates[i]);
      if (usdToSupplemental == null || usdToOther == null) continue;
      if (usdToSupplemental <= 0 || usdToOther <= 0) continue;

      final usdToBase = supplementalIsBase ? usdToSupplemental : usdToOther;
      final usdToQuote = supplementalIsBase ? usdToOther : usdToSupplemental;
      points.add(RatePoint(date: dates[i], value: usdToQuote / usdToBase));
    }

    // Con menos de 2 puntos las gráficas muestran su estado vacío
    // ("Sin datos históricos…") en lugar de romper toda la pantalla, que
    // es lo que pasaría si aquí se lanzara una excepción: `RatesProvider`
    // carga tasa actual, histórico y ranking en un único `Future.wait`.
    return points.length < 2 ? const [] : points;
  }

  Future<double?> _tryUsdRate(String iso, DateTime date) async {
    try {
      return await _supplemental.fetchUsdRate(iso, date: date);
    } catch (_) {
      return null;
    }
  }

  /// Fechas equidistantes entre [from] y [to] (ambas incluidas), como
  /// máximo [_maxHistoryPoints]. En rangos cortos es una por día.
  List<DateTime> _sampleDates(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    final totalDays = end.difference(start).inDays;
    if (totalDays <= 0) return [end];

    final count =
        totalDays + 1 <= _maxHistoryPoints ? totalDays + 1 : _maxHistoryPoints;
    return [
      for (var i = 0; i < count; i++)
        // Se suma sobre `day` (no sobre Duration) para no desfasarse por DST.
        DateTime(
          start.year,
          start.month,
          start.day + (totalDays * i / (count - 1)).round(),
        ),
    ];
  }

  /// Último valor de [series] (ordenada por fecha) en o antes de [date].
  /// Frankfurter solo publica días hábiles: para fines de semana se usa el
  /// cierre previo. Si [date] es anterior a todo, se usa el primer punto.
  double? _valueOnOrBefore(List<RatePoint> series, DateTime date) {
    if (series.isEmpty) return null;
    var match = series.first;
    for (final point in series) {
      if (point.date.isAfter(date)) break;
      match = point;
    }
    return match.value;
  }
}
