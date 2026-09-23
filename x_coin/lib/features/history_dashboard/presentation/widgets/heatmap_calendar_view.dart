import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_style.dart';
import '../../domain/math/rate_series_math.dart';

/// Mapa de calor tipo "calendario de contribuciones": ninguna de las
/// 4 librerías del catálogo trae un heatmap nativo, así que se
/// resuelve con un `GridView` compartido, coloreado según el
/// [ChartStyle] de cada estrategia para conservar identidad propia
/// por combinación (librería × gráfica) sin duplicar la lógica 4
/// veces.
class HeatmapCalendarView extends StatelessWidget {
  const HeatmapCalendarView({super.key, required this.points, required this.style});

  final List<RatePoint> points;
  final ChartStyle style;

  @override
  Widget build(BuildContext context) {
    final changes = RateSeriesMath.percentChange(points);
    if (changes.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('Sin datos suficientes para graficar')),
      );
    }
    final columns = (changes.length / 7).ceil().clamp(1, 999);
    return SizedBox(
      height: 180,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: changes.length,
        itemBuilder: (context, i) {
          final intensity = (changes[i].abs() / 5).clamp(0.12, 1.0);
          final color = changes[i] >= 0 ? AppColors.success : AppColors.danger;
          return Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: intensity),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        },
      ),
    );
  }
}
