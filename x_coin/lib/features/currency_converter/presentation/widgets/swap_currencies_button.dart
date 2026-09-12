import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Botón circular con ícono de intercambio (⇄), ubicado entre los
/// dos dropdowns de moneda tal como en el mockup.
class SwapCurrenciesButton extends StatelessWidget {
  const SwapCurrenciesButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.swap_horiz_rounded,
            color: AppColors.primaryNavy,
            size: 20,
          ),
        ),
      ),
    );
  }
}
