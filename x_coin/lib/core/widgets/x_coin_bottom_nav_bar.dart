import 'package:flutter/material.dart';
import '../constants/app_strings.dart';

/// BottomNavigationBar compartido por las tres pantallas principales.
///
/// Corresponde al `BottomNavigationBarBar` con sus tres
/// `BottomNavigationBarItem` (Inicio / Historial / Ajustes) señalados
/// en la guía de componentes (mockup 2).
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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: AppStrings.navHistory,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppStrings.navSettings,
        ),
      ],
    );
  }
}
