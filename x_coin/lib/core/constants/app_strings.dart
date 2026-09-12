/// Textos estáticos de la app, centralizados para facilitar
/// mantenimiento y una futura internacionalización.
class AppStrings {
  AppStrings._();

  static const String appName = 'X-Coin';

  // Pantalla "Inicio" (conversor).
  static const String convertTitle = 'Convertir Monedas Internacionales';
  static const String originCurrency = 'Moneda de Origen';
  static const String destinationCurrency = 'Moneda de Destino';
  static const String amountLabel = 'Moneda de Destino';
  static const String convertButton = 'Convertir';
  static const String favoriteCurrencies = 'Monedas Favoritas';

  // Pantalla "Historial" (tasas).
  static const String currentRate = 'Tasa Actual';
  static const String globalRates = 'Tasas Globales';
  static const String rangeSevenDays = '7 Días';
  static const String rangeOneWeek = '1W';
  static const String rangeOneYear = '1Y';
  static const String rangeTwoYears = '2Y';

  // Pantalla "Ajustes".
  static const String appPreferences = 'Preferencias de la App';
  static const String darkMode = 'Modo Oscuro';
  static const String notifications = 'Notificaciones';
  static const String rateAlerts = 'Alertas de Tasa';
  static const String baseCurrency = 'Moneda Base';

  // Navegación inferior.
  static const String navHome = 'Inicio';
  static const String navHistory = 'Historial';
  static const String navSettings = 'Ajustes';

  // Mensajes de estado.
  static const String errorLoadingCurrencies =
      'No se pudieron cargar las monedas. Desliza para reintentar.';
  static const String errorLoadingRate =
      'No se pudo obtener la tasa actual.';
  static const String noConnection =
      'Sin conexión. Verifica tu red e inténtalo de nuevo.';
}

/// Configuración de la API pública de tasas de cambio (Frankfurter),
/// según lo documentado en el taller: API abierta, sin API key,
/// que devuelve JSON con date / base / quote(s) / rate(s).
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://api.frankfurter.dev/v1';

  static Uri currencies() => Uri.parse('$baseUrl/currencies');

  static Uri latestRate({required String base, required String quote}) =>
      Uri.parse('$baseUrl/latest?base=$base&symbols=$quote');

  static Uri rankingRates({required String base}) =>
      Uri.parse('$baseUrl/latest?base=$base');

  static Uri historicalRange({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) {
    final f = _fmt(from);
    final t = _fmt(to);
    return Uri.parse('$baseUrl/$f..$t?base=$base&symbols=$quote');
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
