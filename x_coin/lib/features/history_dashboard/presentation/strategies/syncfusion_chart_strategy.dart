import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../../domain/chart_engine/chart_style.dart';
import '../../domain/math/rate_series_math.dart';
import '../widgets/heatmap_calendar_view.dart';
import 'chart_strategy.dart';

class _P {
  const _P(this.date, this.value);
  final DateTime date;
  final double value;
}

/// Implementación con `syncfusion_flutter_charts`. A diferencia de
/// `fl_chart`, Syncfusion sí trae series nativas de velas (`CandleSeries`)
/// y OHLC (`HiloOpenCloseSeries`), así que esas 2 variantes se
/// renderizan con soporte real de la librería, no con un painter.
class SyncfusionChartStrategy implements ChartStrategy {
  @override
  ChartLibrary get library => ChartLibrary.syncfusion;

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
    final series = points.map((p) => _P(p.date, p.value)).toList();

    switch (config.type) {
      case ChartType.lineSimple:
        return _cartesian(style, [_line(series, style)]);
      case ChartType.lineSpline:
        return _cartesian(style, [_spline(series, style)]);
      case ChartType.lineStepped:
        return _cartesian(style, [_step(series, style)]);
      case ChartType.lineDashedTrend:
        return _cartesian(style, [_line(series, style, dashArray: const [6, 4])]);
      case ChartType.lineWithMarkers:
        return _cartesian(style, [_line(series, style, markers: true)]);
      case ChartType.sparkline:
        return _cartesian(style, [_line(series, style)], compact: true);

      case ChartType.areaSimple:
        return _cartesian(style, [_area(series, style)]);
      case ChartType.areaGradient:
        return _cartesian(style, [_area(series, style, gradient: true)]);
      case ChartType.areaSpline:
        return _cartesian(style, [
          SplineAreaSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor.withValues(alpha: style.gradientOpacity),
            borderColor: style.primaryColor,
            borderWidth: style.strokeWidth,
          ),
        ]);
      case ChartType.areaStep:
        return _cartesian(style, [
          StepAreaSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor.withValues(alpha: style.gradientOpacity),
            borderColor: style.primaryColor,
            borderWidth: style.strokeWidth,
          ),
        ]);

      case ChartType.lineMovingAverage:
        final ma = RateSeriesMath.movingAverage(points, 7);
        return _cartesian(style, [
          _line(series, style, opacity: 0.4),
          _line(
            [for (var i = 0; i < ma.length; i++) _P(points[i].date, ma[i])],
            style,
            colorOverride: style.secondaryColor,
          ),
        ]);

      case ChartType.linePercentChange:
        final pct = RateSeriesMath.percentChange(points);
        return _cartesian(style, [
          _line([for (var i = 0; i < pct.length; i++) _P(points[i].date, pct[i])], style),
        ]);

      case ChartType.cumulativeReturnArea:
        final pct = RateSeriesMath.percentChange(points);
        return _cartesian(style, [
          _area([for (var i = 0; i < pct.length; i++) _P(points[i].date, pct[i])], style,
              gradient: true),
        ]);

      case ChartType.drawdownArea:
        final dd = RateSeriesMath.drawdown(points);
        return _cartesian(style, [
          AreaSeries<_P, DateTime>(
            dataSource: [for (var i = 0; i < dd.length; i++) _P(points[i].date, dd[i])],
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: AppColors.danger.withValues(alpha: 0.25),
            borderColor: AppColors.danger,
          ),
        ]);

      case ChartType.rsiOscillator:
        final rsi = RateSeriesMath.rsi(points);
        return _cartesian(
          style,
          [_line([for (var i = 0; i < rsi.length; i++) _P(points[i].date, rsi[i])], style)],
          minimum: 0,
          maximum: 100,
        );

      case ChartType.barVertical:
      case ChartType.barRounded:
      case ChartType.columnRangeHiLo:
        return _cartesian(style, [
          ColumnSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor,
            borderRadius: config.type == ChartType.barRounded
                ? const BorderRadius.vertical(top: Radius.circular(6))
                : BorderRadius.zero,
          ),
        ]);
      case ChartType.barHorizontal:
        return _cartesian(style, [
          BarSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor,
          ),
        ]);
      case ChartType.barGroupedWeekly:
        return _cartesian(style, [
          ColumnSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor,
            width: 0.6,
          ),
        ]);
      case ChartType.barStackedMinMax:
        final ma = RateSeriesMath.movingAverage(points, 5);
        return _cartesian(style, [
          StackedColumnSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.primaryColor,
          ),
          StackedColumnSeries<_P, DateTime>(
            dataSource: [for (var i = 0; i < ma.length; i++) _P(points[i].date, ma[i] * 0.02)],
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.secondaryColor,
          ),
        ]);

      case ChartType.dualAxisLineBar:
        final volume = RateSeriesMath.syntheticVolume(points);
        return _cartesian(style, [
          ColumnSeries<_P, DateTime>(
            dataSource: [for (var i = 0; i < volume.length; i++) _P(points[i + 1].date, volume[i])],
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.secondaryColor.withValues(alpha: 0.35),
          ),
          _line(series, style),
        ]);

      case ChartType.donutLatestShare:
        final values = points.map((p) => p.value);
        final minV = values.reduce((a, b) => a < b ? a : b);
        final maxV = values.reduce((a, b) => a > b ? a : b);
        final progress = maxV == minV ? 0.5 : (points.last.value - minV) / (maxV - minV);
        return SizedBox(
          height: 180,
          child: SfCircularChart(
            series: [
              DoughnutSeries<double, String>(
                dataSource: [progress * 100, (1 - progress) * 100],
                xValueMapper: (v, i) => i == 0 ? 'Actual' : 'Rango',
                yValueMapper: (v, _) => v,
                pointColorMapper: (v, i) =>
                    i == 0 ? style.primaryColor : AppColors.surfaceMuted,
              ),
            ],
          ),
        );

      case ChartType.scatterCorrelation:
        final ma = RateSeriesMath.movingAverage(points, 7);
        return _cartesian(style, [
          ScatterSeries<_P, DateTime>(
            dataSource: [for (var i = 0; i < ma.length; i++) _P(points[i].date, points[i].value)],
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            pointColorMapper: (_, __) => style.primaryColor,
          ),
        ]);

      case ChartType.multiCurrencyComparison:
        final ma = RateSeriesMath.movingAverage(points, 30);
        return _cartesian(style, [
          _line(series, style, opacity: 0.9),
          _line(
            [for (var i = 0; i < ma.length; i++) _P(points[i].date, ma[i])],
            style,
            colorOverride: style.secondaryColor,
            dashArray: const [4, 3],
          ),
        ]);

      case ChartType.bollingerBands:
      case ChartType.volatilityStdDevBands:
      case ChartType.rangeAreaBollingerFill:
        final bands = RateSeriesMath.bollingerBands(points);
        return _cartesian(style, [
          RangeAreaSeries<_P, DateTime>(
            dataSource: series,
            xValueMapper: (p, _) => p.date,
            highValueMapper: (p, i) => bands.upper[i],
            lowValueMapper: (p, i) => bands.lower[i],
            color: style.secondaryColor.withValues(alpha: 0.15),
            borderColor: style.secondaryColor.withValues(alpha: 0.4),
          ),
          _line(series, style),
        ]);

      case ChartType.candlestick:
        return _cartesian(style, [
          CandleSeries<SyntheticCandle, DateTime>(
            dataSource: RateSeriesMath.toCandles(points),
            xValueMapper: (c, _) => c.date,
            lowValueMapper: (c, _) => c.low,
            highValueMapper: (c, _) => c.high,
            openValueMapper: (c, _) => c.open,
            closeValueMapper: (c, _) => c.close,
            bearColor: AppColors.danger,
            bullColor: AppColors.success,
          ),
        ]);

      case ChartType.ohlcBar:
        return _cartesian(style, [
          HiloOpenCloseSeries<SyntheticCandle, DateTime>(
            dataSource: RateSeriesMath.toCandles(points),
            xValueMapper: (c, _) => c.date,
            lowValueMapper: (c, _) => c.low,
            highValueMapper: (c, _) => c.high,
            openValueMapper: (c, _) => c.open,
            closeValueMapper: (c, _) => c.close,
            bearColor: AppColors.danger,
            bullColor: AppColors.success,
          ),
        ]);

      case ChartType.candleVolumeCombo:
        final volume = RateSeriesMath.syntheticVolume(points);
        final candles = RateSeriesMath.toCandles(points);
        return _cartesian(style, [
          ColumnSeries<_P, DateTime>(
            dataSource: [for (var i = 0; i < volume.length; i++) _P(candles[i].date, volume[i])],
            xValueMapper: (p, _) => p.date,
            yValueMapper: (p, _) => p.value,
            color: style.secondaryColor.withValues(alpha: 0.3),
          ),
          CandleSeries<SyntheticCandle, DateTime>(
            dataSource: candles,
            xValueMapper: (c, _) => c.date,
            lowValueMapper: (c, _) => c.low,
            highValueMapper: (c, _) => c.high,
            openValueMapper: (c, _) => c.open,
            closeValueMapper: (c, _) => c.close,
            bearColor: AppColors.danger,
            bullColor: AppColors.success,
          ),
        ]);

      case ChartType.heatmapCalendar:
        return HeatmapCalendarView(points: points, style: style);
    }
  }

  CartesianSeries<_P, DateTime> _line(
    List<_P> series,
    ChartStyle style, {
    List<double>? dashArray,
    bool markers = false,
    double opacity = 1,
    Color? colorOverride,
  }) {
    return LineSeries<_P, DateTime>(
      dataSource: series,
      xValueMapper: (p, _) => p.date,
      yValueMapper: (p, _) => p.value,
      color: (colorOverride ?? style.primaryColor).withValues(alpha: opacity),
      width: style.strokeWidth,
      dashArray: dashArray,
      markerSettings: MarkerSettings(isVisible: markers || style.showDots),
    );
  }

  CartesianSeries<_P, DateTime> _spline(List<_P> series, ChartStyle style) {
    return SplineSeries<_P, DateTime>(
      dataSource: series,
      xValueMapper: (p, _) => p.date,
      yValueMapper: (p, _) => p.value,
      color: style.primaryColor,
      width: style.strokeWidth,
    );
  }

  CartesianSeries<_P, DateTime> _step(List<_P> series, ChartStyle style) {
    return StepLineSeries<_P, DateTime>(
      dataSource: series,
      xValueMapper: (p, _) => p.date,
      yValueMapper: (p, _) => p.value,
      color: style.primaryColor,
      width: style.strokeWidth,
    );
  }

  CartesianSeries<_P, DateTime> _area(List<_P> series, ChartStyle style, {bool gradient = false}) {
    return AreaSeries<_P, DateTime>(
      dataSource: series,
      xValueMapper: (p, _) => p.date,
      yValueMapper: (p, _) => p.value,
      color: style.primaryColor.withValues(alpha: style.gradientOpacity),
      borderColor: style.primaryColor,
      borderWidth: style.strokeWidth,
      gradient: gradient
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                style.primaryColor.withValues(alpha: 0.35),
                style.primaryColor.withValues(alpha: 0),
              ],
            )
          : null,
    );
  }

  Widget _cartesian(
    ChartStyle style,
    List<CartesianSeries> series, {
    bool compact = false,
    double? minimum,
    double? maximum,
  }) {
    return SizedBox(
      height: compact ? 60 : 180,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        primaryXAxis: DateTimeAxis(isVisible: !compact, majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(
          isVisible: !compact,
          minimum: minimum,
          maximum: maximum,
          majorGridLines: MajorGridLines(width: style.showGrid ? 0.5 : 0),
        ),
        plotAreaBorderWidth: 0,
        tooltipBehavior: compact ? null : TooltipBehavior(enable: true),
        series: series,
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
