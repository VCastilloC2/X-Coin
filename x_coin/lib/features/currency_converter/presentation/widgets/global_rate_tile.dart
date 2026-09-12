import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/currency_flag.dart';

/// Fila de la lista "Tasas Globales": banderas del par a la
/// izquierda, valor de la tasa a la derecha
/// (p. ej. "🇪🇺🇬🇧 EUR/GBP · 0.92 EUR").
class GlobalRateTile extends StatelessWidget {
  const GlobalRateTile({
    super.key,
    required this.baseIso,
    required this.quoteIso,
    required this.valueLabel,
  });

  final String baseIso;
  final String quoteIso;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          CurrencyFlag(isoCurrency: baseIso, size: 20),
          const SizedBox(width: 4),
          CurrencyFlag(isoCurrency: quoteIso, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text('$baseIso/$quoteIso', style: AppTypography.body),
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
