import '../../domain/chart_engine/chart_enums.dart';
import 'chart_strategy.dart';
import 'community_charts_strategy.dart';
import 'fl_chart_strategy.dart';
import 'graphic_chart_strategy.dart';
import 'syncfusion_chart_strategy.dart';

/// Punto único de acoplamiento con las 4 librerías concretas.
///
/// El resto del módulo (UI, provider) solo conoce [ChartStrategy] y
/// [ChartLibrary]; nunca importa `fl_chart`, `syncfusion_flutter_charts`,
/// etc. directamente. Cambiar de librería en tiempo real es un
/// simple `factory.strategyFor(library)`.
class ChartStrategyFactory {
  ChartStrategyFactory._();

  static final Map<ChartLibrary, ChartStrategy> _strategies = {
    ChartLibrary.flChart: FlChartStrategy(),
    ChartLibrary.syncfusion: SyncfusionChartStrategy(),
    ChartLibrary.communityCharts: CommunityChartsStrategy(),
    ChartLibrary.graphic: GraphicChartStrategy(),
  };

  static ChartStrategy strategyFor(ChartLibrary library) {
    final strategy = _strategies[library];
    assert(strategy != null, 'No hay ChartStrategy registrada para $library');
    return strategy!;
  }
}
