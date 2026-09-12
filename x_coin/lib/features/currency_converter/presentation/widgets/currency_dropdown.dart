import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/currency.dart';

/// Selector desplegable de moneda: bandera + código ISO + chevron,
/// reproduciendo los campos "USD ⌄" / "EUR ⌄" de "Moneda de Origen"
/// y "Moneda de Destino" en el mockup.
class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    super.key,
    required this.label,
    required this.currencies,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<Currency> currencies;
  final Currency? selected;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: selected,
              isDense: true,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary),
              items: currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c.flagEmoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(c.isoCode, style: AppTypography.bodyStrong),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
