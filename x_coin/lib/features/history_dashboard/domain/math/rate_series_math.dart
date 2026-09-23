import 'dart:math' as math;
import '../../../currency_converter/domain/entities/exchange_rate.dart';

/// Vela sintetizada a partir de dos tasas diarias consecutivas.
///
/// Frankfurter solo expone UNA tasa por día (no OHLC real). Para las
/// gráficas de velas/OHLC se sintetiza: `open` = cierre del día
/// anterior, `close` = tasa del día, y `high`/`low` se derivan de un
/// rango de volatilidad proporcional al cambio diario. Esto se deja
/// explícito en el modelo (campo `synthetic`) para no presentar datos
/// derivados como si fueran datos crudos del API.
class SyntheticCandle {
  const SyntheticCandle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.synthetic = true,
  });

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final bool synthetic;

  bool get isBullish => close >= open;
}

class RateSeriesMath {
  RateSeriesMath._();

  static List<SyntheticCandle> toCandles(List<RatePoint> points) {
    if (points.length < 2) return const [];
    final candles = <SyntheticCandle>[];
    for (var i = 1; i < points.length; i++) {
      final open = points[i - 1].value;
      final close = points[i].value;
      final volatility = (close - open).abs() * 0.6 + (open * 0.0005);
      candles.add(
        SyntheticCandle(
          date: points[i].date,
          open: open,
          close: close,
          high: math.max(open, close) + volatility,
          low: math.min(open, close) - volatility,
        ),
      );
    }
    return candles;
  }

  static List<double> movingAverage(List<RatePoint> points, int window) {
    final result = <double>[];
    for (var i = 0; i < points.length; i++) {
      final start = math.max(0, i - window + 1);
      final slice = points.sublist(start, i + 1).map((p) => p.value);
      result.add(slice.reduce((a, b) => a + b) / slice.length);
    }
    return result;
  }

  static double _stdDev(Iterable<double> values, double mean) {
    if (values.length < 2) return 0;
    final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        (values.length - 1);
    return math.sqrt(variance);
  }

  /// Bandas de Bollinger: media móvil ± 2 desviaciones estándar sobre
  /// una ventana (por defecto 20, recortada a la longitud disponible).
  static ({List<double> mid, List<double> upper, List<double> lower})
      bollingerBands(List<RatePoint> points, {int window = 20}) {
    final effectiveWindow = math.min(window, points.length);
    final mid = <double>[];
    final upper = <double>[];
    final lower = <double>[];
    for (var i = 0; i < points.length; i++) {
      final start = math.max(0, i - effectiveWindow + 1);
      final slice = points.sublist(start, i + 1).map((p) => p.value).toList();
      final mean = slice.reduce((a, b) => a + b) / slice.length;
      final sd = _stdDev(slice, mean);
      mid.add(mean);
      upper.add(mean + 2 * sd);
      lower.add(mean - 2 * sd);
    }
    return (mid: mid, upper: upper, lower: lower);
  }

  /// RSI (Relative Strength Index) clásico de 14 periodos.
  static List<double> rsi(List<RatePoint> points, {int period = 14}) {
    if (points.length < period + 1) {
      return List.filled(points.length, 50);
    }
    final result = List<double>.filled(points.length, 50);
    var avgGain = 0.0;
    var avgLoss = 0.0;
    for (var i = 1; i <= period; i++) {
      final change = points[i].value - points[i - 1].value;
      if (change >= 0) {
        avgGain += change;
      } else {
        avgLoss -= change;
      }
    }
    avgGain /= period;
    avgLoss /= period;
    for (var i = period + 1; i < points.length; i++) {
      final change = points[i].value - points[i - 1].value;
      final gain = change > 0 ? change : 0.0;
      final loss = change < 0 ? -change : 0.0;
      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;
      final rs = avgLoss == 0 ? 100.0 : avgGain / avgLoss;
      result[i] = avgLoss == 0 ? 100 : 100 - (100 / (1 + rs));
    }
    return result;
  }

  static List<double> percentChange(List<RatePoint> points) {
    if (points.isEmpty) return const [];
    final base = points.first.value;
    return points.map((p) => ((p.value - base) / base) * 100).toList();
  }

  static List<double> drawdown(List<RatePoint> points) {
    var peak = double.negativeInfinity;
    final result = <double>[];
    for (final p in points) {
      peak = math.max(peak, p.value);
      result.add(((p.value - peak) / peak) * 100);
    }
    return result;
  }

  /// Volumen sintético (no provisto por Frankfurter): proporcional a
  /// la variación absoluta diaria, normalizado a un rango legible.
  static List<double> syntheticVolume(List<RatePoint> points) {
    if (points.length < 2) return const [];
    final deltas = <double>[
      for (var i = 1; i < points.length; i++)
        (points[i].value - points[i - 1].value).abs(),
    ];
    final maxDelta = deltas.isEmpty
        ? 1.0
        : deltas.reduce((a, b) => a > b ? a : b).clamp(0.0001, double.infinity);
    return deltas.map((d) => (d / maxDelta) * 100).toList();
  }
}
