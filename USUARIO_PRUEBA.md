# Usuario de Prueba - Mythos App

## Información del Usuario de Prueba

Para probar la aplicación sin necesidad de Firebase, se ha configurado un usuario de prueba predefinido:

### Credenciales de Acceso
- **Email:** `test@mythos.com`
- **Contraseña:** `123456`
- **Nombre:** `Usuario de Prueba`

## Cómo Usar

### Iniciar Sesión
1. Abre la aplicación
2. Ve a la pantalla de login
3. Ingresa las credenciales:
   - Email: `test@mythos.com`
   - Contraseña: `123456`
4. Presiona "Iniciar Sesión"

### Registro
También puedes registrar nuevos usuarios de prueba:
1. Ve a la pantalla de registro
2. Ingresa cualquier email y contraseña
3. El sistema creará un usuario simulado automáticamente

## Funcionalidades Disponibles

Con el usuario de prueba puedes acceder a todos los módulos de la aplicación:
- ✅ Dashboard principal
- ✅ Módulo de juegos
- ✅ Configuraciones
- ✅ Perfil de usuario
- ✅ Navegación entre módulos

## Modo de Desarrollo

La aplicación detecta automáticamente si Firebase está disponible:
- **Con Firebase:** Usa autenticación real
- **Sin Firebase:** Usa el sistema de usuarios simulados

Esto permite desarrollar y probar la aplicación sin necesidad de configurar Firebase.

## Notas Técnicas

- Los usuarios simulados se almacenan solo en memoria
- Al cerrar la aplicación, se pierde la sesión simulada
- Las credenciales del usuario de prueba están definidas en `AuthService`
- El sistema es completamente funcional para desarrollo y testing