import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/currency_flag.dart';
import '../../domain/entities/currency.dart';

/// Modal con buscador para elegir la "Moneda Base" del sistema desde
/// Ajustes (`showModalBottomSheet`). Filtra en tiempo real, por
/// código ISO o nombre, el catálogo ya cargado por la pantalla
/// Inicio — sin volver a golpear la API.
class BaseCurrencyPickerSheet extends StatefulWidget {
  const BaseCurrencyPickerSheet({
    super.key,
    required this.currencies,
    required this.selectedIso,
  });

  final List<Currency> currencies;
  final String selectedIso;

  /// Abre el modal y retorna el código ISO elegido, o `null` si el
  /// usuario lo cerró sin seleccionar nada.
  static Future<String?> show(
    BuildContext context, {
    required List<Currency> currencies,
    required String selectedIso,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => BaseCurrencyPickerSheet(
        currencies: currencies,
        selectedIso: selectedIso,
      ),
    );
  }

  @override
  State<BaseCurrencyPickerSheet> createState() =>
      _BaseCurrencyPickerSheetState();
}

class _BaseCurrencyPickerSheetState extends State<BaseCurrencyPickerSheet> {
  final _searchController = TextEditingController();
  late List<Currency> _filtered = widget.currencies;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? widget.currencies
          : widget.currencies
              .where((c) =>
                  c.isoCode.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q))
              .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
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
              Text('Moneda Base', style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por código o nombre…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(child: Text('Sin coincidencias')),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final currency = _filtered[index];
                          final isSelected =
                              currency.isoCode == widget.selectedIso;
                          return ListTile(
                            leading: CurrencyFlag(
                              isoCurrency: currency.isoCode,
                              size: 28,
                            ),
                            title: Text(currency.isoCode,
                                style: AppTypography.bodyStrong),
                            subtitle: Text(currency.name,
                                style: AppTypography.caption),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.primaryNavy)
                                : null,
                            onTap: () =>
                                Navigator.of(context).pop(currency.isoCode),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
