import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/math/rate_series_math.dart';

/// Vela japonesa / OHLC dibujada a mano: `fl_chart` no ofrece un
/// `CandlestickChart` nativo, así que se usa `CustomPaint` sobre las
/// mismas proporciones de layout que el resto del módulo.
class CandlePainterView extends StatelessWidget {
  const CandlePainterView({required this.candles, this.showVolume = false});

  final List<SyntheticCandle> candles;
  final bool showVolume;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) return const SizedBox(height: 140, child: Center(child: Text("Sin datos suficientes para graficar")));
    return SizedBox(
      height: showVolume ? 220 : 180,
      child: CustomPaint(
        painter: CandlePainter(candles: candles, showVolume: showVolume),
        size: Size.infinite,
      ),
    );
  }
}

class CandlePainter extends CustomPainter {
  CandlePainter({required this.candles, required this.showVolume});

  final List<SyntheticCandle> candles;
  final bool showVolume;

  @override
  void paint(Canvas canvas, Size size) {
    final highs = candles.map((c) => c.high);
    final lows = candles.map((c) => c.low);
    final maxV = highs.reduce((a, b) => a > b ? a : b);
    final minV = lows.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).clamp(0.0001, double.infinity);
    final chartHeight = showVolume ? size.height * 0.72 : size.height;
    final slotWidth = size.width / candles.length;
    final bodyWidth = (slotWidth * 0.6).clamp(2.0, 14.0);

    double yFor(double value) =>
        chartHeight - ((value - minV) / range) * chartHeight;

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];
      final cx = slotWidth * i + slotWidth / 2;
      final color = c.isBullish ? AppColors.success : AppColors.danger;
      final wickPaint = Paint()..color = color..strokeWidth = 1.2;
      final bodyPaint = Paint()..color = color;

      canvas.drawLine(Offset(cx, yFor(c.high)), Offset(cx, yFor(c.low)), wickPaint);
      final top = yFor(c.isBullish ? c.close : c.open);
      final bottom = yFor(c.isBullish ? c.open : c.close);
      canvas.drawRect(
        Rect.fromLTRB(cx - bodyWidth / 2, top, cx + bodyWidth / 2, bottom.clamp(top + 1, chartHeight)),
        bodyPaint,
      );
    }

    if (showVolume) {
      final volumePaint = Paint()..color = AppColors.primaryBlue.withValues(alpha: 0.35);
      final volHeight = size.height - (chartHeight + 8);
      final maxRange = candles.map((c) => c.high - c.low).reduce((a, b) => a > b ? a : b).clamp(0.0001, double.infinity);
      for (var i = 0; i < candles.length; i++) {
        final cx = slotWidth * i + slotWidth / 2;
        final magnitude = (candles[i].high - candles[i].low) / maxRange;
        final barHeight = volHeight * magnitude;
        canvas.drawRect(
          Rect.fromLTWH(cx - bodyWidth / 2, size.height - barHeight, bodyWidth, barHeight),
          volumePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CandlePainter oldDelegate) =>
      oldDelegate.candles != candles || oldDelegate.showVolume != showVolume;
}
