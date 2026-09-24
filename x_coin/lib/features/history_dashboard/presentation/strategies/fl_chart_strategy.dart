import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../../domain/chart_engine/chart_style.dart';
import '../../domain/math/rate_series_math.dart';
import '../widgets/candle_painter_view.dart';
import '../widgets/heatmap_calendar_view.dart';
import 'chart_strategy.dart';

/// Implementación con `fl_chart`.
///
/// `fl_chart` no tiene un `CandlestickChart` nativo, así que las 3
/// variantes de vela/OHLC se dibujan con un `CustomPainter` ligero
/// sobre el mismo sistema de coordenadas que usa el resto de la app.
/// Esto se documenta aquí en vez de simular un soporte que no existe.
class FlChartStrategy implements ChartStrategy {
  @override
  ChartLibrary get library => ChartLibrary.flChart;

  @override
  bool supports(ChartType type) => true;

  @override
  Widget build({
    required BuildContext context,
    required ChartConfig config,
    required List<RatePoint> points,
  }) {
    if (points.length < 2) return const _EmptySeries();
    final style = config.style;

    switch (config.type) {
      case ChartType.lineSimple:
      case ChartType.lineSpline:
      case ChartType.lineStepped:
      case ChartType.lineDashedTrend:
      case ChartType.lineWithMarkers:
      case ChartType.areaSimple:
      case ChartType.areaGradient:
      case ChartType.areaSpline:
      case ChartType.areaStep:
      case ChartType.sparkline:
        return _lineFamily(points, style, config.type);

      case ChartType.lineMovingAverage:
        return _movingAverageOverlay(points, style);

      case ChartType.linePercentChange:
        return _seriesLine(RateSeriesMath.percentChange(points), style,
            suffix: '%');

      case ChartType.cumulativeReturnArea:
        return _seriesLine(RateSeriesMath.percentChange(points), style,
            suffix: '%', filled: true);

      case ChartType.drawdownArea:
        return _seriesLine(RateSeriesMath.drawdown(points), style,
            suffix: '%', filled: true, negative: true);

      case ChartType.rsiOscillator:
        return _seriesLine(RateSeriesMath.rsi(points), style,
            minY: 0, maxY: 100);

      case ChartType.barVertical:
      case ChartType.barHorizontal:
      case ChartType.barGroupedWeekly:
      case ChartType.barStackedMinMax:
      case ChartType.barRounded:
      case ChartType.columnRangeHiLo:
        return _barFamily(points, style, config.type);

      case ChartType.dualAxisLineBar:
        return _dualAxis(points, style);

      case ChartType.donutLatestShare:
        return _donut(points, style);

      case ChartType.scatterCorrelation:
        return _scatter(points, style);

      case ChartType.bollingerBands:
      case ChartType.volatilityStdDevBands:
      case ChartType.rangeAreaBollingerFill:
        return _bollinger(points, style);

      case ChartType.multiCurrencyComparison:
        return _comparison(points, style);

      case ChartType.heatmapCalendar:
        return HeatmapCalendarView(points: points, style: style);

      case ChartType.candlestick:
      case ChartType.ohlcBar:
      case ChartType.candleVolumeCombo:
        return CandlePainterView(
          candles: RateSeriesMath.toCandles(points),
          showVolume: config.type == ChartType.candleVolumeCombo,
        );
    }
  }

  // ---- helpers -----------------------------------------------------

  Widget _lineFamily(List<RatePoint> points, ChartStyle style, ChartType type) {
    final isArea = type.name.startsWith('area');
    final isStepped = type == ChartType.lineStepped || type == ChartType.areaStep;
    final showDots = type == ChartType.lineWithMarkers || style.showDots;
    final height = type == ChartType.sparkline ? 60.0 : 180.0;

    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];
    final values = points.map((p) => p.value);
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.995;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.005;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(show: style.showGrid && type != ChartType.sparkline),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: type != ChartType.sparkline),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: type == ChartType.lineSpline || (style.isCurved && !isStepped),
              isStepLineChart: isStepped,
              barWidth: style.strokeWidth,
              color: style.primaryColor,
              dashArray: type == ChartType.lineDashedTrend ? [6, 4] : null,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: isArea,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    style.primaryColor.withValues(alpha: style.gradientOpacity),
                    style.primaryColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seriesLine(
    List<double> series,
    ChartStyle style, {
    String suffix = '',
    bool filled = false,
    bool negative = false,
    double? minY,
    double? maxY,
  }) {
    if (series.isEmpty) return const _EmptySeries();
    final spots = [for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i])];
    final values = series;
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: minY ?? values.reduce((a, b) => a < b ? a : b) * (negative ? 1.05 : 0.95),
          maxY: maxY ?? values.reduce((a, b) => a > b ? a : b) * (negative ? 0.95 : 1.05),
          gridData: FlGridData(show: style.showGrid),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.primaryNavy,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        '${CurrencyFormatter.amount(s.y)}$suffix',
                        const TextStyle(color: AppColors.textOnPrimary),
                      ))
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: style.isCurved,
              barWidth: style.strokeWidth,
              color: negative ? AppColors.danger : style.primaryColor,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: filled,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (negative ? AppColors.danger : style.primaryColor)
                        .withValues(alpha: style.gradientOpacity),
                    (negative ? AppColors.danger : style.primaryColor).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _movingAverageOverlay(List<RatePoint> points, ChartStyle style) {
    final ma = RateSeriesMath.movingAverage(points, 7);
    final raw = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value)];
    final avg = [for (var i = 0; i < ma.length; i++) FlSpot(i.toDouble(), ma[i])];
    final all = points.map((p) => p.value).followedBy(ma);
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: all.reduce((a, b) => a < b ? a : b) * 0.995,
          maxY: all.reduce((a, b) => a > b ? a : b) * 1.005,
          gridData: FlGridData(show: style.showGrid),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: raw,
              color: style.primaryColor.withValues(alpha: 0.45),
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: avg,
              color: style.secondaryColor,
              barWidth: style.strokeWidth,
              isCurved: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barFamily(List<RatePoint> points, ChartStyle style, ChartType type) {
    final sample = points.length > 20
        ? [
            for (var i = 0; i < points.length; i += (points.length / 20).ceil())
              points[i],
          ]
        : points;
    final values = sample.map((p) => p.value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final isRange = type == ChartType.columnRangeHiLo || type == ChartType.barStackedMinMax;
    final radius = type == ChartType.barRounded
        ? const BorderRadius.vertical(top: Radius.circular(6))
        : BorderRadius.zero;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: style.showGrid),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  fromY: isRange ? minV * 0.995 : 0,
                  toY: values[i],
                  color: style.primaryColor,
                  width: type == ChartType.barHorizontal ? 6 : 10,
                  borderRadius: radius,
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _dualAxis(List<RatePoint> points, ChartStyle style) {
    final volume = RateSeriesMath.syntheticVolume(points);
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < volume.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: volume[i],
                      color: style.secondaryColor.withValues(alpha: 0.35),
                      width: 4,
                    ),
                  ]),
              ],
            ),
          ),
          _lineFamily(points, style, ChartType.lineSimple),
        ],
      ),
    );
  }

  Widget _donut(List<RatePoint> points, ChartStyle style) {
    final values = points.map((p) => p.value);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final latest = points.last.value;
    final progress = maxV == minV ? 0.5 : (latest - minV) / (maxV - minV);
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          sections: [
            PieChartSectionData(
              value: progress * 100,
              color: style.primaryColor,
              showTitle: false,
              radius: 22,
            ),
            PieChartSectionData(
              value: (1 - progress) * 100,
              color: AppColors.surfaceMuted,
              showTitle: false,
              radius: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scatter(List<RatePoint> points, ChartStyle style) {
    final ma = RateSeriesMath.movingAverage(points, 7);
    return SizedBox(
      height: 180,
      child: ScatterChart(
        ScatterChartData(
          gridData: FlGridData(show: style.showGrid),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          scatterSpots: [
            for (var i = 0; i < points.length; i++)
              ScatterSpot(
                ma[i],
                points[i].value,
                dotPainter: FlDotCirclePainter(color: style.primaryColor, radius: 3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bollinger(List<RatePoint> points, ChartStyle style) {
    final bands = RateSeriesMath.bollingerBands(points);
    final allValues = [...bands.upper, ...bands.lower, ...points.map((p) => p.value)];
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: allValues.reduce((a, b) => a < b ? a : b) * 0.995,
          maxY: allValues.reduce((a, b) => a > b ? a : b) * 1.005,
          gridData: FlGridData(show: style.showGrid),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value)],
              color: style.primaryColor,
              barWidth: style.strokeWidth,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: [for (var i = 0; i < bands.upper.length; i++) FlSpot(i.toDouble(), bands.upper[i])],
              color: style.secondaryColor.withValues(alpha: 0.7),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: style.secondaryColor.withValues(alpha: 0.08),
              ),
            ),
            LineChartBarData(
              spots: [for (var i = 0; i < bands.lower.length; i++) FlSpot(i.toDouble(), bands.lower[i])],
              color: style.secondaryColor.withValues(alpha: 0.7),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  /// Sin una segunda divisa ya cargada en memoria (evitando así un
  /// segundo round-trip HTTP), la "comparativa multi-divisa" se
  /// resuelve como serie vs. su propia media móvil de 30 periodos,
  /// que cumple el mismo propósito visual (referencia vs. actual).
  Widget _comparison(List<RatePoint> points, ChartStyle style) =>
      _movingAverageOverlay(points, style);

}

class _EmptySeries extends StatelessWidget {
  const _EmptySeries();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 140,
        child: Center(child: Text('Sin datos suficientes para graficar')),
      );
}

