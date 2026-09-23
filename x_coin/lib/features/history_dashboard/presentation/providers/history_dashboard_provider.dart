import 'package:flutter/foundation.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// Estado de UI del Dashboard Analítico.
///
/// Deliberadamente NO conoce `RatesProvider` ni hace peticiones HTTP:
/// solo decide QUÉ combinación (librería × tipo) mostrar. Los datos
/// (`List<RatePoint>`) siempre llegan desde afuera (ya resueltos por
/// `RatesProvider.history`), así que cambiar de librería o de tipo de
/// gráfica es una operación 100% en memoria — cero round-trips.
class HistoryDashboardProvider extends ChangeNotifier {
  ChartLibrary _library = ChartLibrary.flChart;
  ChartCategory _category = ChartCategory.basic;
  ChartType _type = ChartType.lineSimple;

  ChartLibrary get library => _library;
  ChartCategory get category => _category;
  ChartType get type => _type;

  ChartConfig get activeConfig {
    final index = ChartLibrary.values.indexOf(_library) * ChartType.values.length +
        ChartType.values.indexOf(_type);
    return ChartCatalog.all[index];
  }

  List<ChartType> get availableTypes => _category == ChartCategory.basic
      ? ChartType.basics
      : ChartType.advanced;

  void selectLibrary(ChartLibrary library) {
    if (library == _library) return;
    _library = library;
    notifyListeners();
  }

  void selectCategory(ChartCategory category) {
    if (category == _category) return;
    _category = category;
    // Al cambiar de categoría, el tipo activo puede quedar fuera del
    // set disponible: se ajusta al primero de la nueva categoría.
    _type = (category == ChartCategory.basic ? ChartType.basics : ChartType.advanced).first;
    notifyListeners();
  }

  void selectType(ChartType type) {
    if (type == _type) return;
    _type = type;
    notifyListeners();
  }
}
