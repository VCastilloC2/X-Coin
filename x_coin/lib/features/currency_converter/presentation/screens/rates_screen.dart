import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/currency_flag.dart';
import '../../../../core/widgets/skeletons.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../../../../core/widgets/x_coin_card.dart';
import '../providers/currency_converter_provider.dart' show ViewStatus;
import '../providers/rates_provider.dart';
import '../widgets/global_rate_tile.dart';
import '../widgets/range_selector.dart';
import '../widgets/rate_line_chart.dart';
import '../../../history_dashboard/presentation/screens/history_dashboard_view.dart';

/// Pantalla "Historial": tasa actual con gráfica de evolución y
/// ranking de "Tasas Globales".
///
/// El par mostrado aquí (`provider.base`/`provider.quote`) y la
/// moneda de referencia del ranking (`provider.rankingBase`) ya no
/// están fijos: se sincronizan automáticamente con la selección de
/// Inicio y la "Moneda Base" de Ajustes vía `RatesProvider.syncPair`
/// / `syncRankingBase`, invocados desde los `ChangeNotifierProxyProvider`
/// declarados en `main.dart`.
class RatesScreen extends StatefulWidget {
  const RatesScreen({super.key});

  @override
  State<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends State<RatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RatesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const XCoinAppBar(),
      body: Consumer<RatesProvider>(
        builder: (context, provider, _) {
          if (provider.status == ViewStatus.loading ||
              provider.status == ViewStatus.initial) {
            return const RatesSkeleton();
          }
          if (provider.status == ViewStatus.error) {
            return AsyncStateView(
              isLoading: false,
              errorMessage: provider.errorMessage,
              onRetry: provider.load,
            );
          }
          return _RatesContent(provider: provider);
        },
      ),
    );
  }
}

class _RatesContent extends StatelessWidget {
  const _RatesContent({required this.provider});

  final RatesProvider provider;

  /// Primeras 4 tasas del ranking (como antes) más COP fijada al final:
  /// alfabéticamente COP queda fuera de las 4 primeras y, sin fijarla, la
  /// lista seguiría sin mostrar el peso colombiano.
  static List<MapEntry<String, double>> _featuredRanking(
    Map<String, double> ranking,
    String baseIso,
  ) {
    const pinned = 'COP';
    final entries = ranking.entries.take(4).toList();
    final cop = ranking[pinned];
    if (cop != null &&
        baseIso != pinned &&
        !entries.any((e) => e.key == pinned)) {
      entries.add(MapEntry(pinned, cop));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final rate = provider.currentRate;
    return RefreshIndicator(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(AppStrings.currentRate, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.xs),
          if (rate != null)
            Row(
              children: [
                CurrencyFlag(isoCurrency: rate.baseCurrency, size: 22),
                const SizedBox(width: 6),
                CurrencyFlag(isoCurrency: rate.quoteCurrency, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '1 ${rate.baseCurrency} = '
                    '${CurrencyFormatter.heroRate(rate.rateValue)} '
                    '${rate.quoteCurrency}',
                    style: AppTypography.rateHero,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),

          XCoinCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RateLineChart(points: provider.history),
                const SizedBox(height: AppSpacing.sm),
                RangeSelector(
                  selected: provider.selectedRange,
                  onSelected: provider.selectRange,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryDashboardView()),
                    ),
                    icon: const Icon(Icons.insights_rounded, size: 18),
                    label: const Text('Dashboard Analítico'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.globalRates, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          XCoinCard(
            child: Column(
              children: [
                for (final entry in _featuredRanking(
                  provider.ranking,
                  provider.rankingBase,
                ))
                  GlobalRateTile(
                    baseIso: provider.rankingBase,
                    quoteIso: entry.key,
                    valueLabel: CurrencyFormatter.rate(entry.value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
