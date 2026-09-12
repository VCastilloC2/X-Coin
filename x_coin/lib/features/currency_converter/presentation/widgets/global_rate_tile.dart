import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Fila de la lista "Tasas Globales": bandera + par de monedas a la
/// izquierda, valor de la tasa a la derecha (p. ej. "EUR/GBP · 0.92 EUR").
class GlobalRateTile extends StatelessWidget {
  const GlobalRateTile({
    super.key,
    required this.flagEmoji,
    required this.pairLabel,
    required this.valueLabel,
  });

  final String flagEmoji;
  final String pairLabel;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(flagEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Text(pairLabel, style: AppTypography.body),
          const Spacer(),
          Text(
            valueLabel,
            style: AppTypography.bodyStrong.copyWith(color: AppColors.primaryNavy),
          ),
        ],
      ),
    );
  }
}
