import 'package:flutter/material.dart';
import '../constants/currency_country_map.dart';
import '../theme/app_colors.dart';

/// Bandera oficial de una moneda, resuelta a partir de su código ISO
/// 4217 (ej. `USD` → 🇺🇸) contra [CurrencyCountryMap] y renderizada
/// mediante FlagCDN (`flagcdn.com/w40/{country}.png`).
///
/// Se usa en el Dropdown de Inicio, las "Monedas Favoritas" y las
/// "Tasas Globales" de Historial, garantizando una única fuente de
/// verdad visual para banderas en toda la app.
///
/// Si la moneda no tiene país único (`XAU`, `XDR`, `XOF`, etc.) o si
/// la imagen falla al cargar (sin conexión, código desconocido), se
/// muestra un distintivo circular de respaldo en vez de un espacio
/// vacío o un ícono roto.
class CurrencyFlag extends StatelessWidget {
  const CurrencyFlag({
    super.key,
    required this.isoCurrency,
    this.size = 20,
  });

  /// Código ISO 4217 de la moneda (ej. `USD`, `EUR`, `XDR`).
  final String isoCurrency;

  /// Diámetro del distintivo circular.
  final double size;

  @override
  Widget build(BuildContext context) {
    final countryCode = CurrencyCountryMap.countryCodeFor(isoCurrency);

    if (countryCode == null) {
      return _FlagFallback(diameter: size);
    }

    final url = 'https://flagcdn.com/w40/$countryCode.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: Image.network(
        url,
        key: ValueKey(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _FlagFallback(diameter: size),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _FlagFallback(diameter: size, isLoading: true);
        },
      ),
    );
  }
}

/// Distintivo circular de respaldo: se usa mientras una bandera
/// carga, cuando falla la red, o cuando la moneda no tiene país
/// único (oro, DEG, uniones monetarias regionales).
class _FlagFallback extends StatelessWidget {
  const _FlagFallback({required this.diameter, this.isLoading = false});

  final double diameter;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      child: isLoading
          ? SizedBox(
              width: diameter * 0.45,
              height: diameter * 0.45,
              child: const CircularProgressIndicator(strokeWidth: 1.6),
            )
          : Icon(
              Icons.public_rounded,
              size: diameter * 0.62,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
    );
  }
}
