import 'package:intl/intl.dart';

/// Punto único de formato numérico y monetario de X-Coin.
///
/// Antes cada widget hacía `toStringAsFixed(2)` y concatenaba
/// `currency.symbol`, lo que producía tres problemas para COP:
///
///  1. Sin separadores de miles ni coma decimal (`4100.50` en vez de
///     `4.100,50`), porque `intl` estaba en el pubspec pero nunca se usó.
///  2. El símbolo `$` es el mismo para USD y COP, así que una
///     conversión USD → COP mostraba `$100` ⇒ `$405231.00`, ambiguo.
///  3. Tasas COP → X (p. ej. 1 COP = 0.000247 USD) se redondeaban a
///     `0.00` con solo 2 decimales.
///
/// Los números los formatea `intl` con la convención colombiana
/// (`es_CO`: `.` para miles, `,` para decimales). El símbolo lo
/// decidimos nosotros porque `$` es ambiguo entre monedas.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Locale de toda la app (también se registra en `MaterialApp`).
  static const String locale = 'es_CO';

  // Separadores de es_CO, usados solo para el texto que el usuario está
  // escribiendo (ver [amountInput]) y para interpretar lo que escribe
  // (ver [parseAmount]). El resto de formatos lo resuelve `intl`.
  static const String _groupSeparator = '.';
  static const String _decimalSeparator = ',';

  /// Símbolo mostrado por moneda. COP lleva el prefijo `COP` para no
  /// confundirse con USD (`$`). Cualquier otra moneda cae al código ISO.
  static const Map<String, String> _symbolByIso = {
    'USD': r'$',
    'EUR': '€',
    'GBP': '£',
    'CAD': r'C$',
    'JPY': '¥',
    'AUD': r'A$',
    'CHF': 'CHF ',
    'COP': r'COP $',
  };

  static final Map<int, NumberFormat> _digitsCache = {};

  static NumberFormat _digits(int decimals) {
    return _digitsCache.putIfAbsent(
      decimals,
      () => NumberFormat.decimalPatternDigits(
        locale: locale,
        decimalDigits: decimals,
      ),
    );
  }

  /// Símbolo (o prefijo) de [iso]; si no hay uno definido, el propio ISO.
  static String symbolFor(String iso) {
    final code = iso.toUpperCase();
    return _symbolByIso[code] ?? (code.isEmpty ? '' : '$code ');
  }

  /// Número con separadores es_CO: `4100.5` → `4.100,50`.
  static String amount(double value, {int decimals = 2}) {
    return _digits(decimals).format(value);
  }

  /// Monto con su símbolo: `money(4100.5, 'COP')` → `COP $4.100,50`.
  static String money(double value, String iso, {int decimals = 2}) {
    return '${symbolFor(iso)}${amount(value, decimals: decimals)}';
  }

  /// Tasa para listas (Tasas Globales): 6 decimales si es < 1, si no 2.
  /// Mantiene el comportamiento previo (`0.827750`), ahora localizado.
  static String rate(double value) {
    return amount(value, decimals: value.abs() < 1 ? 6 : 2);
  }

  /// Tasa destacada ("1 USD = 0,88 EUR"): 2 decimales salvo que sea tan
  /// pequeña (p. ej. 1 COP = 0,000247 USD) que 2 decimales daría `0,00`.
  static String heroRate(double value) {
    return amount(value, decimals: value.abs() >= 0.1 ? 2 : 6);
  }

  /// Formato compacto para ejes de gráficas: hasta 4 decimales, sin
  /// ceros sobrantes (`4.052,31`, `0,8765`).
  static NumberFormat axisFormat() => NumberFormat('#,##0.####', locale);

  /// Da formato es_CO al monto tal como se va tecleando en el keypad
  /// (`'1234.5'` → `'1.234,5'`, `'0.'` → `'0,'`). Se agrupa a mano el
  /// texto en curso porque una cadena parcial como `"12."` no es un
  /// número válido para `NumberFormat` y perdería el punto decimal.
  static String amountInput(String raw) {
    if (raw.isEmpty) return '0';
    final dot = raw.indexOf('.');
    final integerPart = dot == -1 ? raw : raw.substring(0, dot);
    final grouped = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => _groupSeparator,
    );
    if (dot == -1) return grouped;
    return '$grouped$_decimalSeparator${raw.substring(dot + 1)}';
  }

  /// Interpreta texto escrito por un usuario colombiano o anglosajón:
  /// `4100`, `4100,5`, `4.100,50`, `4,100.50` y `4.100` (miles en es_CO).
  /// Devuelve `null` si no es un número.
  static double? parseAmount(String input) {
    var text = input.replaceAll(RegExp(r'\s'), '');
    if (text.isEmpty) return null;

    final hasDot = text.contains('.');
    final hasComma = text.contains(',');

    if (hasDot && hasComma) {
      // El último separador es el decimal: 4.100,50 (es) o 4,100.50 (en).
      final commaIsDecimal = text.lastIndexOf(',') > text.lastIndexOf('.');
      text = commaIsDecimal
          ? text.replaceAll('.', '').replaceAll(',', '.')
          : text.replaceAll(',', '');
    } else if (hasComma) {
      text = text.replaceAll(',', '.');
    } else if (hasDot && RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(text)) {
      // "4.100" / "1.250.000": en es_CO son miles, no decimales.
      text = text.replaceAll('.', '');
    }
    return double.tryParse(text);
  }
}
