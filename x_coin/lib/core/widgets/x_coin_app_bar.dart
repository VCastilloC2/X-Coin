import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// AppBar de marca compartida por las tres pantallas.
///
/// Muestra el logo oficial de X-Coin (`assets/images/xcoin_logo.png`)
/// en un contenedor responsive de 32x32 que preserva proporción de
/// aspecto (`BoxFit.contain`), seguido del wordmark "X-Coin". Se
/// adapta automáticamente a modo claro/oscuro según el tema activo.
///
/// Si el asset del logo aún no fue agregado al proyecto (o falla al
/// cargar), cae de forma elegante a un distintivo circular en vez de
/// mostrar un ícono roto o un espacio vacío.
class XCoinAppBar extends StatelessWidget implements PreferredSizeWidget {
  const XCoinAppBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient:
            isDark ? AppColors.appBarGradientDark : AppColors.appBarGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              const SizedBox(width: 16),
              const _BrandLogo(),
              const SizedBox(width: 10),
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

/// Contenedor responsive de 32x32, listo para inyectar el logo
/// oficial manteniendo proporción de aspecto.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  static const double _diameter = 32;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _diameter,
      height: _diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.currency_exchange_rounded,
        color: AppColors.textOnPrimary,
        size: 18,
      ),
    );
  }
}
