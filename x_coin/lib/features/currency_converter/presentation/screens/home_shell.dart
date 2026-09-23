import 'package:flutter/material.dart';
import '../../../../core/widgets/x_coin_bottom_nav_bar.dart';
import 'converter_screen.dart';
import 'rates_screen.dart';
import 'settings_screen.dart';

/// Contenedor raíz de la app: mantiene vivo el estado de cada
/// pantalla con [IndexedStack] y conmuta entre ellas mediante el
/// [XCoinBottomNavBar] compartido (Inicio / Historial / Ajustes).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Permite a pantallas hijas solicitar el cambio de pestaña.
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_HomeShellState>();
    state?._changeIndex(index);
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _changeIndex(int index) {
    setState(() => _index = index);
  }

  static const _screens = [

    ConverterScreen(),
    RatesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: XCoinBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
