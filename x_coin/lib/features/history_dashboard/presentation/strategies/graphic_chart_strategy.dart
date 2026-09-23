import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../../domain/chart_engine/chart_style.dart';
import '../../domain/math/rate_series_math.dart';
import '../widgets/candle_painter_view.dart';
import '../widgets/heatmap_calendar_view.dart';
import 'chart_strategy.dart';

/// Implementación con `graphic` (grammar-of-graphics), la cuarta
/// librería del catálogo — deliberadamente distinta en paradigma a
/// las otras 3 (declarativa por capas: `variables` + `marks`, en vez
/// de "un widget de chart por tipo").
///
/// ADVERTENCIA DE MANTENIMIENTO: `graphic` es la librería menos
/// estandarizada de las 4 y su API de encoding avanzado (áreas de
/// rango con dos medidas, marcas polares) varía más entre versiones
/// que `fl_chart` o `syncfusion`. Por eso las variantes más
/// exóticas (velas, bandas, heatmap) reutilizan los widgets
/// compartidos [CandlePainterView] / [HeatmapCalendarView] en lugar
/// de forzar un encoding de `graphic` que podría no compilar contra
/// la versión exacta fijada en `pubspec.yaml`. Antes de ampliar este
/// archivo, valida el encoding contra la versión instalada.
class GraphicChartStrategy implements ChartStrategy {
  @override
  ChartLibrary get library => ChartLibrary.graphic;

  @override
  bool supports(ChartType type) => true;

  @override
  Widget build({
    required BuildContext context,
    required ChartConfig config,
    required List<RatePoint> points,
  }) {
    if (points.length < 2) return const _Empty();
    final style = config.style;

    switch (config.type) {
      case ChartType.candlestick:
      case ChartType.ohlcBar:
      case ChartType.candleVolumeCombo:
        return CandlePainterView(
          candles: RateSeriesMath.toCandles(points),
          showVolume: config.type == ChartType.candleVolumeCombo,
        );

      case ChartType.heatmapCalendar:
        return HeatmapCalendarView(points: points, style: style);

      case ChartType.bollingerBands:
      case ChartType.volatilityStdDevBands:
      case ChartType.rangeAreaBollingerFill:
        return _multiLine(points, style, [
          points.map((p) => p.value).toList(),
          RateSeriesMath.bollingerBands(points).upper,
          RateSeriesMath.bollingerBands(points).lower,
        ]);

      case ChartType.multiCurrencyComparison:
        return _multiLine(
          points,
          style,
          [points.map((p) => p.value).toList(), RateSeriesMath.movingAverage(points, 30)],
        );

      case ChartType.lineMovingAverage:
        return _multiLine(
          points,
          style,
          [points.map((p) => p.value).toList(), RateSeriesMath.movingAverage(points, 7)],
        );

      case ChartType.linePercentChange:
        return _singleLine(points, RateSeriesMath.percentChange(points), style, area: false);

      case ChartType.cumulativeReturnArea:
        return _singleLine(points, RateSeriesMath.percentChange(points), style, area: true);

      case ChartType.drawdownArea:
        return _singleLine(points, RateSeriesMath.drawdown(points), style, area: true);

      case ChartType.rsiOscillator:
        return _singleLine(points, RateSeriesMath.rsi(points), style, area: false);

      case ChartType.barVertical:
      case ChartType.barHorizontal:
      case ChartType.barGroupedWeekly:
      case ChartType.barStackedMinMax:
      case ChartType.barRounded:
      case ChartType.columnRangeHiLo:
      case ChartType.dualAxisLineBar:
        return _bars(points, style);

      case ChartType.scatterCorrelation:
        return _scatter(points, style);

      case ChartType.donutLatestShare:
        return _progressRing(points, style);

      // Familia línea/área restante: lineSimple, lineSpline,
      // lineStepped, lineDashedTrend, lineWithMarkers, sparkline,
      // areaSimple, areaGradient, areaSpline, areaStep.
      default:
        final isArea = config.type.name.startsWith('area');
        return _singleLine(points, points.map((p) => p.value).toList(), style, area: isArea);
    }
  }

  List<Map<String, dynamic>> _asRows(List<RatePoint> points, List<double> values) => [
        for (var i = 0; i < points.length; i++) {'x': points[i].date, 'y': values[i]},
      ];

  Widget _singleLine(List<RatePoint> points, List<double> values, ChartStyle style, {required bool area}) {
    return SizedBox(
      height: 180,
      child: Chart(
        data: _asRows(points, values),
        variables: {
          'x': Variable(accessor: (Map d) => d['x'] as DateTime),
          'y': Variable(accessor: (Map d) => d['y'] as num, scale: LinearScale(niceRange: true)),
        },
        marks: [
          if (area)
            AreaMark(
              shape: ShapeEncode(value: BasicAreaShape(smooth: style.isCurved)),
              color: ColorEncode(value: style.primaryColor.withValues(alpha: style.gradientOpacity)),
            ),
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(smooth: style.isCurved)),
            size: SizeEncode(value: style.strokeWidth),
            color: ColorEncode(value: style.primaryColor),
          ),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
      ),
    );
  }

  Widget _multiLine(List<RatePoint> points, ChartStyle style, List<List<double>> series) {
    final colors = [style.primaryColor, style.secondaryColor, style.secondaryColor.withValues(alpha: 0.6)];
    final rows = <Map<String, dynamic>>[];
    for (var s = 0; s < series.length; s++) {
      for (var i = 0; i < series[s].length && i < points.length; i++) {
        rows.add({'x': points[i].date, 'y': series[s][i], 'serie': 's$s'});
      }
    }
    return SizedBox(
      height: 180,
      child: Chart(
        data: rows,
        variables: {
          'x': Variable(accessor: (Map d) => d['x'] as DateTime),
          'y': Variable(accessor: (Map d) => d['y'] as num, scale: LinearScale(niceRange: true)),
          'serie': Variable(accessor: (Map d) => d['serie'] as String),
        },
        marks: [
          LineMark(
            shape: ShapeEncode(value: BasicLineShape(smooth: style.isCurved)),
            color: ColorEncode(
              variable: 'serie',
              values: [for (var i = 0; i < series.length; i++) colors[i % colors.length]],
            ),
          ),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
      ),
    );
  }

  Widget _bars(List<RatePoint> points, ChartStyle style) {
    final sample = points.length > 24
        ? [for (var i = 0; i < points.length; i += (points.length / 24).ceil()) points[i]]
        : points;
    return SizedBox(
      height: 180,
      child: Chart(
        data: [for (final p in sample) {'x': '${p.date.day}/${p.date.month}', 'y': p.value}],
        variables: {
          'x': Variable(accessor: (Map d) => d['x'] as String),
          'y': Variable(accessor: (Map d) => d['y'] as num, scale: LinearScale(niceRange: true)),
        },
        marks: [
          IntervalMark(color: ColorEncode(value: style.primaryColor)),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
      ),
    );
  }

  Widget _scatter(List<RatePoint> points, ChartStyle style) {
    final ma = RateSeriesMath.movingAverage(points, 7);
    return SizedBox(
      height: 180,
      child: Chart(
        data: [
          for (var i = 0; i < points.length; i++) {'x': ma[i], 'y': points[i].value},
        ],
        variables: {
          'x': Variable(accessor: (Map d) => d['x'] as num, scale: LinearScale(niceRange: true)),
          'y': Variable(accessor: (Map d) => d['y'] as num, scale: LinearScale(niceRange: true)),
        },
        marks: [
          PointMark(color: ColorEncode(value: style.primaryColor)),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
      ),
    );
  }

  Widget _progressRing(List<RatePoint> points, ChartStyle style) {
    final values = points.map((p) => p.value);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final progress = maxV == minV ? 0.5 : (points.last.value - minV) / (maxV - minV);
    return SizedBox(
      height: 180,
      child: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: style.primaryColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(style.primaryColor),
              ),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 140,
        child: Center(child: Text('Sin datos suficientes para graficar')),
      );
}
