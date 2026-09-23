import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../../domain/chart_engine/chart_style.dart';
import '../../domain/math/rate_series_math.dart';
import '../widgets/candle_painter_view.dart';
import '../widgets/heatmap_calendar_view.dart';
import 'chart_strategy.dart';

class _P {
  const _P(this.date, this.value);
  final DateTime date;
  final double value;
}

charts.Color _toChartsColor(Color color) => charts.Color(
      r: (color.r * 255).round(),
      g: (color.g * 255).round(),
      b: (color.b * 255).round(),
    );

/// Implementación con `community_charts_flutter`, el fork mantenido
/// por la comunidad que continúa la API pública de `charts_flutter`
/// (el paquete que Google publicaba como "Google Charts" para
/// Flutter, descontinuado desde 2020). No incluye velas/OHLC
/// nativas, así que esas 3 variantes reutilizan el mismo
/// `CustomPaint` que la estrategia de `fl_chart`.
class CommunityChartsStrategy implements ChartStrategy {
  @override
  ChartLibrary get library => ChartLibrary.communityCharts;

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
      case ChartType.candlestick:
      case ChartType.ohlcBar:
      case ChartType.candleVolumeCombo:
        return CandlePainterView(
          candles: RateSeriesMath.toCandles(points),
          showVolume: config.type == ChartType.candleVolumeCombo,
        );

      case ChartType.heatmapCalendar:
        return HeatmapCalendarView(points: points, style: style);

      case ChartType.barVertical:
      case ChartType.barHorizontal:
      case ChartType.barGroupedWeekly:
      case ChartType.barStackedMinMax:
      case ChartType.barRounded:
      case ChartType.columnRangeHiLo:
        return _bar(series, style, vertical: config.type != ChartType.barHorizontal);

      case ChartType.scatterCorrelation:
        return _scatter(series, style);

      case ChartType.donutLatestShare:
        return _pie(points, style);

      case ChartType.bollingerBands:
      case ChartType.volatilityStdDevBands:
      case ChartType.rangeAreaBollingerFill:
        return _bollinger(points, style);

      case ChartType.multiCurrencyComparison:
        final ma = RateSeriesMath.movingAverage(points, 30);
        return _timeSeries([
          series,
          [for (var i = 0; i < ma.length; i++) _P(points[i].date, ma[i])],
        ], style, fill: [false, false]);

      case ChartType.lineMovingAverage:
        final ma = RateSeriesMath.movingAverage(points, 7);
        return _timeSeries([
          series,
          [for (var i = 0; i < ma.length; i++) _P(points[i].date, ma[i])],
        ], style, fill: [false, false]);

      case ChartType.linePercentChange:
        final pct = RateSeriesMath.percentChange(points);
        return _timeSeries([
          [for (var i = 0; i < pct.length; i++) _P(points[i].date, pct[i])],
        ], style, fill: [false]);

      case ChartType.cumulativeReturnArea:
        final pct = RateSeriesMath.percentChange(points);
        return _timeSeries([
          [for (var i = 0; i < pct.length; i++) _P(points[i].date, pct[i])],
        ], style, fill: [true]);

      case ChartType.drawdownArea:
        final dd = RateSeriesMath.drawdown(points);
        return _timeSeries([
          [for (var i = 0; i < dd.length; i++) _P(points[i].date, dd[i])],
        ], style, fill: [true]);

      case ChartType.rsiOscillator:
        final rsi = RateSeriesMath.rsi(points);
        return _timeSeries([
          [for (var i = 0; i < rsi.length; i++) _P(points[i].date, rsi[i])],
        ], style, fill: [false]);

      case ChartType.dualAxisLineBar:
        // `community_charts_flutter` no soporta series mixtas
        // línea+barra en un mismo `TimeSeriesChart` de forma directa;
        // se resuelve como línea sobre barras de volumen apiladas en
        // dos charts sincronizados verticalmente.
        final volume = RateSeriesMath.syntheticVolume(points);
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: _bar(
                  [for (var i = 0; i < volume.length; i++) _P(points[i + 1].date, volume[i])],
                  style,
                  vertical: true,
                ),
              ),
              Expanded(child: _timeSeries([series], style, fill: [false])),
            ],
          ),
        );

      // Familia línea/área: lineSimple, lineSpline, lineStepped,
      // lineDashedTrend, lineWithMarkers, sparkline, areaSimple,
      // areaGradient, areaSpline, areaStep.
      default:
        final isArea = config.type.name.startsWith('area');
        return _timeSeries([series], style, fill: [isArea]);
    }
  }

  Widget _timeSeries(List<List<_P>> allSeries, ChartStyle style, {required List<bool> fill}) {
    final colors = [style.primaryColor, style.secondaryColor];
    return SizedBox(
      height: 180,
      child: charts.TimeSeriesChart(
        [
          for (var i = 0; i < allSeries.length; i++)
            charts.Series<_P, DateTime>(
              id: 'serie_$i',
              colorFn: (_, __) => _toChartsColor(colors[i % colors.length]),
              domainFn: (p, _) => p.date,
              measureFn: (p, _) => p.value,
              data: allSeries[i],
            )..setAttribute(charts.rendererIdKey, fill[i] ? 'area' : 'line'),
        ],
        animate: false,
        defaultRenderer: charts.LineRendererConfig<DateTime>(includeArea: false),
        customSeriesRenderers: [
          charts.LineRendererConfig<DateTime>(
            customRendererId: 'area',
            includeArea: true,
            areaOpacity: style.gradientOpacity,
            strokeWidthPx: style.strokeWidth,
          ),
          charts.LineRendererConfig<DateTime>(
            customRendererId: 'line',
            strokeWidthPx: style.strokeWidth,
          ),
        ],
      ),
    );
  }

  Widget _bar(List<_P> series, ChartStyle style, {required bool vertical}) {
    return SizedBox(
      height: 180,
      child: charts.BarChart(
        [
          charts.Series<_P, String>(
            id: 'valores',
            colorFn: (_, __) => _toChartsColor(style.primaryColor),
            domainFn: (p, _) => '${p.date.day}/${p.date.month}',
            measureFn: (p, _) => p.value,
            data: series,
          ),
        ],
        animate: false,
        vertical: vertical,
        barGroupingType: charts.BarGroupingType.stacked,
      ),
    );
  }

  Widget _scatter(List<_P> series, ChartStyle style) {
    return SizedBox(
      height: 180,
      child: charts.ScatterPlotChart(
        [
          charts.Series<_P, num>(
            id: 'dispersión',
            colorFn: (_, __) => _toChartsColor(style.primaryColor),
            domainFn: (p, _) => p.date.millisecondsSinceEpoch.toDouble(),
            measureFn: (p, _) => p.value,
            data: series,
          ),
        ],
        animate: false,
      ),
    );
  }

  Widget _pie(List<RatePoint> points, ChartStyle style) {
    final values = points.map((p) => p.value);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final progress = maxV == minV ? 0.5 : (points.last.value - minV) / (maxV - minV);
    final data = [
      _Slice('Actual', progress * 100, style.primaryColor),
      _Slice('Rango', (1 - progress) * 100, AppColors.surfaceMuted),
    ];
    return SizedBox(
      height: 180,
      child: charts.PieChart<String>(
        [
          charts.Series<_Slice, String>(
            id: 'dona',
            colorFn: (s, _) => _toChartsColor(s.color),
            domainFn: (s, _) => s.label,
            measureFn: (s, _) => s.value,
            data: data,
          ),
        ],
        animate: false,
        defaultRenderer: charts.ArcRendererConfig(arcWidth: 28),
      ),
    );
  }

  Widget _bollinger(List<RatePoint> points, ChartStyle style) {
    final bands = RateSeriesMath.bollingerBands(points);
    final upper = [for (var i = 0; i < bands.upper.length; i++) _P(points[i].date, bands.upper[i])];
    final lower = [for (var i = 0; i < bands.lower.length; i++) _P(points[i].date, bands.lower[i])];
    final raw = points.map((p) => _P(p.date, p.value)).toList();
    return SizedBox(
      height: 180,
      child: charts.TimeSeriesChart(
        [
          charts.Series<_P, DateTime>(
            id: 'superior',
            colorFn: (_, __) => _toChartsColor(style.secondaryColor.withValues(alpha: 0.6)),
            domainFn: (p, _) => p.date,
            measureFn: (p, _) => p.value,
            data: upper,
          ),
          charts.Series<_P, DateTime>(
            id: 'inferior',
            colorFn: (_, __) => _toChartsColor(style.secondaryColor.withValues(alpha: 0.6)),
            domainFn: (p, _) => p.date,
            measureFn: (p, _) => p.value,
            data: lower,
          ),
          charts.Series<_P, DateTime>(
            id: 'valor',
            colorFn: (_, __) => _toChartsColor(style.primaryColor),
            domainFn: (p, _) => p.date,
            measureFn: (p, _) => p.value,
            data: raw,
          ),
        ],
        animate: false,
      ),
    );
  }
}

class _Slice {
  const _Slice(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 140,
        child: Center(child: Text('Sin datos suficientes para graficar')),
      );
}
