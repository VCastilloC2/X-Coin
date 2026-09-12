import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/currency_converter/data/repositories/currency_repository_impl.dart';
import 'features/currency_converter/domain/repositories/currency_repository.dart';
import 'features/currency_converter/presentation/providers/currency_converter_provider.dart';
import 'features/currency_converter/presentation/providers/rates_provider.dart';
import 'features/currency_converter/presentation/providers/settings_provider.dart';
import 'features/currency_converter/presentation/screens/home_shell.dart';

void main() {
  runApp(const XCoinApp());
}

/// Widget raíz de X-Coin.
///
/// Registra el repositorio (única instancia, compartida por los
/// providers de presentación) y expone los `ChangeNotifier` de cada
/// pantalla mediante [MultiProvider], sin acoplar la UI a Flutter's
/// data layer.
class XCoinApp extends StatelessWidget {
  const XCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CurrencyRepository>(create: (_) => CurrencyRepositoryImpl()),
        ChangeNotifierProvider<CurrencyConverterProvider>(
          create: (context) => CurrencyConverterProvider(
            repository: context.read<CurrencyRepository>(),
          ),
        ),
        ChangeNotifierProvider<RatesProvider>(
          create: (context) => RatesProvider(
            repository: context.read<CurrencyRepository>(),
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}