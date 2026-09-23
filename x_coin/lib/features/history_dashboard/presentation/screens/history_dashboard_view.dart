import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../../../../core/widgets/x_coin_card.dart';
import '../../../currency_converter/presentation/providers/currency_converter_provider.dart'
    show ViewStatus;
import '../../../currency_converter/presentation/providers/rates_provider.dart';
import '../../../currency_converter/presentation/widgets/range_selector.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../providers/history_dashboard_provider.dart';
import '../strategies/chart_strategy_factory.dart';
import '../widgets/chart_type_bottom_sheet.dart';
import '../widgets/library_segmented_selector.dart';

/// Pantalla "Dashboard Analítico Histórico".
///
/// El único disparador de red de esta pantalla es
/// `RatesProvider.load()` / `selectRange()` — ya existente en la app
/// para poblar `ApiConfig.historicalRange`. Todo lo que ocurre dentro
/// de este widget (cambiar librería, cambiar tipo de gráfica, cambiar
/// categoría) opera exclusivamente sobre `RatesProvider.history`, que
/// ya está en memoria: por diseño, ninguna de esas acciones puede
/// disparar un nuevo request HTTP.
class HistoryDashboardView extends StatefulWidget {
  const HistoryDashboardView({super.key});

  @override
  State<HistoryDashboardView> createState() => _HistoryDashboardViewState();
}

class _HistoryDashboardViewState extends State<HistoryDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rates = context.read<RatesProvider>();
      if (rates.status == ViewStatus.initial) rates.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryDashboardProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const XCoinAppBar(),
        body: Consumer<RatesProvider>(
          builder: (context, rates, _) {
            if (rates.status == ViewStatus.loading || rates.status == ViewStatus.initial) {
              return const RatesSkeleton();
            }
            if (rates.status == ViewStatus.error) {
              return AsyncStateView(
                isLoading: false,
                errorMessage: rates.errorMessage,
                onRetry: rates.load,
              );
            }
            return _DashboardContent(rates: rates);
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.rates});

  final RatesProvider rates;

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<HistoryDashboardProvider>();
    final config = dashboard.activeConfig;
    final strategy = ChartStrategyFactory.strategyFor(dashboard.library);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Dashboard Analítico Histórico',
          style: AppTypography.screenTitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${rates.base}/${rates.quote} · ${rates.history.length} puntos en memoria '
          '(catálogo: 128 gráficas · 4 librerías × 32 tipos)',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        RangeSelector(
          selected: rates.selectedRange,
          onSelected: rates.selectRange, // Único punto que sí refetchea (cambia el rango real).
        ),
        const SizedBox(height: AppSpacing.md),
        XCoinCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LibrarySegmentedSelector(
                  selected: dashboard.library,
                  onSelected: dashboard.selectLibrary,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        config.title,
                        style: AppTypography.bodyStrong,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _ChangeTypeButton(
                      category: dashboard.category,
                      type: dashboard.type,
                      onCategoryChanged: dashboard.selectCategory,
                      onTypeChanged: dashboard.selectType,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(config.id),
                    child: strategy.build(
                      context: context,
                      config: config,
                      points: rates.history,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _CatalogSummary(library: dashboard.library),
      ],
    );
  }
}

class _ChangeTypeButton extends StatelessWidget {
  const _ChangeTypeButton({
    required this.category,
    required this.type,
    required this.onCategoryChanged,
    required this.onTypeChanged,
  });

  final ChartCategory category;
  final ChartType type;
  final ValueChanged<ChartCategory> onCategoryChanged;
  final ValueChanged<ChartType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => showChartTypeBottomSheet(
        context: context,
        selectedCategory: category,
        selectedType: type,
        onCategoryChanged: onCategoryChanged,
        onTypeChanged: onTypeChanged,
      ),
      icon: const Icon(Icons.tune, size: 16),
      label: const Text('Tipo'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryNavy,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
    );
  }
}

class _CatalogSummary extends StatelessWidget {
  const _CatalogSummary({required this.library});

  final ChartLibrary library;

  @override
  Widget build(BuildContext context) {
    return XCoinCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '${library.label} (${library.packageName}) · 32 gráficas disponibles '
                'para este par, sin nuevas peticiones a Frankfurter.',
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
