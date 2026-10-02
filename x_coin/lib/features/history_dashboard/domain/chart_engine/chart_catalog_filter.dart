import 'chart_config.dart';
import 'chart_enums.dart';

/// Etiquetas legibles de [ChartCategory] (extensión: no se toca el enum).
extension ChartCategoryLabelX on ChartCategory {
  String get label => switch (this) {
        ChartCategory.basic => 'Básicas',
        ChartCategory.advanced => 'Avanzadas',
      };

  String get singularLabel => switch (this) {
        ChartCategory.basic => 'Básica',
        ChartCategory.advanced => 'Avanzada',
      };
}

/// Minúsculas + sin tildes, para que "grafica" encuentre "Gráfica".
String normalizeSearchText(String input) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final i = from.indexOf(char);
    buffer.write(i >= 0 ? to[i] : char);
  }
  return buffer.toString();
}

/// Lógica pura de filtrado (sin Flutter): fácil de testear.
///
/// Búsqueda: cada palabra escrita debe aparecer en el título O en el
/// nombre de la categoría de la gráfica (AND entre palabras).
/// Categoría: filtro independiente; `null` = todas.
class ChartCatalogFilter {
  ChartCatalogFilter(List<ChartConfig> source)
      : _source = source,
        _haystack = {
          for (final c in source)
            c.id: normalizeSearchText(
              '${c.title} ${c.category.singularLabel} ${c.category.label}',
            ),
        };

  final List<ChartConfig> _source;
  final Map<String, String> _haystack;

  int countFor(ChartCategory? category) => category == null
      ? _source.length
      : _source.where((c) => c.category == category).length;

  List<ChartConfig> apply({String query = '', ChartCategory? category}) {
    final tokens = normalizeSearchText(query)
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    return _source.where((c) {
      if (category != null && c.category != category) return false;
      final text = _haystack[c.id]!;
      return tokens.every(text.contains);
    }).toList(growable: false);
  }
}
