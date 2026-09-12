import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../providers/currency_converter_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/base_currency_picker_sheet.dart';
import '../widgets/rate_alert_sheet.dart';
import '../widgets/settings_tile.dart';

/// Pantalla "Ajustes": preferencias de la app — modo oscuro,
/// notificaciones, alertas de tasa y moneda base — todas
/// funcionales y persistidas con `shared_preferences` a través de
/// [SettingsProvider].
///
/// Cambiar la "Moneda Base" aquí no solo actualiza esta pantalla:
/// vía el grafo de providers en `main.dart`, también mueve el origen
/// del conversor en Inicio y el par/ranking consultados en Historial.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XCoinAppBar(),
      body: Consumer2<SettingsProvider, CurrencyConverterProvider>(
        builder: (context, settings, converter, _) {
          final alert = settings.rateAlert;
          final currenciesReady = converter.currencies.isNotEmpty;

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
                subtitle: alert?.description ?? 'Sin alerta configurada',
                trailing: const Icon(Icons.chevron_right),
                onTap: currenciesReady
                    ? () => _openRateAlertSheet(context, settings, converter)
                    : null,
              ),
              SettingsTile(
                icon: Icons.public_outlined,
                title: AppStrings.baseCurrency,
                subtitle: settings.baseCurrency,
                trailing: const Icon(Icons.chevron_right),
                onTap: currenciesReady
                    ? () => _openBaseCurrencyPicker(context, settings, converter)
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openBaseCurrencyPicker(
    BuildContext context,
    SettingsProvider settings,
    CurrencyConverterProvider converter,
  ) async {
    final selected = await BaseCurrencyPickerSheet.show(
      context,
      currencies: converter.currencies,
      selectedIso: settings.baseCurrency,
    );
    if (selected != null) {
      await settings.setBaseCurrency(selected);
    }
  }

  Future<void> _openRateAlertSheet(
    BuildContext context,
    SettingsProvider settings,
    CurrencyConverterProvider converter,
  ) async {
    final alert = await RateAlertSheet.show(
      context,
      currencies: converter.currencies,
      initialAlert: settings.rateAlert,
    );
    if (alert != null) {
      await settings.setRateAlert(alert);
    }
  }
}
