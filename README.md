# Electro Industrial — App de Compra y Venta de Materiales Eléctricos e Industriales

[![Tests](https://img.shields.io/badge/Tests-41%20passing%20(100%25)-success)](backend/tests/)
[![Backend Coverage](https://img.shields.io/badge/Backend%20Coverage-90.99%25-brightgreen)](backend/)
[![Frontend Linter](https://img.shields.io/badge/Flutter%20Analyze-0%20issues-blue)](frontend/)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2F%20Layered-orange)](docs/ARCHITECTURE.md)
[![API Spec](https://img.shields.io/badge/OpenAPI-3.0.3-yellow)](docs/openapi.yaml)
[![Normativa](https://img.shields.io/badge/Normativa-RETIE%20%2F%20NTC%202050-informational)](docs/)

Plataforma integral de comercio electrónico B2B y B2C especializada en materiales, conductores y herramientas eléctricas en Colombia, con catálogo certificado bajo normativas técnicas obligatorias **RETIE** (Reglamento Técnico de Instalaciones Eléctricas) y **NTC 2050**.

---

## 🏛️ Topología y Arquitectura del Sistema

El proyecto está organizado como un **Monorepo Desacoplado** con separación estricta de responsabilidades entre el cliente y el servidor:

```mermaid
graph TD
    subgraph Cliente ["Frontend (Flutter 3.x)"]
        UI["Pantallas UI (Catálogo, Detalle, Carrito, Checkout, Asistente)"]
        State["Manejo de Estado (CartState con ChangeNotifier)"]
        RepoFront["Capa Repositorios (ProductRepository, OrderRepository)"]
        ApiClient["Cliente API Centralizado (lib/api/api_client.dart)"]
        
        UI --> State
        UI --> RepoFront
        RepoFront --> ApiClient
    end

    subgraph API ["Backend API (Node.js + TypeScript + Express)"]
        Routes["Rutas REST (/products, /orders, /auth, /assistant, /health)"]
        Security["Seguridad (Helmet, CORS, ErrorHandler Centralizado)"]
        Controllers["Controladores (Validación de DTOs con Zod)"]
        Services["Servicios de Negocio (RETIE, Stock, Fletes, JWT, Bcrypt)"]
        ReposBack["Capa de Persistencia y Acceso a Datos"]
        
        Routes --> Security
        Security --> Controllers
        Controllers --> Services
        Services --> ReposBack
    end

    subgraph Persistencia ["Almacenamiento"]
        DB[(PostgreSQL 16)]
        Seed[(Catálogo Técnico RETIE)]
        
        ReposBack --> DB
        ReposBack --> Seed
    end

    ApiClient -- "HTTP / REST JSON (api/v1)" --> Routes
```

---

## 📂 Estructura de Directorios

```
app-compra-venta-electricos/
├── backend/                      # Servidor API REST independiente
│   ├── src/
│   │   ├── config/               # Variables de entorno tipadas
│   │   ├── controllers/          # Controladores HTTP y respuestas
│   │   ├── data/                 # Catálogo técnico RETIE (seed)
│   │   ├── middlewares/          # Helmet, CORS, ErrorHandler
│   │   ├── models/               # DTOs, Zod schemas y entidades
│   │   ├── repositories/         # Capa de persistencia
│   │   ├── routes/               # Rutas versionadas /api/v1
│   │   └── services/             # Lógica de negocio (stock, fletes, auth)
│   ├── tests/                    # 26 pruebas de integración y seguridad
│   ├── docker-compose.yml        # PostgreSQL 16 local
│   ├── Dockerfile                # Imagen de producción multi-stage
│   └── package.json
├── frontend/                     # Aplicación cliente Flutter desacoplada
│   ├── lib/
│   │   ├── api/                  # ApiClient con interceptores y timeouts
│   │   ├── models/               # Entidades Product con fromJson/toJson
│   │   ├── repositories/         # Consumo API con fallback offline
│   │   ├── screens/              # UI responsiva (Home, Detail, Cart, Checkout)
│   │   ├── state/                # CartState reactivo
│   │   └── theme/                # Paleta industrial 60/30/10 WCAG AA
│   ├── test/                     # 15 pruebas unitarias y de widgets
│   ├── analysis_options.yaml     # Reglas de linter estrictas (0 issues)
│   └── pubspec.yaml
├── docs/                         # Documentación técnica y contratos
│   ├── ARCHITECTURE.md           # Diseño arquitectónico detallado
│   ├── PLAN.md                   # Plan maestro y trazabilidad de PRs
│   └── openapi.yaml              # Especificación OpenAPI 3.0.3
├── AGENTS.md                     # Estándares obligatorios de ingeniería
└── README.md                     # Este portal
```

---

## 🚀 Inicio Rápido (Desarrollo Local)

### 1. Prerrequisitos
- **Node.js**: v18+ y `npm`
- **Flutter SDK**: v3.x+
- **Docker** y **Docker Compose** (opcional, para PostgreSQL)

### 2. Configuración de Entorno
```bash
# En la raíz del repositorio
cp .env.example .env
```

### 3. Ejecutar el Backend (Node.js + Express)
```bash
cd backend
npm install
npm run dev
```
- API Base: `http://localhost:3000/api/v1`
- Verificación de salud: `http://localhost:3000/api/v1/health`

### 4. Ejecutar el Frontend (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

---

## 🧪 Pruebas Automatizadas y Calidad

El proyecto cuenta con **41 pruebas automatizadas** que cubren unitarias, integración, seguridad y widgets:

### En el Backend:
```bash
cd backend
npm run lint           # Verificación de tipos TypeScript (0 errores)
npm run build          # Compilación a dist/
npm test               # 26 pruebas pasadas (100%)
npm run test:coverage  # Cobertura superior al 90%
```

### En el Frontend:
```bash
cd frontend
flutter analyze        # Análisis estático (0 issues)
flutter test           # 15 pruebas unitarias y de widgets pasadas (100%)
```

---

## 📜 Contratos y Documentación Técnica

- [**`docs/ARCHITECTURE.md`**](docs/ARCHITECTURE.md): Documento de diseño arquitectónico y diagramas Mermaid.
- [**`docs/openapi.yaml`**](docs/openapi.yaml): Especificación OpenAPI 3.0.3 completa.
- [**`docs/PLAN.md`**](docs/PLAN.md): Plan maestro de 6 fases y Pull Requests.
- [**`AGENTS.md`**](AGENTS.md): Reglas de ingeniería, seguridad y flujo Git.

---

## 🌿 Trazabilidad de Pull Requests

El proyecto fue desarrollado y entregado mediante un flujo de trabajo de equipo real con Conventional Commits:

1. [**PR #2: `chore: configuracion inicial de estandares, reglas de agentes y documentacion`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/2)
2. [**PR #3: `refactor(backend): inicializar paquete backend con arquitectura en capas, express, typescript y tests`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/3)
3. [**PR #4: `refactor(frontend): migrar aplicacion flutter a frontend, corregir linter y pruebas unitarias`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/4)
4. [**PR #5: `feat: conectar frontend a api rest, implementar auth con jwt y gestion de ordenes`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/5)
5. [**PR #6: `test: incorporar pruebas de seguridad en backend y pruebas unitarias/widgets en frontend`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/6)
6. [**PR #7: `docs: documentacion final de arquitectura, dockerfile y cierre de ingenieria`**](https://github.com/Santi202305/app-compra-venta-electricos/pull/7)
