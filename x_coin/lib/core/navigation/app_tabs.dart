import 'package:flutter/foundation.dart';

/// Estado global mínimo de la pestaña activa del shell principal
/// (Inicio / Historial / Ajustes).
///
/// Existe porque el Dashboard Analítico se abre con `Navigator.push`:
/// esa ruta vive **encima** de `HomeShell`, no dentro de él, así que
/// `context.findAncestorStateOfType<HomeShellState>()` devuelve `null`
/// desde el dashboard. Con un [ValueNotifier] compartido, cualquier
/// pantalla (esté o no dentro del shell) puede pedir un cambio de
/// pestaña sin conocer al widget que la dibuja.
class AppTabs {
  AppTabs._();

  static const int home = 0;
  static const int history = 1;
  static const int settings = 2;

  /// Índice de la pestaña activa. `HomeShell` lo escucha.
  static final ValueNotifier<int> current = ValueNotifier<int>(home);

  /// Activa la pestaña [index] (usa las constantes de esta clase).
  static void select(int index) {
    current.value = index;
  }
}
