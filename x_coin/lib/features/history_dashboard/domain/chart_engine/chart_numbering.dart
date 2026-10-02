import 'chart_config.dart';
import 'chart_enums.dart';

/// Numeración estricta 1..32 de las gráficas dentro de su librería.
///
/// El número NO depende del filtrado ni de la posición en pantalla: es la
/// posición fija del tipo en [ChartType.values]. Como el catálogo genera
/// los mismos 32 tipos, en el mismo orden, para cada librería
/// (`ChartCatalog._build`), la numeración se reinicia sola al cambiar de
/// librería, y "#07" sigue siendo "#07" aunque el buscador o la categoría
/// oculten a sus vecinas.
///
/// Es una extensión de solo lectura: no modifica enums, catálogo,
/// estrategias ni el buscador.
extension ChartNumbering on ChartConfig {
  /// 1..32 (posición del tipo dentro de la librería).
  int get number => type.index + 1;

  /// "#01" … "#32".
  String get numberLabel => '#${number.toString().padLeft(2, '0')}';
}
