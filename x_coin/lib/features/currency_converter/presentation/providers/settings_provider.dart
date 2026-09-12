import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/rate_alert.dart';

/// Controla las preferencias de la app mostradas en "Ajustes": modo
/// oscuro, notificaciones, alerta de tasa y moneda base — y las
/// persiste localmente con `shared_preferences` para que sobrevivan
/// a un reinicio de la aplicación.
///
/// Además de ser la fuente de las preferencias, [baseCurrency] actúa
/// como disparador del estado global: cuando cambia, el resto de la
/// app (Inicio y, en cascada, Historial) se sincroniza
/// automáticamente mediante los `ChangeNotifierProxyProvider`
/// declarados en `main.dart`. Esta clase no conoce ni depende de los
/// otros providers — la propagación ocurre en la capa de composición
/// (main.dart), no aquí, para mantener el desacople.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _restore();
  }

  static const _kDarkMode = 'settings.darkMode';
  static const _kNotifications = 'settings.notificationsEnabled';
  static const _kBaseCurrency = 'settings.baseCurrency';
  static const _kRateAlert = 'settings.rateAlert';

  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _baseCurrency = 'USD';
  RateAlert? _rateAlert;
  bool _isReady = false;

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get baseCurrency => _baseCurrency;
  RateAlert? get rateAlert => _rateAlert;

  /// `true` una vez que las preferencias guardadas fueron leídas de
  /// disco. Útil para evitar parpadeos de tema al arrancar la app.
  bool get isReady => _isReady;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool(_kDarkMode) ?? false;
      _notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
      _baseCurrency = prefs.getString(_kBaseCurrency) ?? 'USD';
      final rawAlert = prefs.getString(_kRateAlert);
      if (rawAlert != null) {
        _rateAlert = RateAlert.fromJson(
          jsonDecode(rawAlert) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Primera instalación o almacenamiento corrupto: se conservan
      // los valores por defecto ya inicializados arriba.
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
  }

  /// Cambia la Moneda Base global. Este es el único punto de entrada
  /// para esa preferencia: `main.dart` observa este cambio y
  /// actualiza automáticamente el origen del conversor y, en
  /// cascada, el par consultado en Historial.
  Future<void> setBaseCurrency(String isoCode) async {
    if (isoCode == _baseCurrency) return;
    _baseCurrency = isoCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseCurrency, isoCode);
  }

  Future<void> setRateAlert(RateAlert alert) async {
    _rateAlert = alert;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRateAlert, jsonEncode(alert.toJson()));
  }

  Future<void> clearRateAlert() async {
    _rateAlert = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRateAlert);
  }
}
