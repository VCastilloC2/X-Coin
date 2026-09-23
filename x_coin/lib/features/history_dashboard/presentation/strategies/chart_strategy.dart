import 'package:flutter/widgets.dart';
import '../../../currency_converter/domain/entities/exchange_rate.dart';
import '../../domain/chart_engine/chart_config.dart';
import '../../domain/chart_engine/chart_enums.dart';

/// Contrato que debe cumplir CADA librería de gráficos.
///
/// El `HistoryDashboardView` nunca conoce `fl_chart`, `syncfusion`,
/// etc. — solo conoce esta interfaz. Cambiar de librería en runtime
/// es simplemente pedirle al `ChartStrategyFactory` la instancia que
/// corresponde a `config.library` y llamar a [build] con los mismos
/// datos ya cargados en memoria.
abstract class ChartStrategy {
  ChartLibrary get library;

  /// true si esta estrategia sabe renderizar [type] de forma nativa
  /// con su librería. Se usa para filtrar el selector de tipos y
  /// evitar publicitar combinaciones sin soporte real.
  bool supports(ChartType type);

  /// Construye el widget de la gráfica [config] a partir de la serie
  /// histórica ya en memoria (`points`). Nunca dispara peticiones
  /// HTTP: los datos siempre vienen resueltos por el llamador.
  Widget build({
    required BuildContext context,
    required ChartConfig config,
    required List<RatePoint> points,
  });
}
