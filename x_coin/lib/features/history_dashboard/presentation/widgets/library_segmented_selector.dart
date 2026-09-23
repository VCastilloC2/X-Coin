import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// Segmented control para cambiar de librería de gráficos en runtime.
/// El cambio nunca refetchea datos: solo notifica al
/// `HistoryDashboardProvider`, que reconstruye la gráfica activa con
/// los mismos puntos ya cargados en memoria.
class LibrarySegmentedSelector extends StatelessWidget {
  const LibrarySegmentedSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ChartLibrary selected;
  final ValueChanged<ChartLibrary> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        children: [
          for (final library in ChartLibrary.values)
            Expanded(
              child: _Segment(
                label: library.label,
                selected: library == selected,
                onTap: () => onSelected(library),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: selected ? AppColors.primaryNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
