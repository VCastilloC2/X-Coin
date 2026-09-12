import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/rates_provider.dart';

/// Fila de botones de rango temporal para la gráfica de tasas
/// ("7 Días", "1W", "1Y", "2Y" en el mockup 1).
class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RateRange selected;
  final ValueChanged<RateRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RateRange.values
          .map(
            (range) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _RangeChip(
                label: range.label,
                selected: range == selected,
                onTap: () => onSelected(range),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryNavy : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
