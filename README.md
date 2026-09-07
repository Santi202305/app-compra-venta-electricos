# App de compra y venta de materiales eléctricos e industriales

Proyecto académico — UCEVA, Ingeniería de Sistemas, Electiva Profesional I.

> El proyecto todavía no tiene un nombre comercial definitivo. Este README
> se actualizará cuando el equipo lo defina.

## Descripción

Aplicación móvil que permite a electricistas, contratistas y dueños de
casa buscar, cotizar y comprar materiales y herramientas eléctricas, con
carrito de compras, checkout y un asistente virtual (bot de preguntas
frecuentes) disponible 24/7.

## Stack tecnológico

- **Frontend móvil:** Flutter
- **Backend (por integrar):** Spring Boot (API REST)
- **Base de datos (por integrar):** PostgreSQL
- **Pagos (por integrar):** pasarela agregadora (Wompi/PayU/ePayco) para
  Nequi y Efecty

## Estado actual

Esta es la **estructura inicial del proyecto**: la app corre de forma
independiente con datos de catálogo simulados (`lib/data/products.dart`),
sin conexión todavía al backend. Sirve como base para ir conectando cada
funcionalidad real por Pull Request.

## Pantallas incluidas

1. Ingreso (login simple, sin autenticación real todavía)
2. Catálogo con filtro por categoría
3. Detalle de producto
4. Carrito de compras
5. Checkout (selección de método de pago)
6. Confirmación de pedido
7. Asistente virtual (bot de preguntas frecuentes)

## Cómo correr el proyecto

```bash
flutter pub get
flutter run
```

## Estructura de carpetas

```
lib/
  data/       # datos de ejemplo (catálogo, respuestas del bot)
  models/     # modelos de datos (Product)
  screens/    # una pantalla por archivo
  state/      # estado de la app (CartState)
  theme/      # colores y tema visual
  widgets/    # widgets reutilizables (ProductCard)
```

## Flujo de ramas

- `main`: rama protegida, solo recibe cambios vía Pull Request aprobado.
- `develop`: rama de integración de funcionalidades.
- `feature/<nombre>`: una rama por funcionalidad, creada desde `develop`.
- `fix/<nombre>`: corrección puntual de errores.
