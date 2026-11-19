# Frontend — Electro Industrial Flutter App

Aplicación cliente multiplataforma desarrollada en **Flutter 3.x** para la compra y venta de materiales eléctricos e industriales en Colombia.

---

## 🏛️ Estructura del Proyecto

```
frontend/
├── lib/
│   ├── data/       # Catálogo local de respaldo y respuestas del chatbot
│   ├── models/     # Entidades de dominio (Product, ProductCategory) y DTOs
│   ├── screens/    # Pantallas de la aplicación (Home, Detail, Cart, Checkout, Login)
│   ├── state/      # Gestión de estado reactivo (CartState)
│   ├── theme/      # Colores y estilos industriales (Regla 60/30/10, WCAG AA)
│   └── widgets/    # Componentes modulares y reutilizables (ProductCard)
├── test/           # Pruebas unitarias de modelos, serialización y widgets
├── analysis_options.yaml # Reglas estrictas de análisis estático y tipado
├── pubspec.yaml    # Dependencias y configuración de Flutter
└── .env.example    # Variables de entorno requeridas (API_BASE_URL)
```

---

## 🚀 Inicio Rápido

### 1. Prerrequisitos
- Flutter SDK 3.x o superior instalado.
- Dispositivo Android/iOS, emulador o soporte Linux/Chrome habilitado.

### 2. Configuración
```bash
cp .env.example .env
```

### 3. Instalación de Dependencias
```bash
flutter pub get
```

### 4. Ejecución
```bash
# Ejecutar en el dispositivo predeterminado
flutter run

# O ejecutar en navegador web
flutter run -d chrome

# O ejecutar en escritorio Linux
flutter run -d linux
```

---

## 🧪 Pruebas Automatizadas y Calidad

Ejecutar análisis estático (debe reportar 0 advertencias):
```bash
flutter analyze
```

Ejecutar la suite completa de pruebas unitarias:
```bash
flutter test
```
