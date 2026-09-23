import 'package:flutter/foundation.dart';
import '../../data/datasources/currency_api_service.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';

/// Estados posibles de una operación asíncrona en la pantalla Home.
enum ViewStatus { initial, loading, success, error }

/// Controla el estado de la pantalla "Inicio" (conversor de monedas):
/// carga del catálogo, selección de moneda origen/destino, entrada
/// numérica desde el teclado y resultado de la conversión.
///
/// Es la **única fuente de verdad** del par origen/destino de toda la
/// app: `main.dart` conecta este provider con [RatesProvider] mediante
/// `ChangeNotifierProxyProvider2`, de forma que Historial se
/// re-sincroniza automáticamente cada vez que [origin]/[destination]
/// cambian aquí, sin que esta clase necesite conocer a Historial.
class CurrencyConverterProvider extends ChangeNotifier {
  CurrencyConverterProvider({
    required CurrencyRepository repository,
    String initialOrigin = 'USD',
    String initialDestination = 'EUR',
  })  : _repository = repository,
        _initialOrigin = initialOrigin,
        _initialDestination = initialDestination;

  final CurrencyRepository _repository;
  final String _initialOrigin;
  final String _initialDestination;

  ViewStatus _currenciesStatus = ViewStatus.initial;
  ViewStatus _conversionStatus = ViewStatus.initial;
  String? _errorMessage;

  List<Currency> _currencies = const [];
  Currency? _origin;
  Currency? _destination;

  String _rawAmount = '100';
  double? _convertedAmount;

  static const List<String> favoriteCodes = [
    'USD', 'GBP', 'EUR', 'CAD', 'JPY', 'AUD', 'COP',
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

  /// Carga inicial del catálogo de monedas desde la API. El origen
  /// por defecto respeta la "Moneda Base" configurada en Ajustes
  /// (inyectada como [_initialOrigin] desde `main.dart`).
  Future<void> loadCurrencies() async {
    _currenciesStatus = ViewStatus.loading;
    notifyListeners();
    try {
      _currencies = await _repository.getAvailableCurrencies();
      _origin = _findExact(_initialOrigin) ?? _firstOrNull();
      _destination = _findExact(_initialDestination) ?? _secondOrNull();
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

  Currency? _findExact(String iso) {
    for (final c in _currencies) {
      if (c.isoCode == iso) return c;
    }
    return null;
  }

  Currency? _firstOrNull() => _currencies.isNotEmpty ? _currencies.first : null;

  Currency? _secondOrNull() =>
      _currencies.length > 1 ? _currencies[1] : _firstOrNull();

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

  /// Aplica una moneda de origen por código ISO. Es el punto de
  /// entrada usado por `main.dart` cuando la "Moneda Base" cambia en
  /// Ajustes, para mantener el estado global sincronizado sin
  /// duplicar la lógica de selección manual del usuario.
  ///
  /// No hace nada si el catálogo aún no cargó o si la moneda ya es
  /// la actual, evitando notificaciones y llamadas de red redundantes.
  void setOriginByIso(String isoCode) {
    if (_currencies.isEmpty || _origin?.isoCode == isoCode) return;
    final match = _findExact(isoCode);
    if (match == null) return;
    _origin = match;
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
