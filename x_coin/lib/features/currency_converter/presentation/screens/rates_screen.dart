import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/async_state_view.dart';
import '../../../../core/widgets/x_coin_app_bar.dart';
import '../../../../core/widgets/x_coin_card.dart';
import '../providers/currency_converter_provider.dart' show ViewStatus;
import '../providers/rates_provider.dart';
import '../widgets/global_rate_tile.dart';
import '../widgets/range_selector.dart';
import '../widgets/rate_line_chart.dart';

/// Pantalla "Historial": tasa actual con gráfica de evolución y
/// ranking de "Tasas Globales", igual al teléfono derecho del
/// mockup 1.
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
            return const AsyncStateView(
              isLoading: true,
              errorMessage: null,
              onRetry: _noop,
            );
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

  static void _noop() {}
}

class _RatesContent extends StatelessWidget {
  const _RatesContent({required this.provider});

  final RatesProvider provider;

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
            Text(
              '1 ${rate.baseCurrency} = ${rate.rateValue.toStringAsFixed(2)} '
              '${rate.quoteCurrency}',
              style: AppTypography.rateHero,
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(AppStrings.globalRates, style: AppTypography.sectionLabel),
          const SizedBox(height: AppSpacing.sm),
          XCoinCard(
            child: Column(
              children: [
                for (final entry in provider.ranking.entries.take(4))
                  GlobalRateTile(
                    flagEmoji: '🏳️',
                    pairLabel: '${provider.base}/${entry.key}',
                    valueLabel: entry.value.toStringAsFixed(entry.value < 1 ? 6 : 2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
