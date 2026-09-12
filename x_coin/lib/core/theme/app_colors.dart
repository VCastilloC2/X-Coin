import 'package:flutter/material.dart';

/// Paleta de colores centralizada de X-Coin.
///
/// Un solo cambio aquí se refleja en toda la app (AppBar, botones,
/// tarjetas, gráfica, etc.), tal como se ve en los mockups: un azul
/// marino profundo para las cabeceras y acentos, sobre un fondo
/// gris muy claro para el contenido.
class AppColors {
  AppColors._();

  // Azules de marca (AppBar, botón "Convertir", acentos de texto).
  static const Color primaryNavy = Color(0xFF17215B);
  static const Color primaryNavyDark = Color(0xFF0D1440);
  static const Color primaryBlue = Color(0xFF2F3D8F);

  // Fondo general de las pantallas (gris azulado muy claro).
  static const Color background = Color(0xFFF2F3F8);

  // Superficies (tarjetas, teclado numérico, ListTiles de Ajustes).
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEDEFF5);
  static const Color keypadButton = Color(0xFFE7E9F2);
  static const Color keypadOperator = Color(0xFF3A4694);

  // Texto.
  static const Color textPrimary = Color(0xFF1B1F2E);
  static const Color textSecondary = Color(0xFF6B7180);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados.
  static const Color success = Color(0xFF2E9E5B);
  static const Color danger = Color(0xFFD1443A);
  static const Color divider = Color(0xFFE1E3EC);

  // Gráfica de tasas (línea + relleno degradado suave).
  static const Color chartLine = Color(0xFF2F3D8F);
  static const Color chartFillTop = Color(0x332F3D8F);
  static const Color chartFillBottom = Color(0x002F3D8F);

  // Navegación inferior.
  static const Color navSelected = primaryNavy;
  static const Color navUnselected = Color(0xFF9AA0B4);

  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavyDark, primaryNavy],
  );
}
