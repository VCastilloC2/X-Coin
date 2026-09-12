import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/currency_flag.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/rate_alert.dart';

/// Modal interactivo (`showModalBottomSheet`) para definir el umbral
/// de una alerta de tasa, ej.: "Notificar si 1 USD > 4100 COP".
class RateAlertSheet extends StatefulWidget {
  const RateAlertSheet({
    super.key,
    required this.currencies,
    this.initialAlert,
  });

  final List<Currency> currencies;
  final RateAlert? initialAlert;

  /// Abre el modal y retorna la [RateAlert] configurada, o `null` si
  /// el usuario cerró sin guardar.
  static Future<RateAlert?> show(
    BuildContext context, {
    required List<Currency> currencies,
    RateAlert? initialAlert,
  }) {
    return showModalBottomSheet<RateAlert>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => RateAlertSheet(
        currencies: currencies,
        initialAlert: initialAlert,
      ),
    );
  }

  @override
  State<RateAlertSheet> createState() => _RateAlertSheetState();
}

class _RateAlertSheetState extends State<RateAlertSheet> {
  Currency? _base;
  Currency? _quote;
  late final TextEditingController _thresholdController;
  RateAlertDirection _direction = RateAlertDirection.above;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialAlert?.direction ?? RateAlertDirection.above;
    _base = _resolve(widget.initialAlert?.baseCurrency ?? 'USD');
    _quote = _resolve(widget.initialAlert?.quoteCurrency ?? 'COP') ??
        (widget.currencies.length > 1 ? widget.currencies[1] : null);
    _thresholdController = TextEditingController(
      text: widget.initialAlert != null
          ? widget.initialAlert!.threshold.toStringAsFixed(2)
          : '',
    );
  }

  Currency? _resolve(String iso) {
    for (final c in widget.currencies) {
      if (c.isoCode == iso) return c;
    }
    return widget.currencies.isNotEmpty ? widget.currencies.first : null;
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _base != null &&
      _quote != null &&
      _base != _quote &&
      double.tryParse(_thresholdController.text.replaceAll(',', '.')) != null;

  void _save() {
    final threshold =
        double.parse(_thresholdController.text.replaceAll(',', '.'));
    Navigator.of(context).pop(
      RateAlert(
        baseCurrency: _base!.isoCode,
        quoteCurrency: _quote!.isoCode,
        threshold: threshold,
        direction: _direction,
      ),
    );
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
              Text('Alerta de Tasa', style: AppTypography.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Te avisaremos cuando el par alcance el umbral definido.',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _CurrencyField(
                      label: 'Moneda',
                      value: _base,
                      currencies: widget.currencies,
                      onChanged: (c) => setState(() => _base = c),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DirectionPicker(
                    value: _direction,
                    onChanged: (v) => setState(() => _direction = v),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _CurrencyField(
                      label: 'Contra',
                      value: _quote,
                      currencies: widget.currencies,
                      onChanged: (c) => setState(() => _quote = c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _thresholdController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Umbral (ej. 4100)',
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  child: const Text('Guardar Alerta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionPicker extends StatelessWidget {
  const _DirectionPicker({required this.value, required this.onChanged});

  final RateAlertDirection value;
  final ValueChanged<RateAlertDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<RateAlertDirection>(
            value: value,
            isDense: true,
            items: const [
              DropdownMenuItem(
                value: RateAlertDirection.above,
                child: Text('>', style: AppTypography.bodyStrong),
              ),
              DropdownMenuItem(
                value: RateAlertDirection.below,
                child: Text('<', style: AppTypography.bodyStrong),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.label,
    required this.value,
    required this.currencies,
    required this.onChanged,
  });

  final String label;
  final Currency? value;
  final List<Currency> currencies;
  final ValueChanged<Currency?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.sectionLabel),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: value,
              isExpanded: true,
              isDense: true,
              items: currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CurrencyFlag(isoCurrency: c.isoCode, size: 18),
                          const SizedBox(width: 6),
                          Text(c.isoCode, style: AppTypography.bodyStrong),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
