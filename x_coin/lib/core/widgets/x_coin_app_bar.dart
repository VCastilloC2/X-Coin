import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// AppBar de marca compartida por las tres pantallas.
///
/// Reproduce la cabecera de los mockups: fondo azul marino en
/// degradado, ícono "X" y wordmark "X-Coin". Es un [PreferredSizeWidget]
/// para poder usarse directamente en `Scaffold.appBar`.
class XCoinAppBar extends StatelessWidget implements PreferredSizeWidget {
  const XCoinAppBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              const SizedBox(width: 20),
              _BrandIcon(),
              const SizedBox(width: 8),
              const Text(AppStrings.appName, style: AppTypography.brandTitle),
              const Spacer(),
              if (actions != null) ...actions!,
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Ícono de marca "X" dentro de un contenedor circular translúcido,
/// tal como aparece junto al wordmark en ambos mockups.
class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, color: AppColors.textOnPrimary, size: 16),
    );
  }
}
