import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'features/currency_converter/data/repositories/currency_repository_impl.dart';
import 'features/currency_converter/data/repositories/supplemented_currency_repository.dart';
import 'features/currency_converter/domain/repositories/currency_repository.dart';
import 'features/currency_converter/presentation/providers/currency_converter_provider.dart';
import 'features/currency_converter/presentation/providers/rates_provider.dart';
import 'features/currency_converter/presentation/providers/settings_provider.dart';
import 'features/currency_converter/presentation/screens/home_shell.dart';

void main() {
  // Locale por defecto de `intl`: cualquier NumberFormat/DateFormat sin
  // locale explícito usará la convención colombiana (`4.100,50`).
  Intl.defaultLocale = CurrencyFormatter.locale;
  runApp(const XCoinApp());
}

/// Widget raíz de X-Coin.
///
/// Registra el repositorio (única instancia, compartida por todos
/// los providers) y compone el estado global mediante [MultiProvider].
/// El grafo de dependencias está diseñado a propósito para que exista
/// una única fuente de verdad para el par de monedas en toda la app:
///
/// ```
/// SettingsProvider              (Moneda Base, persistida en disco)
///        │
///        ▼   ChangeNotifierProxyProvider
/// CurrencyConverterProvider     (Inicio: origen/destino, favoritas)
///        │
///        ▼   ChangeNotifierProxyProvider2 (junto con SettingsProvider)
/// RatesProvider                 (Historial: gráfica + tasas globales)
/// ```
///
/// Cambiar la "Moneda Base" en Ajustes actualiza el origen en Inicio,
/// y cambiar el par en Inicio refresca automáticamente el Historial —
/// sin que ninguna pantalla ni provider conozca directamente a los
/// demás. Cada provider expone únicamente un método `syncX` / `setX`
/// que main.dart invoca al observar el cambio en su dependencia.
class XCoinApp extends StatelessWidget {
  const XCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Frankfurter (BCE) no publica COP: el decorador lo añade al
        // catálogo, tasas, ranking e histórico sin tocar la
        // implementación original ni la capa de presentación.
        Provider<CurrencyRepository>(
          create: (_) => SupplementedCurrencyRepository(
            delegate: CurrencyRepositoryImpl(),
          ),
        ),

        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),

        // Inicio escucha la Moneda Base de Ajustes: cada vez que
        // cambia, `setOriginByIso` mueve el origen del conversor.
        ChangeNotifierProxyProvider<SettingsProvider, CurrencyConverterProvider>(
          create: (context) => CurrencyConverterProvider(
            repository: context.read<CurrencyRepository>(),
            initialOrigin: context.read<SettingsProvider>().baseCurrency,
          ),
          update: (context, settings, converter) {
            converter ??= CurrencyConverterProvider(
              repository: context.read<CurrencyRepository>(),
              initialOrigin: settings.baseCurrency,
            );
            converter.setOriginByIso(settings.baseCurrency);
            return converter;
          },
        ),

        // Historial escucha tanto a Inicio (par origen/destino) como
        // a Ajustes (moneda de referencia del ranking).
        ChangeNotifierProxyProvider2<CurrencyConverterProvider, SettingsProvider,
            RatesProvider>(
          create: (context) => RatesProvider(
            repository: context.read<CurrencyRepository>(),
          ),
          update: (context, converter, settings, rates) {
            rates ??= RatesProvider(
              repository: context.read<CurrencyRepository>(),
            );
            final base = converter.origin?.isoCode ?? settings.baseCurrency;
            final quote = converter.destination?.isoCode ?? 'EUR';
            rates
              ..syncPair(base: base, quote: quote)
              ..syncRankingBase(settings.baseCurrency);
            return rates;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('es', 'CO'),
            supportedLocales: const [
              Locale('es', 'CO'),
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
