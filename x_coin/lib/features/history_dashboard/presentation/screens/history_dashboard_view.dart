import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_tabs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../../../../core/widgets/x_coin_bottom_nav_bar.dart';
import '../../../currency_converter/presentation/providers/currency_converter_provider.dart'
    show ViewStatus;
import '../../../currency_converter/presentation/providers/rates_provider.dart';
import '../../../currency_converter/presentation/widgets/range_selector.dart';
import '../providers/chart_filter_provider.dart';
import '../widgets/chart_card.dart';
import '../widgets/chart_filter_bar.dart';

/// Pantalla "Dashboard Analítico Histórico".
///
/// Capa de UI/UX sobre el catálogo de gráficas existente: tarjetas con
/// título y descripción + buscador + filtro por categoría. Las gráficas
/// se siguen construyendo con `ChartStrategyFactory` (sin cambios) y los
/// datos siguen viniendo de `RatesProvider.history` (sin nuevas peticiones).
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

  void _goToTab(int index) {
    AppTabs.select(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChartFilterProvider(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const XCoinAppBar(),
        bottomNavigationBar: XCoinBottomNavBar(
          currentIndex: AppTabs.history,
          onTap: _goToTab,
        ),
        body: Consumer<RatesProvider>(
          builder: (context, rates, _) {
            if (rates.status == ViewStatus.loading ||
                rates.status == ViewStatus.initial) {
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

  // Items fijos antes de las tarjetas: título + selector de rango.
  static const int _headerItems = 2;

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<ChartFilterProvider>();
    final visible = filter.visible;
    final isEmpty = visible.isEmpty;

    return Column(
      children: [
        // Zona fija: el buscador y las categorías siempre a mano.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
          ),
          child: const ChartFilterBar(),
        ),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg,
            ),
            // Lazy: solo se construyen (y cargan) las tarjetas visibles.
            itemCount: _headerItems + (isEmpty ? 1 : visible.length),
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard Analítico Histórico',
                        style: AppTypography.screenTitle),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${rates.base}/${rates.quote} · '
                      '${rates.history.length} puntos en memoria',
                      style: AppTypography.caption,
                    ),
                  ],
                );
              }
              if (index == 1) {
                return RangeSelector(
                  selected: rates.selectedRange,
                  onSelected: rates.selectRange,
                );
              }
              if (isEmpty) return _EmptyResults(onClear: filter.clear);

              final config = visible[index - _headerItems];
              return ChartCard(
                key: ValueKey(config.id), // identidad estable al filtrar
                config: config,
                points: rates.history,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text('Sin resultados', style: AppTypography.bodyStrong),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Prueba con otro término o cambia la categoría.',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onClear, child: const Text('Limpiar filtros')),
        ],
      ),
    );
  }
}
