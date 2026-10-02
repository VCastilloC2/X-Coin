import 'package:flutter/foundation.dart';

import '../../domain/chart_engine/chart_catalog_filter.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// Estado de búsqueda + categoría del dashboard.
///
/// Igual que `HistoryDashboardProvider`, no conoce `RatesProvider` ni
/// hace HTTP: solo decide QUÉ tarjetas se listan. Los gráficos se
/// construyen después, vía `ChartStrategyFactory`, sin cambios.
class ChartFilterProvider extends ChangeNotifier {
  ChartFilterProvider({List<ChartConfig>? source})
      : _filter = ChartCatalogFilter(source ?? ChartCatalog.all) {
    _visible = _filter.apply();
  }

  final ChartCatalogFilter _filter;

  String _query = '';
  ChartCategory? _category; // null = todas
  late List<ChartConfig> _visible;

  String get query => _query;
  ChartCategory? get category => _category;
  List<ChartConfig> get visible => _visible;
  bool get hasActiveFilters => _query.isNotEmpty || _category != null;

  int countFor(ChartCategory? category) => _filter.countFor(category);

  void setQuery(String value) {
    final trimmed = value.trim();
    if (trimmed == _query) return;
    _query = trimmed;
    _recompute();
  }

  void setCategory(ChartCategory? value) {
    if (value == _category) return;
    _category = value;
    _recompute();
  }

  void clear() {
    if (!hasActiveFilters) return;
    _query = '';
    _category = null;
    _recompute();
  }

  void _recompute() {
    _visible = _filter.apply(query: _query, category: _category);
    notifyListeners();
  }
}
