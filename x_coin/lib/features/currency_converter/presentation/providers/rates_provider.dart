import 'package:flutter/foundation.dart';
import '../../data/datasources/currency_api_service.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../../../core/constants/app_strings.dart';
import 'currency_converter_provider.dart' show ViewStatus;

/// Rango temporal seleccionable en el segmented control de la
/// gráfica ("7 Días", "1W", "1Y", "2Y").
enum RateRange { sevenDays, oneWeek, oneYear, twoYears }

extension RateRangeX on RateRange {
  String get label => switch (this) {
        RateRange.sevenDays => '7 Días',
        RateRange.oneWeek => '1W',
        RateRange.oneYear => '1Y',
        RateRange.twoYears => '2Y',
      };

  Duration get span => switch (this) {
        RateRange.sevenDays => const Duration(days: 7),
        RateRange.oneWeek => const Duration(days: 7),
        RateRange.oneYear => const Duration(days: 365),
        RateRange.twoYears => const Duration(days: 730),
      };
}

/// Controla el estado de la pantalla "Historial": tasa actual entre
/// dos monedas, su evolución histórica (gráfica) y el ranking de
/// "Tasas Globales" frente a una moneda de referencia.
///
/// A diferencia de la versión original, el par (`base`/`quote`) y la
/// moneda de referencia del ranking (`rankingBase`) **no están
/// fijos**: se sincronizan automáticamente vía [syncPair] y
/// [syncRankingBase], invocados desde `main.dart` cada vez que
/// cambian, respectivamente, la selección en Inicio
/// ([CurrencyConverterProvider]) y la "Moneda Base" en Ajustes
/// ([SettingsProvider]). Este provider no importa ninguno de los dos
/// para mantener el desacople; la orquestación vive en la capa de
/// composición.
class RatesProvider extends ChangeNotifier {
  RatesProvider({required CurrencyRepository repository})
      : _repository = repository;

  final CurrencyRepository _repository;

  ViewStatus _status = ViewStatus.initial;
  String? _errorMessage;

  ExchangeRate? _currentRate;
  List<RatePoint> _history = const [];
  Map<String, double> _ranking = const {};
  RateRange _selectedRange = RateRange.sevenDays;

  String _base = 'USD';
  String _quote = 'EUR';
  String _rankingBase = 'USD';

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ExchangeRate? get currentRate => _currentRate;
  List<RatePoint> get history => _history;
  Map<String, double> get ranking => _ranking;
  RateRange get selectedRange => _selectedRange;
  String get base => _base;
  String get quote => _quote;
  String get rankingBase => _rankingBase;

  /// Sincroniza el par consultado para "Tasa Actual" y la gráfica
  /// desde la selección de Inicio. Si el par no cambió, no hace
  /// nada (evita refetch innecesario en cada rebuild).
  void syncPair({required String base, required String quote}) {
    if (base == _base && quote == _quote) return;
    _base = base;
    _quote = quote;
    // Disparo intencional sin esperar: el llamador (ProxyProvider en
    // main.dart) no puede ser async, y `load()` ya notifica a sus
    // propios listeners al terminar.
    // ignore: discarded_futures
    load();
  }

  /// Sincroniza la moneda de referencia de "Tasas Globales" desde la
  /// "Moneda Base" de Ajustes.
  void syncRankingBase(String base) {
    if (base == _rankingBase) return;
    _rankingBase = base;
    // ignore: discarded_futures
    load();
  }

  Future<void> load() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _repository.getLatestRate(base: _base, quote: _quote),
        _repository.getHistoricalRange(
          base: _base,
          quote: _quote,
          from: now.subtract(_selectedRange.span),
          to: now,
        ),
        _repository.getRanking(base: _rankingBase),
      ]);
      _currentRate = results[0] as ExchangeRate;
      _history = results[1] as List<RatePoint>;
      _ranking = results[2] as Map<String, double>;
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ViewStatus.error;
    } catch (_) {
      _errorMessage = AppStrings.errorLoadingRate;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> selectRange(RateRange range) async {
    if (range == _selectedRange) return;
    _selectedRange = range;
    notifyListeners();
    await load();
  }
}
