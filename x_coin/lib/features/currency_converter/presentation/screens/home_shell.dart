import 'package:flutter/material.dart';
import '../../../../core/navigation/app_tabs.dart';
import '../../../../core/widgets/x_coin_bottom_nav_bar.dart';
import 'converter_screen.dart';
import 'rates_screen.dart';
import 'settings_screen.dart';

/// Contenedor raíz de la app: mantiene vivo el estado de cada
/// pantalla con [IndexedStack] y conmuta entre ellas mediante el
/// [XCoinBottomNavBar] compartido (Inicio / Historial / Ajustes).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Permite a cualquier pantalla solicitar el cambio de pestaña.
  ///
  /// Se conserva la firma original (Inicio la usa tal cual), pero ahora
  /// delega en [AppTabs]: antes buscaba el `State` del shell en el árbol
  /// de ancestros, algo imposible desde rutas empujadas con `Navigator`
  /// como el Dashboard Analítico, que quedan por encima del shell.
  static void switchTab(BuildContext context, int index) {
    AppTabs.select(index);
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _screens = [
    ConverterScreen(),
    RatesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Siempre se arranca en Inicio (el notifier es estático y sobrevive
    // a la recreación del widget, p. ej. en tests o hot restart parcial).
    AppTabs.select(AppTabs.home);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppTabs.current,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(index: index, children: _screens),
          bottomNavigationBar: XCoinBottomNavBar(
            currentIndex: index,
            onTap: AppTabs.select,
          ),
        );
      },
    );
  }
}
