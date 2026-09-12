import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/exchange_rate.dart';

/// Gráfica de línea con relleno degradado que muestra "cómo cambia
/// el valor de una moneda con respecto a otra a lo largo del tiempo",
/// tal como en la sección "Tasa Actual" del mockup 1.
class RateLineChart extends StatelessWidget {
  const RateLineChart({super.key, required this.points});

  final List<RatePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('Sin datos históricos disponibles')),
      );
    }

    final spots = [
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].value),
    ];
    final values = points.map((p) => p.value);
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.995;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.005;

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.primaryNavy,
              getTooltipItems: (spots) => spots
                  .map(
                    (s) => LineTooltipItem(
                      s.y.toStringAsFixed(4),
                      const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2.5,
              color: AppColors.chartLine,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.chartFillTop, AppColors.chartFillBottom],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
