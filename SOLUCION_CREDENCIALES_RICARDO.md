# Solución: Problema con Credenciales de Ricardo

## 🔍 Diagnóstico del Problema

He identificado por qué las credenciales de "ricardo" no funcionan:

### El Problema
La aplicación actualmente tiene **credenciales fijas** definidas en el código para el modo de desarrollo:
- **Email válido:** `test@mythos.com`
- **Contraseña válida:** `123456`

Cualquier otra combinación de credenciales (incluyendo "ricardo") será rechazada con el mensaje "Credenciales incorrectas".

## 🛠️ Soluciones Disponibles

### Opción 1: Usar las Credenciales Correctas (Más Rápido)
**Prueba con estas credenciales:**
- **Email:** `test@mythos.com`
- **Contraseña:** `123456`

Esto debería funcionar inmediatamente.

### Opción 2: Crear Usuario "Ricardo" en Firebase Console
Si quieres usar específicamente las credenciales de "ricardo":

1. **Ve a Firebase Console:**
   - Abre [Firebase Console](https://console.firebase.google.com/)
   - Selecciona tu proyecto "MythosApp"

2. **Crear el usuario:**
   - Ve a **Authentication** → **Users**
   - Haz clic en **"Add user"**
   - Ingresa:
     - **Email:** `ricardo@mythos.com` (o el email que prefieras)
     - **Password:** La contraseña que quieras usar
   - Haz clic en **"Add user"**

3. **Probar en la app:**
   - Usa las credenciales que acabas de crear
   - Ahora debería funcionar con Firebase real

### Opción 3: Modificar las Credenciales de Prueba en el Código
Si quieres cambiar las credenciales de desarrollo:

1. **Editar el archivo:** `lib/services/auth_service.dart`
2. **Cambiar las líneas 18-20:**
   ```dart
   // Cambiar de:
   static const String testEmail = 'test@mythos.com';
   static const String testPassword = '123456';
   
   // A:
   static const String testEmail = 'ricardo@mythos.com';
   static const String testPassword = 'tu_password_aqui';
   ```
3. **Reiniciar la app:** `flutter run`

## 🧪 Cómo Verificar Qué Modo Está Usando

### Modo Firebase (Producción)
- Si ves usuarios reales en Firebase Console
- Los logs muestran "Firebase Auth disponible"
- Puedes crear usuarios nuevos desde la app

### Modo Desarrollo (Offline)
- Solo funciona con credenciales fijas
- Los logs muestran "Firebase no disponible, usando modo desarrollo"
- No se crean usuarios reales

## 📋 Pasos Recomendados

1. **Primero:** Prueba con `test@mythos.com` / `123456`
2. **Si funciona:** El problema son las credenciales, no la app
3. **Si no funciona:** Hay un problema técnico más profundo
4. **Para usar "ricardo":** Crea el usuario en Firebase Console

## 🔧 Comandos Útiles

```bash
# Ver logs detallados para diagnosticar
flutter run --verbose

# Limpiar caché si hay problemas
flutter clean
flutter pub get
flutter run
```

## 📞 Estado Actual

✅ **Configuración técnica:** Funcionando correctamente  
✅ **Firebase:** Configurado y disponible  
❌ **Credenciales "ricardo":** No existen en el sistema  
✅ **Credenciales de prueba:** `test@mythos.com` disponibles  

**Conclusión:** La app funciona perfectamente, solo necesitas usar las credenciales correctas o crear el usuario "ricardo" en Firebase Console.