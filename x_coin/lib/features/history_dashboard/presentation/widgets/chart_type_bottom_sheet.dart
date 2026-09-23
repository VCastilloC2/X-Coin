import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// BottomSheet que permite elegir la categoría (Básica/Avanzada) y el
/// tipo específico dentro de la librería activa. No recibe ni
/// dispara ninguna petición de datos: solo devuelve la selección.
Future<void> showChartTypeBottomSheet({
  required BuildContext context,
  required ChartCategory selectedCategory,
  required ChartType selectedType,
  required ValueChanged<ChartCategory> onCategoryChanged,
  required ValueChanged<ChartType> onTypeChanged,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final types = selectedCategory == ChartCategory.basic
              ? ChartType.basics
              : ChartType.advanced;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                    ),
                  ),
                  Text('Tipo de gráfica', style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (final category in ChartCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(category == ChartCategory.basic ? 'Básicas (20)' : 'Avanzadas (12)'),
                            selected: category == selectedCategory,
                            onSelected: (_) {
                              onCategoryChanged(category);
                              setSheetState(() => selectedCategory = category);
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: types.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, i) {
                        final type = types[i];
                        final isSelected = type == selectedType;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(type.displayName, style: AppTypography.body),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: AppColors.primaryNavy)
                              : null,
                          onTap: () {
                            onTypeChanged(type);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
