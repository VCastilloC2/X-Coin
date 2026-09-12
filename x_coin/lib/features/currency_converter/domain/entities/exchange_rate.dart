/// Entidad de dominio que representa una tasa de cambio entre dos
/// monedas en una fecha determinada.
///
/// Refleja el modelo `ExchangeRate` (base / quote / rateValue)
/// documentado en el taller, con el campo `date` adicional para
/// poder graficar la evolución histórica.
class ExchangeRate {
  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateValue,
    required this.date,
  });

  final String baseCurrency;
  final String quoteCurrency;
  final double rateValue;
  final DateTime date;

  /// Fábrica de conversión: mapea la respuesta JSON del API
  /// (formato `{ date, base, rates: { QUOTE: valor } }`) al objeto
  /// nativo `ExchangeRate` usado por la aplicación.
  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>;
    final quote = rates.keys.first;
    return ExchangeRate(
      baseCurrency: json['base'] as String,
      quoteCurrency: quote,
      rateValue: (rates[quote] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

/// Punto de una serie histórica, usado para dibujar la gráfica de
/// "Tasa Actual" (comportamiento del mercado a lo largo del tiempo).
class RatePoint {
  const RatePoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}
