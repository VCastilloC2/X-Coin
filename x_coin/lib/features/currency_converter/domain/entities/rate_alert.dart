import '../../../../core/utils/currency_formatter.dart';

/// Dirección del umbral de una alerta de tasa.
enum RateAlertDirection { above, below }

/// Entidad de dominio que representa una alerta de tasa configurada
/// por el usuario en Ajustes, ej.: "Notificar si 1 USD > 4100 COP".
class RateAlert {
  const RateAlert({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.threshold,
    required this.direction,
  });

  final String baseCurrency;
  final String quoteCurrency;
  final double threshold;
  final RateAlertDirection direction;

  /// Serializa a JSON para persistencia en `shared_preferences`.
  Map<String, dynamic> toJson() => {
        'base': baseCurrency,
        'quote': quoteCurrency,
        'threshold': threshold,
        'direction': direction.name,
      };

  factory RateAlert.fromJson(Map<String, dynamic> json) {
    return RateAlert(
      baseCurrency: json['base'] as String,
      quoteCurrency: json['quote'] as String,
      threshold: (json['threshold'] as num).toDouble(),
      direction: RateAlertDirection.values.firstWhere(
        (d) => d.name == json['direction'],
        orElse: () => RateAlertDirection.above,
      ),
    );
  }

  /// Descripción legible mostrada como subtítulo en Ajustes, ej.:
  /// "Notificar si 1 USD > 4.100,00 COP".
  String get description {
    final symbol = direction == RateAlertDirection.above ? '>' : '<';
    return 'Notificar si 1 $baseCurrency $symbol '
        '${CurrencyFormatter.amount(threshold)} $quoteCurrency';
  }
}
