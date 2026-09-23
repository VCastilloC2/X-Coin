import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Parámetros visuales que el motor de configuración modula por
/// combinación (librería × tipo de gráfica) para que cada una de
/// las 128 variantes tenga identidad propia sin definir 128 clases.
@immutable
class ChartStyle {
  const ChartStyle({
    required this.primaryColor,
    required this.secondaryColor,
    required this.strokeWidth,
    required this.isCurved,
    required this.showGrid,
    required this.showDots,
    required this.gradientOpacity,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final double strokeWidth;
  final bool isCurved;
  final bool showGrid;
  final bool showDots;
  final double gradientOpacity;

  /// Paleta base rotada de forma determinística por índice, para que
  /// el catálogo completo tenga variedad visual sin configuración
  /// manual por gráfica.
  static const List<Color> _palette = [
    AppColors.chartLine,
    AppColors.primaryBlue,
    AppColors.success,
    AppColors.danger,
    AppColors.keypadOperator,
  ];

  /// Genera un estilo determinístico a partir de un índice (posición
  /// en el catálogo de 128). Es la pieza clave del "motor de
  /// configuración": en vez de codificar color/curva/grosor por
  /// gráfica, se derivan matemáticamente del índice.
  factory ChartStyle.fromSeed(int seed) {
    final primary = _palette[seed % _palette.length];
    final secondary = _palette[(seed + 2) % _palette.length];
    return ChartStyle(
      primaryColor: primary,
      secondaryColor: secondary,
      strokeWidth: 2.0 + (seed % 3) * 0.5,
      isCurved: seed % 2 == 0,
      showGrid: seed % 4 != 0,
      showDots: seed % 5 == 0,
      gradientOpacity: 0.18 + (seed % 3) * 0.08,
    );
  }
}
