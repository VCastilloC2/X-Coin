# X-Coin - Aplicación de Monedas Internacionales

Aplicación móvil diseñada para consultar, convertir y analizar divisas oficiales de diferentes países en tiempo real e histórico. Permite realizar conversiones de moneda, consultar información detallada, comparar tasas de cambio, visualizar rankings y examinar mediante gráficas la evolución del valor de una divisa frente a otra a lo largo del tiempo.

## Referencia

Llamadas Markdown de GitHub
Publicado en marzo de 2026
GitHub añadió sintaxis de llamadas (alertas) al GitHub Flavored Markdown. Estas cajas estilizadas resaltan información importante en la documentación — notas, consejos, advertencias y más. ShowMeMyMD es uno de los pocos visores de escritorio que las renderiza.

## La sintaxis

Cinco tipos de llamadas
Las llamadas usan sintaxis de cita con una etiqueta especial en la primera línea. El formato es siempre el mismo: > [!TYPE] seguido de tu contenido en la siguiente línea, también con prefijo >.

> [!NOTE]
> Información útil que los usuarios deberían conocer,
> incluso al ojear el contenido.

NOTE — Se renderiza como una caja de información azul. Úsala para contexto adicional que es útil pero no crítico. Piensa en información del tipo 'por cierto'.

> [!TIP]
> Consejos útiles para hacer las cosas mejor
> o más fácilmente.

TIP — Se renderiza como una caja verde de sugerencia. Úsala para mejores prácticas, atajos o recomendaciones que faciliten la vida del lector.

> [!IMPORTANT]
> Información clave que los usuarios necesitan
> saber para lograr su objetivo.

IMPORTANT — Se renderiza como una caja púrpura de énfasis. Úsala para información que es crítica de entender antes de continuar. No es una advertencia, pero es algo que no puedes omitir.

> [!WARNING]
> Info urgente que necesita atención inmediata
> del usuario para evitar problemas.

WARNING — Se renderiza como una caja de alerta amarilla. Úsala para problemas potenciales, trampas o cosas que podrían salir mal si el lector no tiene cuidado.

> [!CAUTION]
> Advierte sobre riesgos o consecuencias
> negativas de ciertas acciones.

CAUTION — Se renderiza como una caja roja de peligro. Resérvala para operaciones irreversibles, escenarios de pérdida de datos o acciones que podrían romper cosas.

## Descripción del Proyecto

### Elección de la API

Se seleccionó la API de Frankfurter porque es de código abierto, no requiere clave de autenticación (API Key) para consultas básicas, ofrece tiempos de respuesta rápidos y mantiene datos actualizados proporcionados por el Banco Central Europeo.

### Servicio e Información que Proporciona

Ofrece tasas de cambio históricas y actuales para las principales monedas del mundo. Devuelve datos estructurados en formato JSON con información sobre fechas, moneda base, monedas a comparar y los valores de conversión exactos.

> [!NOTE]
> La API de Frankfurter es el motor principal de datos de X-Coin. Se utiliza para poblar las listas desplegables de monedas disponibles, realizar los cálculos matemáticos en el conversor de divisas, generar las tablas de ranking del valor y proveer los puntos de datos (coordenadas) para dibujar las gráficas del historial de comportamiento del mercado.

### Consumo de la API

La API se consume a través de peticiones HTTP de tipo GET utilizando una arquitectura REST. Desde la aplicación móvil se implementa utilizando clientes HTTP estándar y se recibe la respuesta en formato JSON, la cual es decodificada y transformada en objetos nativos de la aplicación mediante factorías de conversión.

## Mapeo de Respuestas a Modelos

Para manejar la información recibida, la aplicación utiliza principalmente dos modelos de datos:

### Modelo para el Catálogo de Monedas

```dart
class Currency {
  final String isoCode;
  final String name;

  Currency({required this.isoCode, required this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      isoCode: json['iso_code'],
      name: json['name'],
    );
  }
}
```

### Modelo para la Conversión de Moneda (Tasa de Cambio)

```dart
class ExchangeRate {
  final String baseCurrency;
  final String quoteCurrency;
  final double rateValue;

  ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateValue,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      baseCurrency: json['base'],
      quoteCurrency: json['quote'],
      rateValue: (json['rate'] as num).toDouble(),
    );
  }
}
```

## Funciones Principales

### Conversor de Divisas
Permite convertir una cantidad de una moneda a otra consultando la tasa actual.
- Ruta: `GET https://api.frankfurter.dev/v1/latest?base=USD&quote=COP`

### Consulta de Monedas
Permite obtener el catálogo de monedas disponibles para que el usuario pueda seleccionarlas dentro de la aplicación.
- Ruta: `GET https://api.frankfurter.dev/v1/currencies`

### Ranking de Tasas
Permite consultar las tasas de cambio de múltiples monedas utilizando una moneda base como referencia.
- Ruta: `GET https://api.frankfurter.dev/v1/latest?base=COP`

### Comparación Histórica y Gráfica
Permite consultar la evolución de una moneda específica frente a una moneda base en un rango de fechas determinado para trazar las gráficas interactivas.
- Ruta: `GET https://api.frankfurter.dev/v1/2026-07-07..2026-08-12?base=USD&quote=COP`

> [!TIP]
> Puedes filtrar los rangos de tiempo de la gráfica entre 7 días, 1 semana, 1 mes, 1 año o 2 años para analizar tendencias a corto y largo plazo.

## Interfaz de Usuario y Componentes Flutter

La aplicación está diseñada siguiendo los lineamientos de Material 3 en Flutter. A continuación se detallan los widgets clave utilizados en cada pantalla:

- **AppBar & Icon:** Encabezado con título principal e identificación de la aplicación.
- **BottomNavigationBar & BottomNavigationBarItem:** Barra de navegación inferior con acceso a Inicio, Historial y Ajustes.
- **ListView & ListTile:** Presentación de preferencias del sistema (Modo Oscuro, Notificaciones, Alertas de Tasa, Moneda Base) y listas de divisas favoritas.
- **Switch:** Control interactivo para activar o desactivar el modo oscuro y notificaciones.
- **DropdownButton:** Selección de monedas de origen y destino.
- **LineChart:** Renderizado del historial de tasas de cambio a lo largo del tiempo.

> [!WARNING]
> Asegúrate de contar con conexión a internet para realizar la sincronización inicial del catálogo de monedas y actualizar las tasas en tiempo real.