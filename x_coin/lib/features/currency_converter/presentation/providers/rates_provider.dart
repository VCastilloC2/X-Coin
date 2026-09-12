import 'package:flutter/foundation.dart';
import '../../data/datasources/currency_api_service.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
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

  final String base = 'USD';
  final String quote = 'EUR';

  ViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ExchangeRate? get currentRate => _currentRate;
  List<RatePoint> get history => _history;
  Map<String, double> get ranking => _ranking;
  RateRange get selectedRange => _selectedRange;

  Future<void> load() async {
    _status = ViewStatus.loading;
    notifyListeners();
    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _repository.getLatestRate(base: base, quote: quote),
        _repository.getHistoricalRange(
          base: base,
          quote: quote,
          from: now.subtract(_selectedRange.span),
          to: now,
        ),
        _repository.getRanking(base: base),
      ]);
      _currentRate = results[0] as ExchangeRate;
      _history = results[1] as List<RatePoint>;
      _ranking = results[2] as Map<String, double>;
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ViewStatus.error;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar las tasas globales.';
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
