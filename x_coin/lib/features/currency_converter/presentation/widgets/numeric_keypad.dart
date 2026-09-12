import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Teclado numérico en grilla 4x4, igual al del mockup: dígitos 1-9,
/// '.', 0, borrar (⌫) y una columna de operadores a la derecha
/// (aquí usada como acciones +/-/⌫ sobre el monto).
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({super.key, required this.onKeyTap});

  /// Recibe '0'-'9', '.' o 'back'.
  final ValueChanged<String> onKeyTap;

  static const _layout = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['0', '.', 'back'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _layout
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: row
                    .map((key) => Expanded(child: _KeypadButton(
                          keyLabel: key,
                          onTap: () => onKeyTap(key),
                        )))
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.keyLabel, required this.onTap});

  final String keyLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBack = keyLabel == 'back';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: AppColors.keypadButton,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          onTap: onTap,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: isBack
                ? const Icon(Icons.backspace_outlined,
                    size: 20, color: AppColors.textPrimary)
                : Text(keyLabel, style: AppTypography.keypadDigit),
          ),
        ),
      ),
    );
  }
}
