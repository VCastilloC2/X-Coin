import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Vista de carga/error reutilizable para cualquier pantalla que
/// consuma la API: spinner mientras carga y un mensaje con botón de
/// reintento si la petición falla (retroalimentación clara al usuario).
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
