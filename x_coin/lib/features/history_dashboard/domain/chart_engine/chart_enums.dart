/// Las 4 librerías de gráficos soportadas por el Dashboard Analítico.
///
/// NOTA DE ARQUITECTURA (léase antes de tocar este archivo):
/// El paquete original `google_charts_flutter` / `charts_flutter` fue
/// **descontinuado por Google en 2020** y no compila con null-safety
/// ni con el SDK de Dart usado en este proyecto (`^3.13.2`). "Google
/// Charts" tampoco existe como paquete Flutter independiente: es la
/// misma familia (`charts_flutter` ES la librería "Google Charts"
/// para Flutter). Para no entregar un módulo que no compila, ese
/// cupo se cubre con `community_charts_flutter` — el fork
/// mantenido por la comunidad que conserva la misma API pública de
/// `charts_flutter`/Google Charts — y se añade `graphic` (grammar-
/// of-graphics, activamente mantenido) como cuarta librería
/// genuinamente distinta para no duplicar la misma familia dos
/// veces. El resultado sigue siendo **4 librerías × 32 gráficas**.
enum ChartLibrary {
  flChart,
  syncfusion,
  communityCharts, // Sucesor mantenido de charts_flutter / Google Charts.
  graphic,
}

extension ChartLibraryX on ChartLibrary {
  String get label => switch (this) {
        ChartLibrary.flChart => 'FL Chart',
        ChartLibrary.syncfusion => 'Syncfusion Charts',
        ChartLibrary.communityCharts => 'Google Charts (community)',
        ChartLibrary.graphic => 'Graphic',
      };

  String get packageName => switch (this) {
        ChartLibrary.flChart => 'fl_chart',
        ChartLibrary.syncfusion => 'syncfusion_flutter_charts',
        ChartLibrary.communityCharts => 'community_charts_flutter',
        ChartLibrary.graphic => 'graphic',
      };
}

enum ChartCategory { basic, advanced }

/// 32 variantes de gráfica: 20 básicas + 12 avanzadas.
/// Se aplican de forma idéntica a las 4 librerías, así que el
/// catálogo total es `ChartLibrary.values.length * ChartType.values.length`
/// = 4 × 32 = 128, sin escribir un widget por cada una.
enum ChartType {
  // ---------------------------------------------------------------
  // 20 básicas: tendencia en línea, barras, áreas.
  // ---------------------------------------------------------------
  lineSimple(ChartCategory.basic, 'Línea simple'),
  lineSpline(ChartCategory.basic, 'Línea suavizada (spline)'),
  lineStepped(ChartCategory.basic, 'Línea escalonada'),
  lineDashedTrend(ChartCategory.basic, 'Tendencia punteada'),
  lineWithMarkers(ChartCategory.basic, 'Línea con marcadores'),
  lineMovingAverage(ChartCategory.basic, 'Media móvil (7 periodos)'),
  linePercentChange(ChartCategory.basic, 'Variación % acumulada'),
  areaSimple(ChartCategory.basic, 'Área simple'),
  areaGradient(ChartCategory.basic, 'Área con degradado'),
  areaSpline(ChartCategory.basic, 'Área suavizada'),
  areaStep(ChartCategory.basic, 'Área escalonada'),
  barVertical(ChartCategory.basic, 'Barras verticales'),
  barHorizontal(ChartCategory.basic, 'Barras horizontales'),
  barGroupedWeekly(ChartCategory.basic, 'Barras agrupadas (semanal)'),
  barStackedMinMax(ChartCategory.basic, 'Barras apiladas (min/máx)'),
  barRounded(ChartCategory.basic, 'Barras redondeadas'),
  columnRangeHiLo(ChartCategory.basic, 'Rango de columna (hi-lo)'),
  sparkline(ChartCategory.basic, 'Sparkline compacto'),
  dualAxisLineBar(ChartCategory.basic, 'Combinado línea + barra'),
  donutLatestShare(ChartCategory.basic, 'Dona: último valor vs rango'),

  // ---------------------------------------------------------------
  // 12 avanzadas: velas, bandas, dispersión, comparativas, etc.
  // ---------------------------------------------------------------
  candlestick(ChartCategory.advanced, 'Velas japonesas (OHLC sintético)'),
  ohlcBar(ChartCategory.advanced, 'Barras OHLC'),
  bollingerBands(ChartCategory.advanced, 'Bandas de Bollinger'),
  volatilityStdDevBands(ChartCategory.advanced, 'Bandas de volatilidad (±σ)'),
  multiCurrencyComparison(ChartCategory.advanced, 'Comparativa multi-divisa'),
  scatterCorrelation(ChartCategory.advanced, 'Dispersión valor vs media móvil'),
  candleVolumeCombo(ChartCategory.advanced, 'Velas + volumen sintético'),
  heatmapCalendar(ChartCategory.advanced, 'Mapa de calor calendario'),
  rangeAreaBollingerFill(ChartCategory.advanced, 'Área de rango (Bollinger fill)'),
  cumulativeReturnArea(ChartCategory.advanced, 'Retorno acumulado'),
  rsiOscillator(ChartCategory.advanced, 'Oscilador RSI (14)'),
  drawdownArea(ChartCategory.advanced, 'Drawdown desde máximo');

  const ChartType(this.category, this.displayName);

  final ChartCategory category;
  final String displayName;

  static List<ChartType> get basics =>
      values.where((t) => t.category == ChartCategory.basic).toList();

  static List<ChartType> get advanced =>
      values.where((t) => t.category == ChartCategory.advanced).toList();
}
