# Plan Maestro de Separación Backend / Frontend y Modernización Arquitectónica
## Repositorio: `app-compra-venta-electricos`

---

## 1. Justificación de Stack y Arquitectura

Tras la auditoría técnica de la Fase 0 y la decisión del Tech Lead:
- **Frontend:** **Flutter 3.x** en `/frontend`. Mantiene la compatibilidad multiplataforma (Móvil, Web y Linux Desktop), el diseño industrial con accesibilidad WCAG AA y la interfaz adaptativa.
- **Backend:** **Node.js (TypeScript) + Express** en `/backend`. Ofrece tipado estricto de extremo a extremo, alta velocidad de desarrollo, consumo mínimo de recursos frente a JVM, y ejecución desacoplada en contenedores Docker.
- **Base de Datos:** **PostgreSQL 16** gestionada con `docker-compose.yml`, con esquema relacional para productos, categorías, usuarios y órdenes de compra, sembrada inicialmente con los 35 productos técnicos certificados bajo normativa RETIE / NTC 2050.
- **Contrato de Comunicación:** **RESTful API** en formato JSON, versionada bajo `/api/v1`, tipada y documentada formalmente en OpenAPI 3.0 (`docs/openapi.yaml`).

---

## 2. Estructura Final de Carpetas

```
app-compra-venta-electricos/
├── backend/                      # Paquete independiente del servidor API REST
│   ├── .env.example              # Variables de entorno requeridas (PORT, DB_*, JWT_SECRET)
│   ├── .gitignore
│   ├── package.json
│   ├── tsconfig.json
│   ├── docker-compose.yml        # PostgreSQL 16 local
│   ├── Dockerfile                # Despliegue en producción multi-stage
│   ├── src/
│   │   ├── config/               # Configuración de entorno y conexión
│   │   ├── controllers/          # Controladores HTTP (Request/Response con Zod)
│   │   ├── middlewares/          # Autenticación JWT, CORS, Helmet, ErrorHandler
│   │   ├── models/               # Definición de entidades, DTOs e interfaces
│   │   ├── repositories/         # Capa de acceso a datos y persistencia
│   │   ├── routes/               # Rutas Express (/products, /auth, /orders, /assistant)
│   │   ├── services/             # Lógica de negocio (stock, fletes, autenticación)
│   │   ├── data/                 # Seed inicial del catálogo técnico RETIE
│   │   └── app.ts / server.ts    # Configuración y arranque del servidor
│   ├── tests/                    # 26 pruebas de integración y seguridad con Jest/Supertest
│   └── README.md                 # Guía paso a paso para levantar el backend
├── frontend/                     # Aplicación cliente Flutter desacoplada
│   ├── .env.example              # API_BASE_URL=http://localhost:3000/api/v1
│   ├── .gitignore
│   ├── analysis_options.yaml     # Reglas de linter estrictas (0 issues)
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── api/                  # ApiClient HTTP centralizado y manejo de errores
│   │   ├── models/               # Modelos de dominio inmutables con fromJson/toJson
│   │   ├── repositories/         # ProductRepository y OrderRepository con fallback
│   │   ├── screens/              # Pantallas responsivas de la app
│   │   ├── state/                # AppState y CartState
│   │   ├── theme/                # Tema industrial 60/30/10 WCAG AA
│   │   └── widgets/              # Widgets reutilizables
│   ├── test/                     # 15 pruebas unitarias, de modelos y widgets
│   └── README.md                 # Guía paso a paso para ejecutar el frontend
├── docs/
│   ├── PLAN.md                   # Este plan maestro de arquitectura
│   ├── ARCHITECTURE.md           # Diseño técnico detallado y diagramas
│   └── openapi.yaml              # Especificación técnica OpenAPI 3.0 de la API
├── AGENTS.md                     # Estándares obligatorios para agentes y desarrolladores
├── .gitignore                    # Reglas globales de exclusión Git
└── README.md                     # Portal raíz con visión general y quickstart integral
```

---

## 3. Estado de Ejecución de Pull Requests

| PR # | Rama | Tipo | Resumen del Alcance | Estado en GitHub |
| :---: | :--- | :---: | :--- | :---: |
| **1** | `chore/bootstrap-standards` | `chore` | `AGENTS.md`, `.gitignore`, `.env.example`, `docs/PLAN.md`, `docs/openapi.yaml` | [PR #2 (Merged)](https://github.com/Santi202305/app-compra-venta-electricos/pull/2) |
| **2** | `refactor/setup-backend-core` | `refactor` | Paquete `/backend`, Express, TypeScript, capas, catálogo RETIE y tests | [PR #3 (Merged)](https://github.com/Santi202305/app-compra-venta-electricos/pull/3) |
| **3** | `refactor/migrate-frontend-structure` | `refactor` | Mover Flutter a `/frontend`, corregir `product_test.dart` y 0 linter issues | [PR #4 (Merged)](https://github.com/Santi202305/app-compra-venta-electricos/pull/4) |
| **4** | `feat/connect-api-auth-orders` | `feat` | Conectar Flutter a REST API con `ApiClient`, auth JWT y módulo de orders | [PR #5 (Merged)](https://github.com/Santi202305/app-compra-venta-electricos/pull/5) |
| **5** | `test/security-and-e2e-coverage` | `test` | Pruebas de seguridad (SQLi, Helmet, JWT), widgets en Flutter y cobertura > 90% | [PR #6 (Merged)](https://github.com/Santi202305/app-compra-venta-electricos/pull/6) |
| **6** | `docs/final-handover` | `docs` | `ARCHITECTURE.md`, Dockerfile, README final y reporte de cierre | [PR #7 (En revisión)](https://github.com/Santi202305/app-compra-venta-electricos/pull/7) |

---

## 4. Riesgos Identificados y Mitigaciones Implementadas

| Riesgo | Probabilidad / Impacto | Mitigación Implementada | Estado |
| :--- | :---: | :--- | :---: |
| **Inaccesibilidad del backend en desarrollo** | Media / Alto | `ProductRepository` y `OrderRepository` implementan fallback local automático y resiliente. | Mitigado y Verificado en tests |
| **Ruptura de funcionalidades existentes** | Baja / Crítico | Todos los widgets se preservaron y los tests de pantalla (`HomeScreen`, `ProductCard`) pasan al 100%. | Mitigado y Verificado |
| **Filtración de credenciales / Secrets** | Baja / Crítico | Token manejado solo en memoria; `.env` ignorado; ningún hash ni token expuesto. | Auditado con éxito |
