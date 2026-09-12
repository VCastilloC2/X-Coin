import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Helper para mostrar errores de red de forma no intrusiva mediante
/// un [SnackBar] flotante con acción de "Reintentar".
///
/// Se usa para errores puntuales de una acción (ej. el botón
/// "Convertir" falla por timeout) que no ameritan bloquear toda la
/// pantalla con [AsyncStateView] — ese widget queda reservado para
/// fallos en la carga inicial de datos.
class ErrorRetrySnackBar {
  ErrorRetrySnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryNavyDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Reintentar',
                  textColor: AppColors.textOnPrimary,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
  }
}
