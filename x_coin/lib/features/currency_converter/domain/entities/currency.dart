/// Entidad de dominio que representa una moneda del catálogo.
///
/// Corresponde al modelo `Currency` descrito en el taller para
/// poblar las listas desplegables ("Moneda de Origen" / "Moneda de
/// Destino") y las tarjetas de "Monedas Favoritas".
class Currency {
  const Currency({
    required this.isoCode,
    required this.name,
    required this.symbol,
    required this.flagEmoji,
  });

  final String isoCode;
  final String name;
  final String symbol;
  final String flagEmoji;

  factory Currency.fromJson(String isoCode, Map<String, dynamic> json) {
    return Currency(
      isoCode: isoCode,
      name: json['name'] as String? ?? isoCode,
      symbol: json['symbol'] as String? ?? '',
      flagEmoji: json['flag'] as String? ?? '🏳️',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && other.isoCode == isoCode;

  @override
  int get hashCode => isoCode.hashCode;
}
