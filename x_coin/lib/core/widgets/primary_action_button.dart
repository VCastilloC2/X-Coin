import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Botón primario con feedback visual de carga y estado deshabilitado.
///
/// Usado por el botón "Convertir": mientras se consulta la tasa a la
/// API se muestra un spinner y el botón se deshabilita para evitar
/// solicitudes duplicadas.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading && onPressed != null;
    return ElevatedButton(
      onPressed: canTap ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.textOnPrimary,
                ),
              ),
            )
          : Text(label),
    );
  }
}
