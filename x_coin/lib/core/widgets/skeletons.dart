import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Bloque con efecto shimmer (barrido de brillo) usado como
/// placeholder mientras se cargan datos remotos de Frankfurter API.
///
/// Implementado sin dependencias externas: anima un [ShaderMask] con
/// gradiente desplazado sobre un contenedor sólido, evitando sumar
/// otro paquete solo para un efecto visual.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final highlight = isDark ? const Color(0xFF2B2F58) : const Color(0xFFF7F8FC);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
            begin: Alignment(-1 - _controller.value * 2, 0),
            end: Alignment(1 - _controller.value * 2, 0),
          ).createShader(bounds),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Placeholder de carga para la pantalla "Inicio" mientras se obtiene
/// el catálogo de monedas: reproduce la silueta de los dropdowns, el
/// monto, el teclado y las monedas favoritas.
class ConverterSkeleton extends StatelessWidget {
  const ConverterSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 240, height: 22),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              Expanded(child: ShimmerBox(height: 52, borderRadius: 26)),
              SizedBox(width: AppSpacing.sm),
              ShimmerBox(width: 36, height: 36, borderRadius: 18),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: ShimmerBox(height: 52, borderRadius: 26)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(width: 140, height: 13),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(height: 64, borderRadius: AppSpacing.radiusMd),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: const [
                  Expanded(child: ShimmerBox(height: 52, borderRadius: AppSpacing.radiusSm)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 52, borderRadius: AppSpacing.radiusSm)),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerBox(height: 52, borderRadius: AppSpacing.radiusSm)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(height: 52, borderRadius: AppSpacing.radiusMd),
        ],
      ),
    );
  }
}

/// Placeholder de carga para la pantalla "Historial": tasa actual,
/// gráfica y ranking de tasas globales.
class RatesSkeleton extends StatelessWidget {
  const RatesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 100, height: 13),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 180, height: 28),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(height: 180, borderRadius: AppSpacing.radiusMd),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(width: 140, height: 13),
          const SizedBox(height: AppSpacing.sm),
          for (var i = 0; i < 4; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: ShimmerBox(height: 40, borderRadius: AppSpacing.radiusSm),
            ),
        ],
      ),
    );
  }
}
