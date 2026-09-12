import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_tile.dart';

/// Pantalla "Ajustes": lista de preferencias de la app, fiel al
/// mockup 2 ("GUÍA DE COMPONENTES FLUTTER (MATERIAL 3)"): AppBar +
/// título + `ListView` de `ListTile` con `Switch` e íconos.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XCoinAppBar(),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(AppStrings.appPreferences, style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.lg),

              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: AppStrings.darkMode,
                trailing: Switch(
                  value: settings.darkMode,
                  onChanged: settings.toggleDarkMode,
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                title: AppStrings.notifications,
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: settings.toggleNotifications,
                ),
              ),
              SettingsTile(
                icon: Icons.show_chart_rounded,
                title: AppStrings.rateAlerts,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Punto de extensión: navegar a la configuración
                  // detallada de alertas de tasa.
                },
              ),
              SettingsTile(
                icon: Icons.public_outlined,
                title: AppStrings.baseCurrency,
                subtitle: settings.baseCurrency,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBaseCurrencyPicker(context, settings),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBaseCurrencyPicker(
    BuildContext context,
    SettingsProvider settings,
  ) {
    const options = ['USD', 'EUR', 'GBP', 'COP', 'JPY'];
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final iso in options)
              ListTile(
                title: Text(iso),
                trailing: settings.baseCurrency == iso
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  settings.setBaseCurrency(iso);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
