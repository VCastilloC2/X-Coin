import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/currency_flag.dart';
import '../../domain/entities/currency.dart';

/// Ítem de la grilla "Monedas Favoritas": bandera + código ISO sobre
/// una píldora gris clara, tal como aparece en el mockup 1.
class FavoriteCurrencyChip extends StatelessWidget {
  const FavoriteCurrencyChip({
    super.key,
    required this.currency,
    required this.onTap,
  });

  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurrencyFlag(isoCurrency: currency.isoCode, size: 20),
              const SizedBox(width: 8),
              Text(currency.isoCode, style: AppTypography.bodyStrong),
            ],
          ),
        ),
      ),
    );
  }
}
