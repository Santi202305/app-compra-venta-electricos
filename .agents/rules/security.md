# Reglas de Seguridad y Manejo de Secretos

1. **Gestión de Secretos:**
   - Prohibido commitear credenciales, llaves privadas, strings de conexión o tokens de GitHub/JWT.
   - Archivos de secretos (`.env`, `.env.local`, `.env.production`) deben figurar en `.gitignore`.
   - Cada repositorio/paquete debe proveer un `.env.example` con valores de plantilla seguros para desarrollo.

2. **Mitigación de Vulnerabilidades Web/API:**
   - **Inyección SQL:** Utilizar exclusivamente consultas parametrizadas (`$1, $2, ...` con `pg`) o query builders seguros. Nunca interpolar variables en strings SQL.
   - **XSS:** Sanear entradas y configurar encabezados HTTP seguros (`helmet`, `Content-Security-Policy`).
   - **CORS:** Restringir orígenes permitidos en producción; en desarrollo habilitar explícitamente solo el cliente frontend.
   - **Fuerza Bruta / DoS:** Implementar rate limiting en endpoints de autenticación (`/auth/login`, `/auth/register`).

3. **Autenticación y Autorización:**
   - Hashing de contraseñas con `bcrypt` (mínimo 10 rondas de salt).
   - Tokens JWT firmados con algoritmos seguros (`HS256` o `RS256`), con tiempo de expiración corto (ej. 1h o 24h) y clave secreta robusta de más de 32 caracteres.
   - Headers de autorización estándar: `Authorization: Bearer <token>`.
