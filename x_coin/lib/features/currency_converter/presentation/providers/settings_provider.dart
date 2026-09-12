import 'package:flutter/foundation.dart';

/// Controla las preferencias de la app mostradas en la pantalla
/// "Ajustes": modo oscuro, notificaciones y moneda base.
///
/// Se mantiene deliberadamente simple (sin persistencia) para que sea
/// fácil de conectar más adelante a `shared_preferences` u otro
/// mecanismo de almacenamiento local.
class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _baseCurrency = 'USD';

  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get baseCurrency => _baseCurrency;

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setBaseCurrency(String isoCode) {
    _baseCurrency = isoCode;
    notifyListeners();
  }
}
