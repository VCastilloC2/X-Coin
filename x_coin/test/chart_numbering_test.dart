import 'package:flutter_test/flutter_test.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_catalog_filter.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_config.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_enums.dart';
import 'package:x_coin/features/history_dashboard/domain/chart_engine/chart_numbering.dart';
import 'package:x_coin/features/history_dashboard/presentation/providers/chart_filter_provider.dart';

void main() {
  test('cada librería numera sus 32 gráficas del 1 al 32 sin huecos', () {
    for (final lib in ChartLibrary.values) {
      final numbers = ChartCatalog.byLibrary(lib).map((c) => c.number).toList();
      expect(numbers, List.generate(32, (i) => i + 1), reason: lib.name);
    }
  });

  test('formato #01 … #32', () {
    final first = ChartCatalog.byLibrary(ChartLibrary.graphic).first;
    final last = ChartCatalog.byLibrary(ChartLibrary.graphic).last;
    expect(first.numberLabel, '#01');
    expect(last.numberLabel, '#32');
  });

  test('el número es estable al filtrar y se reinicia al cambiar de librería', () {
    final all = ChartFilterProvider();
    final numberOf = {for (final c in all.visible) c.type: c.number};

    final p = ChartFilterProvider();
    p.setCategory(ChartCategory.advanced);
    p.setQuery('velas');
    // Mismos números que en la lista completa (no se renumera por posición).
    for (final c in p.visible) {
      expect(c.number, numberOf[c.type]);
    }
    expect(p.visible.first.number, greaterThan(20)); // avanzadas: #21..#32

    p.selectLibrary(ChartLibrary.syncfusion);
    for (final c in p.visible) {
      expect(c.library, ChartLibrary.syncfusion);
      expect(c.number, numberOf[c.type]);
    }
  });

  test('el buscador no cambió: sigue filtrando por título y categoría', () {
    final f = ChartCatalogFilter(ChartCatalog.byLibrary(ChartLibrary.flChart));
    expect(f.apply().length, 32);
    expect(f.apply(query: 'avanzada').length, 12);
  });
}
