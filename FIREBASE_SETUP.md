# Configuración de Firebase Authentication

## Pasos para configurar Firebase Authentication correctamente

### 1. Crear proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Crear un proyecto" o "Add project"
3. Nombra tu proyecto (ej: "mythos-app")
4. Acepta los términos y continúa
5. Configura Google Analytics (opcional)
6. Haz clic en "Crear proyecto"

### 2. Configurar Authentication

1. En el panel izquierdo, ve a **Authentication**
2. Haz clic en **Get started**
3. Ve a la pestaña **Sign-in method**
4. Habilita los métodos que quieras usar:
   - **Email/Password**: Haz clic y activa "Enable"
   - **Google**: Haz clic, activa "Enable" y configura el email de soporte

### 3. Configurar la aplicación Android

1. En el panel principal, haz clic en el ícono de Android
2. Registra tu app con estos datos:
   - **Android package name**: `com.example.mythosapp` (debe coincidir con tu app)
   - **App nickname**: "Mythos App" (opcional)
   - **Debug signing certificate SHA-1**: (opcional para desarrollo)

3. Descarga el archivo `google-services.json`
4. **IMPORTANTE**: Reemplaza el archivo actual en `android/app/google-services.json`

### 4. Configurar la aplicación iOS (si planeas usarla)

1. Haz clic en el ícono de iOS
2. Registra tu app con:
   - **iOS bundle ID**: `com.example.mythosapp`
   - **App nickname**: "Mythos App"

3. Descarga `GoogleService-Info.plist`
4. Colócalo en `ios/Runner/GoogleService-Info.plist`

### 5. Verificar configuración en el código

El código ya está configurado correctamente:
- ✅ Dependencias en `pubspec.yaml`
- ✅ Inicialización en `main.dart`
- ✅ Servicio de autenticación implementado

### 6. Configurar Google Sign-In (opcional)

Para que funcione el login con Google:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto de Firebase
3. Ve a **APIs & Services** > **Credentials**
4. Busca tu **OAuth 2.0 Client ID** para Android
5. Copia el **Client ID** y úsalo si es necesario

### 7. Probar la configuración

```bash
# Ejecutar la app
flutter run

# Si hay errores, limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

## Solución de problemas comunes

### Error: "No Firebase App '[DEFAULT]' has been created"
- Verifica que `google-services.json` esté en `android/app/`
- Asegúrate de que el package name coincida
- Ejecuta `flutter clean && flutter pub get`

### Error: "PlatformException(sign_in_failed)"
- Verifica la configuración de Google Sign-In
- Asegúrate de que el SHA-1 esté configurado (para producción)
- Verifica que Google Sign-In esté habilitado en Firebase Console

### Error: "FirebaseAuthException: invalid-email"
- Verifica que el formato del email sea correcto
- Asegúrate de que Email/Password esté habilitado en Firebase

## Archivo actual vs archivo real

**IMPORTANTE**: El archivo `google-services.json` actual contiene datos de demostración. Debes reemplazarlo con el archivo real descargado de Firebase Console para que funcione correctamente.

### Datos actuales (DEMO):
```json
{
  "project_info": {
    "project_id": "mythosapp-demo",
    "project_number": "123456789"
  }
}
```

### Necesitas reemplazar con datos reales de tu proyecto Firebase.