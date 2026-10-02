import 'package:flutter_test/flutter_test.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_catalog_filter.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_config.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_enums.dart';

void main() {
  final filter = ChartCatalogFilter(ChartCatalog.all);

  test('sin filtros devuelve las 128 gráficas', () {
    expect(filter.apply().length, 128);
  });

  test('busca por título sin importar tildes ni mayúsculas', () {
    final r = filter.apply(query: 'LINEA suavizada');
    expect(r, isNotEmpty);
    expect(r.every((c) => c.type == ChartType.lineSpline), isTrue);
  });

  test('busca por nombre de categoría', () {
    final r = filter.apply(query: 'avanzada');
    expect(r.length, 48);
    expect(r.every((c) => c.category == ChartCategory.advanced), isTrue);
  });

  test('búsqueda y categoría se combinan', () {
    final r = filter.apply(query: 'fl chart', category: ChartCategory.basic);
    expect(r.length, 20);
  });
}
