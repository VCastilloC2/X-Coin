import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_strings.dart';

/// Excepción de dominio para errores de consumo de la API.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Fuente de datos remota: consume la API pública de tasas de cambio
/// mediante peticiones HTTP `GET` con arquitectura REST, tal como se
/// describe en el taller ("¿Cómo se consume la API?").
///
/// Las respuestas llegan en formato JSON y son decodificadas aquí;
/// el mapeo a los modelos nativos (`Currency` / `ExchangeRate`) ocurre
/// en el repositorio, manteniendo esta clase enfocada solo en I/O.
class CurrencyApiService {
  CurrencyApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException(AppStrings.noConnection);
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Error del servidor (${response.statusCode}) al consultar $uri',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /currencies → catálogo de monedas disponibles.
  Future<Map<String, dynamic>> fetchCurrencies() {
    return _getJson(ApiConfig.currencies());
  }

  /// GET /latest?base=USD&symbols=EUR → tasa actual entre dos monedas.
  Future<Map<String, dynamic>> fetchLatestRate({
    required String base,
    required String quote,
  }) {
    return _getJson(ApiConfig.latestRate(base: base, quote: quote));
  }

  /// GET /latest?base=COP → ranking de tasas usando una moneda de referencia.
  Future<Map<String, dynamic>> fetchRanking({required String base}) {
    return _getJson(ApiConfig.rankingRates(base: base));
  }

  /// GET /{from}..{to}?base=USD&symbols=COP → evolución histórica.
  Future<Map<String, dynamic>> fetchHistoricalRange({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) {
    return _getJson(
      ApiConfig.historicalRange(base: base, quote: quote, from: from, to: to),
    );
  }
}
