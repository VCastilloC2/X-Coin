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
  lineSimple(
    ChartCategory.basic,
    'Línea simple',
    'Une cada punto con una línea recta. Ideal para ver de un vistazo '
        'si la tasa subió o bajó en el periodo seleccionado.',
  ),
  lineSpline(
    ChartCategory.basic,
    'Línea suavizada (spline)',
    'La misma tendencia que la línea simple, pero curvada para que se '
        'vea más fluida y sea más fácil detectar el patrón general.',
  ),
  lineStepped(
    ChartCategory.basic,
    'Línea escalonada',
    'Muestra el valor como "escalones": útil cuando la tasa se mantiene '
        'fija entre actualizaciones y cambia de golpe, no gradualmente.',
  ),
  lineDashedTrend(
    ChartCategory.basic,
    'Tendencia punteada',
    'La misma línea de tendencia pero en punteado, pensada para '
        'superponerse sobre otra gráfica sin taparla visualmente.',
  ),
  lineWithMarkers(
    ChartCategory.basic,
    'Línea con marcadores',
    'Igual que la línea simple, pero marca cada punto exacto con un '
        'círculo para identificar con precisión el valor de cada día.',
  ),
  lineMovingAverage(
    ChartCategory.basic,
    'Media móvil (7 periodos)',
    'Suaviza el ruido diario promediando los últimos 7 puntos, para '
        'revelar la tendencia real sin los saltos pequeños del día a día.',
  ),
  linePercentChange(
    ChartCategory.basic,
    'Variación % acumulada',
    'Muestra cuánto ha subido o bajado la tasa en porcentaje respecto '
        'al primer punto del periodo, en vez del valor absoluto.',
  ),
  areaSimple(
    ChartCategory.basic,
    'Área simple',
    'Como la línea simple, pero rellena el espacio debajo: ayuda a '
        'percibir mejor el "volumen" o magnitud del cambio.',
  ),
  areaGradient(
    ChartCategory.basic,
    'Área con degradado',
    'Área rellena con un degradado de color que se desvanece hacia '
        'abajo, dándole más énfasis visual a la línea de tendencia.',
  ),
  areaSpline(
    ChartCategory.basic,
    'Área suavizada',
    'Combina la curva suavizada de la spline con el relleno del área, '
        'para una lectura visual más elegante y menos angulosa.',
  ),
  areaStep(
    ChartCategory.basic,
    'Área escalonada',
    'Área rellena que respeta los "escalones" de la línea escalonada, '
        'útil para tasas que cambian en saltos discretos.',
  ),
  barVertical(
    ChartCategory.basic,
    'Barras verticales',
    'Una barra por cada punto en el tiempo: buena para comparar '
        'valores puntuales día a día en vez de ver una tendencia continua.',
  ),
  barHorizontal(
    ChartCategory.basic,
    'Barras horizontales',
    'Igual que las barras verticales pero acostadas; útil cuando hay '
        'pocas categorías y los nombres son largos.',
  ),
  barGroupedWeekly(
    ChartCategory.basic,
    'Barras agrupadas (semanal)',
    'Agrupa los puntos por semana para comparar el comportamiento '
        'de una semana contra otra de forma más resumida.',
  ),
  barStackedMinMax(
    ChartCategory.basic,
    'Barras apiladas (min/máx)',
    'Cada barra muestra el rango entre el valor mínimo y máximo del '
        'periodo, para ver qué tan volátil fue cada tramo.',
  ),
  barRounded(
    ChartCategory.basic,
    'Barras redondeadas',
    'Las mismas barras verticales, con las puntas redondeadas por '
        'estética; el dato que representa es idéntico.',
  ),
  columnRangeHiLo(
    ChartCategory.basic,
    'Rango de columna (hi-lo)',
    'Cada columna marca el punto más alto y más bajo alcanzado, útil '
        'para detectar picos y caídas puntuales.',
  ),
  sparkline(
    ChartCategory.basic,
    'Sparkline compacto',
    'Una miniatura sin ejes ni etiquetas, pensada para mostrar la '
        'tendencia de un vistazo en espacios muy pequeños.',
  ),
  dualAxisLineBar(
    ChartCategory.basic,
    'Combinado línea + barra',
    'Mezcla una línea de tendencia con barras de fondo, para comparar '
        'dos formas de leer el mismo dato en una sola gráfica.',
  ),
  donutLatestShare(
    ChartCategory.basic,
    'Dona: último valor vs rango',
    'Una dona que compara el último valor registrado contra el rango '
        'total (mínimo-máximo) del periodo, como una especie de medidor.',
  ),

  // ---------------------------------------------------------------
  // 12 avanzadas: velas, bandas, dispersión, comparativas, etc.
  // ---------------------------------------------------------------
  candlestick(
    ChartCategory.advanced,
    'Velas japonesas (OHLC sintético)',
    'Cada "vela" resume apertura, cierre, máximo y mínimo de un '
        'tramo, como en las gráficas de trading. Aquí se simula a '
        'partir de los puntos disponibles, ya que la API no da OHLC real.',
  ),
  ohlcBar(
    ChartCategory.advanced,
    'Barras OHLC',
    'La misma información que las velas (apertura/cierre/máx/mín) '
        'pero representada con barras en vez de rectángulos.',
  ),
  bollingerBands(
    ChartCategory.advanced,
    'Bandas de Bollinger',
    'Dibuja una banda superior e inferior alrededor de la media '
        'móvil para visualizar qué tan lejos se aleja el precio de lo normal.',
  ),
  volatilityStdDevBands(
    ChartCategory.advanced,
    'Bandas de volatilidad (±σ)',
    'Parecida a Bollinger, pero basada directamente en la '
        'desviación estándar: entre más ancha la banda, más volátil el par.',
  ),
  multiCurrencyComparison(
    ChartCategory.advanced,
    'Comparativa multi-divisa',
    'Superpone más de una serie en la misma gráfica, para comparar '
        'el comportamiento de la tendencia contra su propia media móvil.',
  ),
  scatterCorrelation(
    ChartCategory.advanced,
    'Dispersión valor vs media móvil',
    'Cada punto compara el valor real contra su media móvil: sirve '
        'para ver qué tan correlacionados están o si hay outliers.',
  ),
  candleVolumeCombo(
    ChartCategory.advanced,
    'Velas + volumen sintético',
    'Añade a las velas una barra de "volumen" simulado debajo, '
        'imitando el estilo típico de las plataformas de trading.',
  ),
  heatmapCalendar(
    ChartCategory.advanced,
    'Mapa de calor calendario',
    'Pinta cada día con un color según qué tanto cambió la tasa: '
        'permite detectar de un vistazo los días más movidos del mes.',
  ),
  rangeAreaBollingerFill(
    ChartCategory.advanced,
    'Área de rango (Bollinger fill)',
    'Rellena el espacio entre la banda superior e inferior de '
        'Bollinger, para ver visualmente el "canal" de precio esperado.',
  ),
  cumulativeReturnArea(
    ChartCategory.advanced,
    'Retorno acumulado',
    'Muestra cuánto habría ganado o perdido alguien que mantuvo la '
        'posición desde el inicio del periodo hasta cada punto.',
  ),
  rsiOscillator(
    ChartCategory.advanced,
    'Oscilador RSI (14)',
    'Indicador entre 0 y 100 que mide si la tasa está '
        '"sobrecomprada" o "sobrevendida" en los últimos 14 periodos.',
  ),
  drawdownArea(
    ChartCategory.advanced,
    'Drawdown desde máximo',
    'Mide qué tan lejos está el valor actual de su punto más alto '
        'reciente: útil para ver caídas relativas, no solo absolutas.',
  );

  const ChartType(this.category, this.displayName, this.description);

  final ChartCategory category;
  final String displayName;
  final String description;

  static List<ChartType> get basics =>
      values.where((t) => t.category == ChartCategory.basic).toList();

  static List<ChartType> get advanced =>
      values.where((t) => t.category == ChartCategory.advanced).toList();
}
