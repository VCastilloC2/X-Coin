import '../entities/currency.dart';
import '../entities/exchange_rate.dart';

/// Contrato del repositorio de monedas y tasas.
///
/// La capa de presentación (providers) depende únicamente de esta
/// interfaz, nunca de la implementación HTTP concreta, siguiendo el
/// principio de inversión de dependencias de Clean Architecture.
abstract class CurrencyRepository {
  /// Lista de monedas disponibles (poblar dropdowns y favoritas).
  Future<List<Currency>> getAvailableCurrencies();

  /// Tasa actual entre [base] y [quote].
  Future<ExchangeRate> getLatestRate({
    required String base,
    required String quote,
  });

  /// Ranking de tasas de varias monedas usando [base] como referencia.
  Future<Map<String, double>> getRanking({required String base});

  /// Evolución histórica de [base] -> [quote] entre [from] y [to].
  Future<List<RatePoint>> getHistoricalRange({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  });
}
