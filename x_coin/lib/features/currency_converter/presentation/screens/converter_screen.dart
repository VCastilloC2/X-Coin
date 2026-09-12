import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/error_retry_snackbar.dart';
import '../../../../core/widgets/primary_action_button.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../../../../core/widgets/x_coin_card.dart';
import '../providers/currency_converter_provider.dart';
import '../widgets/currency_dropdown.dart';
import '../widgets/favorite_currency_chip.dart';
import '../widgets/numeric_keypad.dart';
import '../widgets/swap_currencies_button.dart';

/// Pantalla "Inicio": conversor de monedas internacionales.
///
/// Reproduce el mockup 1: selector de moneda de origen/destino con
/// intercambio, monto editable mediante teclado numérico
/// personalizado, botón "Convertir" y grilla de monedas favoritas.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  /// Evita mostrar el mismo SnackBar de error repetidamente en cada
  /// rebuild mientras el estado de error de la conversión no cambia.
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyConverterProvider>().loadCurrencies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XCoinAppBar(),
      body: Consumer<CurrencyConverterProvider>(
        builder: (context, provider, _) {
          _maybeShowConversionError(context, provider);

          if (provider.currenciesStatus == ViewStatus.loading ||
              provider.currenciesStatus == ViewStatus.initial) {
            return const ConverterSkeleton();
          }
          if (provider.currenciesStatus == ViewStatus.error) {
            return AsyncStateView(
              isLoading: false,
              errorMessage: provider.errorMessage,
              onRetry: provider.loadCurrencies,
            );
          }
          return _ConverterContent(provider: provider);
        },
      ),
    );
  }

  /// Muestra un SnackBar no intrusivo (con acción "Reintentar") si
  /// falla puntualmente la conversión, sin bloquear toda la pantalla.
  void _maybeShowConversionError(
    BuildContext context,
    CurrencyConverterProvider provider,
  ) {
    if (provider.conversionStatus != ViewStatus.error) return;
    if (provider.errorMessage == _lastShownError) return;
    _lastShownError = provider.errorMessage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ErrorRetrySnackBar.show(
        context,
        message: provider.errorMessage ?? AppStrings.errorLoadingRate,
        onRetry: provider.convert,
      );
    });
  }
}

class _ConverterContent extends StatelessWidget {
  const _ConverterContent({required this.provider});

  final CurrencyConverterProvider provider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.convertTitle, style: AppTypography.screenTitle),
          const SizedBox(height: AppSpacing.lg),

          // Moneda de Origen / Destino + intercambio.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CurrencyDropdown(
                  label: AppStrings.originCurrency,
                  currencies: provider.currencies,
                  selected: provider.origin,
                  onChanged: provider.selectOrigin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: SwapCurrenciesButton(onPressed: provider.swapCurrencies),
              ),
              Expanded(
                child: CurrencyDropdown(
                  label: AppStrings.destinationCurrency,
                  currencies: provider.currencies,
                  selected: provider.destination,
                  onChanged: provider.selectDestination,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Monto + resultado convertido.
          Text(AppStrings.amountLabel, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          XCoinCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${provider.origin?.symbol ?? ''}${provider.rawAmount}',
                  style: AppTypography.amountInput,
                ),
                Text(
                  provider.convertedAmount != null
                      ? '${provider.destination?.symbol ?? ''}'
                          '${provider.convertedAmount!.toStringAsFixed(2)}'
                      : '—',
                  style: AppTypography.amountInput.copyWith(
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          NumericKeypad(onKeyTap: provider.onKeypadInput),
          const SizedBox(height: AppSpacing.md),

          PrimaryActionButton(
            label: AppStrings.convertButton,
            isLoading: provider.conversionStatus == ViewStatus.loading,
            enabled: provider.canConvert,
            onPressed: provider.convert,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.favoriteCurrencies, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: provider.favoriteCurrencies
                .map(
                  (c) => FavoriteCurrencyChip(
                    currency: c,
                    onTap: () => provider.selectOrigin(c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
