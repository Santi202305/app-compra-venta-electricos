# App de Compra y Venta de Materiales Eléctricos e Industriales

Plataforma de comercio electrónico B2B/B2C especializada en materiales, conductores y herramientas eléctricas en Colombia, con catálogo certificado bajo normativas técnicas **RETIE** y **NTC 2050**.

---

## 🏛️ Arquitectura del Sistema

El repositorio está organizado como un monorepo desacoplado con separación estricta de responsabilidades:

```
app-compra-venta-electricos/
├── backend/            # Servidor API REST en Node.js (TypeScript) + Express
│   ├── src/            # Capas: routes → controllers → services → repositories
│   ├── tests/          # Pruebas con Jest y Supertest
│   └── docker-compose.yml # PostgreSQL 16
├── frontend/           # Aplicación cliente en Flutter 3.x (Móvil, Web, Desktop)
│   ├── lib/            # UI, estado, capa cliente API (lib/api/)
│   └── test/           # Pruebas unitarias y de widgets
├── docs/               # Especificación OpenAPI 3.0 y Plan de Arquitectura
│   ├── PLAN.md         # Plan maestro de modernización y ramas
│   └── openapi.yaml    # Contrato formal de la API REST
└── AGENTS.md           # Estándares de ingeniería, seguridad y flujo Git
```

---

## 🚀 Inicio Rápido (Desarrollo Local)

### 1. Prerrequisitos
- **Node.js**: v18+ y `npm`
- **Docker** y **Docker Compose**: para PostgreSQL 16
- **Flutter SDK**: v3.x+

### 2. Configuración de Variables de Entorno
Copiar el archivo de plantilla a `.env`:
```bash
cp .env.example .env
```

### 3. Levantar la Base de Datos y el Backend
```bash
# Iniciar PostgreSQL 16
cd backend
docker-compose up -d

# Instalar dependencias e iniciar el servidor
npm install
npm run dev
```
La API estará disponible en `http://localhost:3000/api/v1` (Health check: `http://localhost:3000/api/v1/health`).

### 4. Levantar la Aplicación Frontend
```bash
cd frontend
flutter pub get
flutter run
```

---

## 📜 Contrato de API y Documentación

- **OpenAPI 3.0 Specification:** [`docs/openapi.yaml`](docs/openapi.yaml)
- **Plan Maestro de Migración:** [`docs/PLAN.md`](docs/PLAN.md)
- **Reglas para Desarrolladores y Agentes:** [`AGENTS.md`](AGENTS.md)

---

## 🌿 Flujo de Git y Contribución

- **Rama Base:** `main` (protegida).
- **Commits:** Obligatorio seguir el estándar **Conventional Commits**:
  `tipo(alcance): descripción en imperativo` (`feat`, `fix`, `refactor`, `chore`, `docs`, `test`).
- **Pull Requests:** Todos los cambios se entregan mediante Pull Requests pequeños, con checklist de pruebas y linter aprobados.
