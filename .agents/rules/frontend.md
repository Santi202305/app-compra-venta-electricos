# Reglas para Desarrollo en Frontend (/frontend)

1. **Arquitectura Limpia en Flutter:**
   - La lógica de negocio no reside en los widgets de la interfaz gráfica.
   - Todo llamado al backend se centraliza en `lib/api/api_client.dart` y en repositorios de datos dedicados (`lib/repositories/`).
   - El estado de la aplicación se centraliza en `lib/state/` y se consume de forma reactiva y predecible.

2. **Calidad y Linter:**
   - Cero advertencias (`0 warnings, 0 info`) en `flutter analyze`.
   - No dejar imports sin utilizar, variables muertas ni código comentado obsoleto.
   - Nombrado de archivos en `snake_case`, clases en `PascalCase`, variables y funciones en `camelCase`.

3. **Accesibilidad e Identidad Visual:**
   - Cumplimiento de regla 60/30/10: 60% neutro (blanco/gris industrial), 30% corporativo (azul acero), 10% acento (amarillo/naranja de seguridad eléctrica).
   - Contraste visual mínimo de 4.5:1 (WCAG AA) en textos y botones.
   - Textos descriptivos de accesibilidad (`Semantics`) en botones e imágenes clave.

4. **Testing en Flutter:**
   - Pruebas unitarias para modelos, DTOs y validadores de formularios.
   - Pruebas de widgets para verificar renderizado correcto y manejo de estados (cargando, error, vacío, con datos).
   - Pruebas de integración visual o de responsividad (móvil, tablet, escritorio).
