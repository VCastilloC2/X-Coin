import '../../domain/entities/currency.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_api_service.dart';

/// Implementación concreta de [CurrencyRepository].
///
/// Aquí viven las "factorías de conversión" mencionadas en el taller:
/// se reciben mapas JSON del [CurrencyApiService] y se transforman en
/// objetos nativos (`Currency`, `ExchangeRate`, `RatePoint`) que el
/// resto de la app consume sin conocer el formato del API.
class CurrencyRepositoryImpl implements CurrencyRepository {
  CurrencyRepositoryImpl({CurrencyApiService? apiService})
      : _api = apiService ?? CurrencyApiService();

  final CurrencyApiService _api;

  static const Map<String, String> _flagByIso = {
    'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧', 'CAD': '🇨🇦',
    'JPY': '🇯🇵', 'AUD': '🇦🇺', 'COP': '🇨🇴', 'CHF': '🇨🇭',
  };

  static const Map<String, String> _symbolByIso = {
    'USD': r'$', 'EUR': '€', 'GBP': '£', 'CAD': r'C$',
    'JPY': '¥', 'AUD': r'A$', 'COP': r'$', 'CHF': 'CHF',
  };

  @override
  Future<List<Currency>> getAvailableCurrencies() async {
    final json = await _api.fetchCurrencies();
    return json.entries
        .map(
          (e) => Currency(
            isoCode: e.key,
            name: e.value as String,
            symbol: _symbolByIso[e.key] ?? e.key,
            flagEmoji: _flagByIso[e.key] ?? '🏳️',
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<ExchangeRate> getLatestRate({
    required String base,
    required String quote,
  }) async {
    final json = await _api.fetchLatestRate(base: base, quote: quote);
    return ExchangeRate.fromJson(json);
  }

  @override
  Future<Map<String, double>> getRanking({required String base}) async {
    final json = await _api.fetchRanking(base: base);
    final rates = json['rates'] as Map<String, dynamic>;
    return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  @override
  Future<List<RatePoint>> getHistoricalRange({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    final json = await _api.fetchHistoricalRange(
      base: base,
      quote: quote,
      from: from,
      to: to,
    );
    final series = json['rates'] as Map<String, dynamic>;
    final points = series.entries
        .map(
          (e) => RatePoint(
            date: DateTime.parse(e.key),
            value: ((e.value as Map<String, dynamic>)[quote] as num)
                .toDouble(),
          ),
        )
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
