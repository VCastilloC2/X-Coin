import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/chart_engine/chart_catalog_filter.dart';
import '../../domain/chart_engine/chart_enums.dart';
import '../providers/chart_filter_provider.dart';

/// Buscador en tiempo real + ChoiceChips por categoría.
/// Ambos escriben en el mismo [ChartFilterProvider], por eso siempre
/// están sincronizados.
class ChartFilterBar extends StatefulWidget {
  const ChartFilterBar({super.key});

  @override
  State<ChartFilterBar> createState() => _ChartFilterBarState();
}

class _ChartFilterBarState extends State<ChartFilterBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<ChartFilterProvider>();

    // Si el estado se limpia desde fuera (p. ej. "Limpiar filtros").
    if (filter.query.isEmpty && _controller.text.isNotEmpty) {
      _controller.clear();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: context.read<ChartFilterProvider>().setQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar por título o categoría…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar búsqueda',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      context.read<ChartFilterProvider>().setQuery('');
                    },
                  ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(context, filter, null, 'Todas'),
              for (final c in ChartCategory.values) ...[
                const SizedBox(width: AppSpacing.sm),
                _chip(context, filter, c, c.label),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${filter.visible.length} de ${filter.countFor(null)} gráficas',
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    ChartFilterProvider filter,
    ChartCategory? value,
    String label,
  ) {
    final selected = filter.category == value;
    return ChoiceChip(
      label: Text('$label (${filter.countFor(value)})'),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.primaryNavy,
      labelStyle: AppTypography.sectionLabel.copyWith(
        color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
      ),
      onSelected: (_) => context.read<ChartFilterProvider>().setCategory(value),
    );
  }
}
