import 'package:flutter/foundation.dart';
import 'chart_enums.dart';
import 'chart_style.dart';

/// Configuración inmutable de UNA gráfica del catálogo.
/// Es el objeto que viaja desde la UI hasta el `ChartStrategyFactory`:
/// nunca se instancia un widget "hardcodeado" por gráfica, sino que
/// se construye a partir de este dato.
@immutable
class ChartConfig {
  const ChartConfig({
    required this.id,
    required this.library,
    required this.type,
    required this.style,
  });

  /// Identificador estable, ej. `flChart.candlestick`.
  final String id;
  final ChartLibrary library;
  final ChartType type;
  final ChartStyle style;

  ChartCategory get category => type.category;

  String get title => '${library.label} · ${type.displayName}';

  @override
  bool operator ==(Object other) => other is ChartConfig && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Motor de configuración: genera las 128 gráficas (4 librerías × 32
/// tipos) de forma perezosa y determinística. Añadir una librería o
/// un tipo de gráfica nuevo NO requiere tocar ningún widget — solo
/// se agrega un valor al enum correspondiente y el catálogo crece
/// solo.
class ChartCatalog {
  ChartCatalog._();

  static final List<ChartConfig> _all = _build();

  static List<ChartConfig> get all => _all;

  static List<ChartConfig> byLibrary(ChartLibrary library) =>
      _all.where((c) => c.library == library).toList();

  static List<ChartConfig> byLibraryAndCategory(
    ChartLibrary library,
    ChartCategory category,
  ) =>
      _all
          .where((c) => c.library == library && c.category == category)
          .toList();

  static List<ChartConfig> _build() {
    final configs = <ChartConfig>[];
    var seed = 0;
    for (final library in ChartLibrary.values) {
      for (final type in ChartType.values) {
        configs.add(
          ChartConfig(
            id: '${library.name}.${type.name}',
            library: library,
            type: type,
            style: ChartStyle.fromSeed(seed),
          ),
        );
        seed++;
      }
    }
    // Invariante de diseño: 4 librerías × 32 tipos = 128 gráficas.
    assert(configs.length == ChartLibrary.values.length * ChartType.values.length);
    return configs;
  }
}
