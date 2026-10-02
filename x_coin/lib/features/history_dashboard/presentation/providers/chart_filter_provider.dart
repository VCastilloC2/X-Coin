import 'package:flutter/foundation.dart';

import '../../domain/chart_engine/chart_catalog_filter.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// Estado de la capa de control del dashboard: librería activa,
/// búsqueda y categoría.
///
/// No conoce `RatesProvider` ni hace HTTP: solo decide QUÉ tarjetas se
/// listan (las 32 de la librería activa, filtradas). Los gráficos se
/// construyen después, vía `ChartStrategyFactory`, sin cambios.
class ChartFilterProvider extends ChangeNotifier {
  ChartFilterProvider({ChartLibrary initialLibrary = ChartLibrary.flChart})
      : _library = initialLibrary,
        _filters = {
          for (final lib in ChartLibrary.values)
            lib: ChartCatalogFilter(ChartCatalog.byLibrary(lib)),
        } {
    _recompute(notify: false);
  }

  final Map<ChartLibrary, ChartCatalogFilter> _filters;

  ChartLibrary _library;
  String _query = '';
  ChartCategory? _category; // null = todas
  late List<ChartConfig> _visible;

  ChartLibrary get library => _library;
  String get query => _query;
  ChartCategory? get category => _category;
  List<ChartConfig> get visible => _visible;
  bool get hasActiveFilters => _query.isNotEmpty || _category != null;

  /// Cantidad de gráficas de la librería activa (null = las 32).
  int countFor(ChartCategory? category) =>
      _filters[_library]!.countFor(category);

  /// Cambia de librería conservando búsqueda y categoría vigentes.
  void selectLibrary(ChartLibrary value) {
    if (value == _library) return;
    _library = value;
    _recompute();
  }

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

  /// Limpia búsqueda y categoría (la librería se conserva).
  void clear() {
    if (!hasActiveFilters) return;
    _query = '';
    _category = null;
    _recompute();
  }

  void _recompute({bool notify = true}) {
    _visible = _filters[_library]!.apply(query: _query, category: _category);
    if (notify) notifyListeners();
  }
}
