import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

/// Barra de navegación inferior compartida por las tres pantallas
/// principales (Inicio / Historial / Ajustes).
///
/// Usa el `NavigationBar` de Material 3 en vez del
/// `BottomNavigationBar` clásico: trae de fábrica una animación
/// suave del indicador de selección (píldora) y del color de los
/// íconos al cambiar de pestaña, cumpliendo el requisito de
/// transiciones fluidas sin lógica de animación manual.
class XCoinBottomNavBar extends StatelessWidget {
  const XCoinBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      animationDuration: const Duration(milliseconds: 400),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: AppStrings.navHome,
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: AppStrings.navHistory,
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: AppStrings.navSettings,
        ),
      ],
    );
  }
}
