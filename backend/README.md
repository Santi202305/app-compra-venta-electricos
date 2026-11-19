# Backend — Electro Industrial API REST

Servidor backend desarrollado en **Node.js + TypeScript + Express** para la plataforma de compra y venta de materiales eléctricos e industriales ("Electro Industrial").

---

## 🏛️ Arquitectura por Capas

El backend sigue un diseño desacoplado de cuatro capas:
```
Routes → Controllers → Services → Repositories → Data Source (PostgreSQL)
```

1. **`src/routes/`**: Declaración de endpoints HTTP y asociación de middlewares.
2. **`src/controllers/`**: Recepción de `Request`, validación de schemas con Zod y serialización de `Response`.
3. **`src/services/`**: Lógica de negocio pura, cálculo de fletes, validación de stock y reglas técnicas RETIE.
4. **`src/repositories/`**: Abstracción del acceso a datos relacionales (PostgreSQL) y sembrado inicial.
5. **`src/models/`**: Tipos TypeScript, interfaces y esquemas de validación inmutables.
6. **`src/middlewares/`**: CORS, Helmet, autenticación y manejador centralizado de errores.

---

## 🚀 Requisitos y Configuración Local

### 1. Variables de Entorno
Copiar el archivo de plantilla a `.env`:
```bash
cp .env.example .env
```

### 2. Base de Datos PostgreSQL 16 con Docker
```bash
docker-compose up -d
```

### 3. Instalación de Dependencias
```bash
npm install
```

### 4. Ejecución en Modo Desarrollo
```bash
npm run dev
```
- API Base: `http://localhost:3000/api/v1`
- Health check: `http://localhost:3000/api/v1/health`
- Catálogo de productos: `http://localhost:3000/api/v1/products`

---

## 🧪 Pruebas Automatizadas y Calidad

Ejecutar la suite de pruebas unitarias y de integración (Jest + Supertest):
```bash
npm test
```

Ejecutar análisis de tipos TypeScript (linter):
```bash
npm run lint
```

Compilar para producción:
```bash
npm run build
```
Inicia el servidor compilado con:
```bash
npm start
```
