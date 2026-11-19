# Reglas para Desarrollo en Backend (/backend)

1. **Estructura en Capas Estricta:**
   - Toda solicitud HTTP entra por `routes/` y se delega a `controllers/`.
   - `controllers/` valida entradas y delega a `services/`.
   - `services/` contiene las reglas de negocio (RETIE, inventario, fletes, transacciones) y delega la persistencia a `repositories/`.
   - `repositories/` realiza consultas SQL parametrizadas a PostgreSQL utilizando pools de conexión limpios.

2. **Tipado Estricto (TypeScript):**
   - Configuración `strict: true` en `tsconfig.json`.
   - No usar `any` salvo excepciones plenamente justificadas y aisladas.
   - Definir interfaces claras para modelos de base de datos y DTOs de request/response.

3. **Manejo de Respuestas HTTP:**
   - 200 OK: Solicitud procesada correctamente con retorno de datos.
   - 201 Created: Entidad creada exitosamente (ej. orden, producto, usuario).
   - 400 Bad Request: Error de validación en los datos de entrada con lista de errores detallada.
   - 401 Unauthorized: Ausencia o invalidez de token JWT.
   - 403 Forbidden: Token válido pero sin permisos para ejecutar la acción.
   - 404 Not Found: Recurso no encontrado.
   - 500 Internal Server Error: Error inesperado del servidor, sin revelar stack trace ni datos confidenciales.

4. **Testing Automatizado:**
   - Cada servicio debe tener cobertura de pruebas unitarias (`tests/unit/`).
   - Cada endpoint crítico (`/products`, `/orders`, `/auth`, `/health`) debe tener pruebas de integración (`tests/integration/`) con Supertest.
