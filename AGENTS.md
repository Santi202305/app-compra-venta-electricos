# Reglas y Estándares de Ingeniería — AGENTS.md

Este documento establece las normas obligatorias de arquitectura, seguridad, calidad y flujo de trabajo en Git para todo desarrollador y agente de Inteligencia Artificial que colabore en el repositorio `app-compra-venta-electricos`.

---

## 1. Arquitectura del Sistema

El proyecto opera bajo un modelo monorepo desacoplado:
- `/backend`: Servidor API REST en Node.js (TypeScript) + Express y base de datos PostgreSQL 16.
- `/frontend`: Aplicación cliente multiplataforma en Flutter 3.x.
- `/docs`: Contratos de API (OpenAPI 3.0), especificaciones técnicas y planes de arquitectura.

### 1.1. Backend por Capas
La arquitectura en `/backend` es estrictamente estratificada:
```
Rutas (Routes) → Controladores (Controllers) → Servicios (Services) → Repositorios (Repositories) → Base de Datos (PostgreSQL)
```
- **Rutas (`src/routes/`):** Definen endpoints HTTP y asocian middlewares de validación/autenticación. No contienen lógica.
- **Controladores (`src/controllers/`):** Reciben `Request`, extraen parámetros validados, invocan servicios y devuelven `Response` con códigos de estado HTTP semánticos (200, 201, 400, 401, 403, 404, 500). Sin lógica de negocio ni SQL.
- **Servicios (`src/services/`):** Contienen **toda la lógica de negocio**, cálculos (fletes, descuentos, validación de stock, reglas RETIE/NTC 2050). No acceden a objetos `req`/`res`.
- **Repositorios (`src/repositories/`):** Abstraen el acceso a datos. Única capa autorizada para ejecutar consultas SQL parametrizadas o interactuar con el pool de base de datos.
- **Modelos y DTOs (`src/models/`):** Interfaces TypeScript y esquemas de validación inmutables para peticiones y respuestas.

### 1.2. Frontend
- **Componentes Pequeños y Reutilizables:** Widgets con responsabilidad única en `lib/widgets/`.
- **Capa de API Centralizada:** Toda comunicación HTTP debe realizarse exclusivamente a través de la capa cliente (`lib/api/`). Queda **estrictamente prohibido** el uso de llamadas `http.get/post` dispersas dentro de widgets de UI.
- **Gestión de Estado Predecible:** Manejo de estado centralizado en `lib/state/` sin mutaciones directas fuera de los métodos del estado.
- **Diseño y Accesibilidad:** Cumplimiento de la regla cromática 60/30/10 y ratio de contraste mínimo WCAG AA (4.5:1).

---

## 2. Estándares de Seguridad

- **Cero Secretos en el Código:** Ninguna credencial, token (`GITHUB_TOKEN`, JWT Secret), clave de API o contraseña debe existir hardcodeada en el código fuente, commits, logs, READMEs o PRs.
- **Variables de Entorno:** Toda configuración sensible se gestiona vía variables de entorno. Los archivos `.env` deben estar ignorados en `.gitignore` y acompañados de un `.env.example` descriptivo con valores ficticios.
- **Token de GitHub:** Uso exclusivo en memoria para sincronización con remote o creación de PRs. Queda prohibido guardarlo de forma permanente en la URL del remote (`git remote -v` debe mostrar siempre la URL HTTPS estándar sin credenciales incrustadas).
- **Validación de Entradas (Input Sanitization):** Toda petición hacia el backend debe ser validada contra esquemas estrictos (DTOs) antes de llegar a la lógica de negocio.
- **Consultas Parametrizadas:** Protección obligatoria contra inyección SQL. Jamás concatenar variables en cadenas SQL.
- **Criptografía:** Hash de contraseñas mediante `bcrypt` o `argon2` con factor de coste adecuado.
- **CORS y Encabezados de Seguridad:** CORS restringido a los orígenes autorizados del frontend y uso de middlewares tipo Helmet.
- **Manejo Seguro de Errores:** Las respuestas de error hacia el cliente jamás deben exponer trazas internas de la pila (stack traces), queries de base de datos ni datos de infraestructura.

---

## 3. Calidad de Código y Testing

- **Análisis Estático y Linters:**
  - Backend: ESLint + Prettier configurados y ejecutados con cero advertencias antes de cada commit (`npm run lint`).
  - Frontend: `flutter analyze` debe pasar con 0 issues (`analysis_options.yaml` estricto).
- **Pruebas Automatizadas:**
  - Backend: Pruebas unitarias de servicios y pruebas de integración de endpoints críticos (`/products`, `/orders`, `/auth`, `/health`) con Jest y Supertest. Cobertura obligatoria para casos de éxito y de error.
  - Frontend: Pruebas unitarias de modelos, repositorios, estado y widgets con `flutter test`.
  - Queda prohibido degradar la cobertura existente.
- **Formato Único de Error en API:**
  ```json
  {
    "success": false,
    "error": {
      "code": "PRODUCT_NOT_FOUND",
      "message": "El producto con ID especificado no existe",
      "details": []
    }
  }
  ```

---

## 4. Flujo de Trabajo en Git

- **Rama Base:** `main`. Jamás hacer commit directo a `main` ni realizar `push --force` en ramas compartidas.
- **Nomenclatura de Ramas:**
  - `chore/<nombre>`: Configuración, herramientas, documentación base.
  - `refactor/<nombre>`: Reestructuración de código sin alterar comportamiento.
  - `feat/<nombre>`: Nuevas funcionalidades.
  - `fix/<nombre>`: Corrección de bugs o vulnerabilidades.
  - `test/<nombre>`: Incorporación o mejora de pruebas.
  - `docs/<nombre>`: Documentación y especificaciones técnicas.
- **Conventional Commits Obligatorio:**
  Formato: `tipo(alcance opcional): descripción en imperativo y minúsculas`.
  - Ejemplos:
    - `chore(repo): configurar gitignore y variables de entorno base`
    - `refactor(backend): desacoplar capa de repositorios para productos`
    - `fix(frontend): corregir compilacion de pruebas en product_test.dart`
- **Commits Atómicos:** Cada commit debe tener un propósito único, compilar correctamente y no romper tests existentes.
- **Pull Requests Revisables:**
  - Cada PR debe ser pequeño, enfocado y contener:
    - **Título en Conventional Commits.**
    - **Resumen:** Qué problema resuelve.
    - **Alcance de Cambios:** Lista concisa de archivos y componentes tocados.
    - **Cómo Verificar:** Comandos exactos ejecutados para probar funcionalidad, linter y tests.
    - **Riesgos y Plan de Rollback.**
    - **Checklist:** Lint ✔, Tests ✔, Cero Secretos ✔.
- **Aprobación y Merge:** Ningún PR debe fusionarse automáticamente. Cada PR requiere auto-revisión previa y posterior revisión/aprobación por parte del Tech Lead / usuario.
