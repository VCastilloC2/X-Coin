import 'package:flutter_test/flutter_test.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_catalog_filter.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_config.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_enums.dart';
import 'package:x_coin/features/history_dashboard/presentation/providers/chart_filter_provider.dart';

void main() {
  group('ChartCatalogFilter (una librería)', () {
    final filter = ChartCatalogFilter(ChartCatalog.byLibrary(ChartLibrary.flChart));

    test('sin filtros devuelve las 32 gráficas', () {
      expect(filter.apply().length, 32);
    });

    test('busca por título sin importar tildes ni mayúsculas', () {
      final r = filter.apply(query: 'VELAS japonesas');
      expect(r.map((c) => c.type), [ChartType.candlestick]);
    });

    test('busca por nombre de categoría', () {
      final r = filter.apply(query: 'avanzada');
      expect(r.length, 12);
      expect(r.every((c) => c.category == ChartCategory.advanced), isTrue);
    });

    test('búsqueda y categoría se combinan', () {
      final r = filter.apply(query: 'velas', category: ChartCategory.advanced);
      expect(r.length, 2);
      expect(filter.apply(query: 'velas', category: ChartCategory.basic), isEmpty);
    });
  });

  group('ChartFilterProvider', () {
    test('muestra solo las 32 de la librería activa y conserva filtros al cambiar', () {
      final p = ChartFilterProvider();
      expect(p.visible.length, 32);
      expect(p.visible.every((c) => c.library == ChartLibrary.flChart), isTrue);

      p.setCategory(ChartCategory.advanced);
      p.selectLibrary(ChartLibrary.syncfusion);
      expect(p.visible.length, 12);
      expect(p.visible.every((c) => c.library == ChartLibrary.syncfusion), isTrue);
    });
  });
}
