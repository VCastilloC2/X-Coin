import 'package:flutter/foundation.dart';
import '../../data/datasources/currency_api_service.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';

/// Estados posibles de una operación asíncrona en la pantalla Home.
enum ViewStatus { initial, loading, success, error }

/// Controla el estado de la pantalla "Inicio" (conversor de monedas):
/// carga del catálogo, selección de moneda origen/destino, entrada
/// numérica desde el teclado y resultado de la conversión.
class CurrencyConverterProvider extends ChangeNotifier {
  CurrencyConverterProvider({required CurrencyRepository repository})
      : _repository = repository;

  final CurrencyRepository _repository;

  ViewStatus _currenciesStatus = ViewStatus.initial;
  ViewStatus _conversionStatus = ViewStatus.initial;
  String? _errorMessage;

  List<Currency> _currencies = const [];
  Currency? _origin;
  Currency? _destination;

  String _rawAmount = '100';
  double? _convertedAmount;

  static const List<String> favoriteCodes = [
    'USD', 'GBP', 'EUR', 'CAD', 'JPY', 'AUD',
  ];

  ViewStatus get currenciesStatus => _currenciesStatus;
  ViewStatus get conversionStatus => _conversionStatus;
  String? get errorMessage => _errorMessage;
  List<Currency> get currencies => _currencies;
  Currency? get origin => _origin;
  Currency? get destination => _destination;
  String get rawAmount => _rawAmount;
  double get amount => double.tryParse(_rawAmount) ?? 0;
  double? get convertedAmount => _convertedAmount;

  List<Currency> get favoriteCurrencies => _currencies
      .where((c) => favoriteCodes.contains(c.isoCode))
      .toList(growable: false);

  /// Carga inicial del catálogo de monedas desde la API.
  Future<void> loadCurrencies() async {
    _currenciesStatus = ViewStatus.loading;
    notifyListeners();
    try {
      _currencies = await _repository.getAvailableCurrencies();
      _origin = _findOrFallback('USD');
      _destination = _findOrFallback('EUR');
      _currenciesStatus = ViewStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _currenciesStatus = ViewStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado cargando las monedas.';
      _currenciesStatus = ViewStatus.error;
    }
    notifyListeners();
  }

  Currency? _findOrFallback(String iso) {
    for (final c in _currencies) {
      if (c.isoCode == iso) return c;
    }
    return _currencies.isNotEmpty ? _currencies.first : null;
  }

  void selectOrigin(Currency currency) {
    _origin = currency;
    _convertedAmount = null;
    notifyListeners();
  }

  void selectDestination(Currency currency) {
    _destination = currency;
    _convertedAmount = null;
    notifyListeners();
  }

  /// Intercambia origen y destino (icono ⇄ del mockup).
  void swapCurrencies() {
    final tmp = _origin;
    _origin = _destination;
    _destination = tmp;
    _convertedAmount = null;
    notifyListeners();
  }

  /// Recibe la pulsación del teclado numérico personalizado.
  void onKeypadInput(String key) {
    switch (key) {
      case 'back':
        if (_rawAmount.isNotEmpty) {
          _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
        }
        break;
      case '.':
        if (!_rawAmount.contains('.')) {
          _rawAmount = _rawAmount.isEmpty ? '0.' : '$_rawAmount.';
        }
        break;
      default:
        if (_rawAmount == '0') {
          _rawAmount = key;
        } else {
          _rawAmount += key;
        }
    }
    if (_rawAmount.isEmpty) _rawAmount = '0';
    _convertedAmount = null;
    notifyListeners();
  }

  bool get canConvert =>
      _origin != null &&
      _destination != null &&
      amount > 0 &&
      _conversionStatus != ViewStatus.loading;

  /// Ejecuta la conversión consultando la tasa actual a la API.
  Future<void> convert() async {
    if (!canConvert) return;
    _conversionStatus = ViewStatus.loading;
    notifyListeners();
    try {
      final rate = await _repository.getLatestRate(
        base: _origin!.isoCode,
        quote: _destination!.isoCode,
      );
      _convertedAmount = amount * rate.rateValue;
      _conversionStatus = ViewStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _conversionStatus = ViewStatus.error;
    } catch (_) {
      _errorMessage = 'No fue posible completar la conversión.';
      _conversionStatus = ViewStatus.error;
    }
    notifyListeners();
  }
}
