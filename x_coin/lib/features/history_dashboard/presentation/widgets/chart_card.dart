import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/x_coin_card.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_catalog_filter.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../strategies/chart_strategy_factory.dart';

/// Tarjeta contenedora: título + categoría + descripción + gráfica.
///
/// La gráfica se construye con la MISMA llamada que ya usaba el
/// dashboard (`strategy.build(...)`); la tarjeta solo la envuelve.
class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.config, required this.points});

  final ChartConfig config;
  final List<RatePoint> points;

  @override
  Widget build(BuildContext context) {
    final strategy = ChartStrategyFactory.strategyFor(config.library);

    return XCoinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(config.type.displayName, style: AppTypography.bodyStrong)),
              const SizedBox(width: AppSpacing.sm),
              _CategoryBadge(label: config.category.singularLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(config.type.description, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          // Aísla repintados: filtrar/scrollear no repinta la gráfica.
          RepaintBoundary(
            child: strategy.build(
              context: context,
              config: config,
              points: points,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(label, style: AppTypography.caption),
    );
  }
}
