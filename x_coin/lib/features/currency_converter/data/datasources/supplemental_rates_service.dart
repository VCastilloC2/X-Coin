import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_strings.dart';
import 'currency_api_service.dart' show ApiException;

/// Fuente de datos de respaldo para monedas que **Frankfurter no publica**.
///
/// Frankfurter v1 replica las tasas de referencia del Banco Central
/// Europeo (~30 monedas) y el peso colombiano (COP) no está entre ellas:
/// por eso nunca aparecía en Monedas Favoritas, en los dropdowns ni en
/// las Tasas Globales, sin importar cómo se formateara.
///
/// Este servicio consume el dataset abierto `fawazahmed0/currency-api`
/// (sin API key), servido por jsDelivr con espejo en Cloudflare Pages.
/// Cada "snapshot" es un JSON `{ "date": ..., "usd": { "cop": 3950.1, ... } }`
/// y siempre se expresa respecto al USD; el repositorio se encarga de
/// convertir a cualquier otro par por tasa cruzada.
///
/// Los snapshots se cachean en memoria (los históricos para siempre, el
/// `latest` durante [_latestTtl]) y las peticiones concurrentes al mismo
/// snapshot se comparten, para no repetir descargas al cargar Historial.
class SupplementalRatesService {
  SupplementalRatesService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Monedas que este servicio cubre y Frankfurter no.
  static const Set<String> supportedCodes = {'COP'};

  static const Duration _latestTtl = Duration(minutes: 10);
  static const Duration _timeout = Duration(seconds: 10);

  final Map<String, Future<Map<String, double>>> _snapshots = {};
  final Map<String, DateTime> _fetchedAt = {};

  /// Cuántas unidades de [iso] equivalen a 1 USD (`1 USD = X iso`).
  ///
  /// Con [date] nulo (o de hoy en adelante) usa la tasa más reciente;
  /// con una fecha pasada usa el snapshot de ese día.
  /// Lanza [ApiException] si ninguna de las dos fuentes responde.
  Future<double> fetchUsdRate(String iso, {DateTime? date}) async {
    final snapshot = await _snapshot(_tagFor(date));
    final value = snapshot[iso.toLowerCase()];
    if (value == null || value <= 0) {
      throw ApiException('No hay tasa disponible para $iso.');
    }
    return value;
  }

  /// `latest` o `yyyy-MM-dd`, según la fecha pedida.
  String _tagFor(DateTime? date) {
    if (date == null) return 'latest';
    final now = DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    // El snapshot de hoy puede no estar publicado aún: se usa `latest`.
    if (!day.isBefore(today)) return 'latest';
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, double>> _snapshot(String tag) {
    final cached = _snapshots[tag];
    final stamp = _fetchedAt[tag];
    final isFresh = tag != 'latest' ||
        (stamp != null && DateTime.now().difference(stamp) < _latestTtl);
    if (cached != null && isFresh) return cached;

    _fetchedAt[tag] = DateTime.now();
    final future = _download(tag).onError<Object>((error, stackTrace) {
      // No cachear fallos: el siguiente intento vuelve a la red.
      _snapshots.remove(tag);
      _fetchedAt.remove(tag);
      Error.throwWithStackTrace(error, stackTrace);
    });
    _snapshots[tag] = future;
    return future;
  }

  Future<Map<String, double>> _download(String tag) async {
    final sources = <Uri>[
      Uri.parse(
        'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@$tag'
        '/v1/currencies/usd.json',
      ),
      // Espejo oficial del mismo dataset, por si jsDelivr no responde.
      Uri.parse('https://$tag.currency-api.pages.dev/v1/currencies/usd.json'),
    ];

    for (final uri in sources) {
      try {
        final response = await _client.get(uri).timeout(_timeout);
        if (response.statusCode != 200) continue;
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final usd = json['usd'] as Map<String, dynamic>;
        return {
          for (final entry in usd.entries)
            if (entry.value is num) entry.key: (entry.value as num).toDouble(),
        };
      } catch (_) {
        // Red caída, timeout o JSON inesperado: se intenta el espejo.
        continue;
      }
    }
    throw ApiException(AppStrings.noConnection);
  }
}
