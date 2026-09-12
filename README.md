# X-Coin — Aplicación de monedas internacionales

Proyecto Flutter (Feature-First / Clean Architecture) generado a partir de los mockups y del documento "Diseño de Mockups y Consumo de una API"[cite: 1].

## Cómo ejecutar

1. `flutter pub get`
2. `flutter run`

## Estructura

Explora `lib/core` (tema, constantes, widgets globales) y `lib/features/currency_converter` (data / domain / presentation).

## API consumida

Frankfurter API (`https://api.frankfurter.dev`) — API REST pública, sin API key, documentada en el taller[cite: 1].

---

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

---

## Descripción del Proyecto

### ¿Por qué se eligió la API?

Se seleccionó la API de Frankfurter porque es de código abierto, no requiere autenticación (API Keys) para consultas básicas, ofrece tiempos de respuesta rápidos y mantiene datos actualizados proporcionados por el Banco Central Europeo[cite: 1].

### Servicio e Información que Proporciona

Ofrece tasas de cambio históricas y actuales para las principales monedas del mundo[cite: 1]. Devuelve datos estructurados en formato JSON con información sobre fechas, moneda base, monedas a comparar y los valores de conversión exactos[cite: 1].

> [!NOTE]
> La API de Frankfurter es el motor de datos de X-Coin[cite: 1]. Se utiliza para poblar las listas desplegables de monedas disponibles, realizar los cálculos matemáticos en el conversor de divisas, generar las tablas de ranking del valor y proveer los puntos de datos (coordenadas) para dibujar las gráficas del historial de comportamiento del mercado[cite: 1].

### Consumo de la API

La API se consume a través de peticiones HTTP de tipo GET utilizando una arquitectura REST[cite: 1]. Desde la aplicación móvil se implementa utilizando clientes HTTP estándar y se recibe la respuesta en formato JSON, la cual es decodificada y transformada en objetos nativos de la aplicación mediante factorías de conversión[cite: 1].

---

## Modelos de Datos

Para manejar la información recibida, la aplicación utiliza principalmente dos clases o modelos de datos[cite: 1]:

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