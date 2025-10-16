# Configuración de la API

## 🌐 Endpoint de Autenticación

### Base URL
```
http://localhost:8080/api
```

### Login Endpoint
```
POST /auth/login
```

### Request Body
```json
{
  "login": "admin",
  "password": "admin123"
}
```

### Response Esperada
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tipoUsuario": "admin",
    "codUsuario": 1,
    "nombreCompleto": "Administrador del Sistema"
  }
}
```

## 📋 Campos del Usuario

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `login` | String | Usuario para autenticación |
| `password` | String | Contraseña del usuario |
| `codUsuario` | int | Código único del usuario |
| `nombreCompleto` | String | Nombre completo del usuario |
| `tipoUsuario` | String | Tipo/rol del usuario |
| `token` | String | JWT token para autenticación |

## 🔐 Manejo de Token

### Almacenamiento
- El token se guarda automáticamente en `FlutterSecureStorage`
- Key: `auth_token`

### Uso Automático
- El `DioClient` agrega automáticamente el header:
  ```
  Authorization: Bearer {token}
  ```
- Se aplica a todas las peticiones excepto `/login`

### Expiración (401)
- Cuando el servidor responde con 401:
  1. Se ejecuta el callback `onUnauthorized`
  2. Se limpia el token del storage
  3. Se redirige automáticamente al login

## 🎯 Flujo de Autenticación

```
1. Usuario ingresa login y password
   ↓
2. LoginScreen envía request a /auth/login
   ↓
3. API valida credenciales
   ↓
4. API responde con { success, message, data: { token, ... } }
   ↓
5. DioClient intercepta la respuesta
   ↓
6. DioClient guarda el token en storage
   ↓
7. AuthProvider actualiza el estado con AsyncValue.data(user)
   ↓
8. LoginScreen escucha el cambio y redirige a HomeScreen
   ↓
9. HomeScreen muestra datos del usuario autenticado
```

## 🧪 Pruebas

### Credenciales de Prueba
```
Login: admin
Password: admin123
```

### Verificar Conexión
1. Asegúrate de que tu API esté corriendo en `http://localhost:8080`
2. Ejecuta la app: `flutter run`
3. Ingresa las credenciales de prueba
4. Verifica que se redirija al HomeScreen con los datos correctos

## 🛠️ Cambiar URL de Producción

Cuando estés listo para producción, actualiza:

**Archivo:** `lib/core/config/app_config.dart`

```dart
static const String baseUrl = 'https://tu-api-produccion.com/api';
```

## 📱 Estados de la Aplicación

### AsyncValue States

| Estado | Descripción | UI |
|--------|-------------|-----|
| `loading` | Request en proceso | CircularProgressIndicator |
| `data(user)` | Login exitoso | Redirección a HomeScreen |
| `error(e)` | Error en login | SnackBar con mensaje de error |

### Manejo de Errores

- **ServerException**: Error del servidor (mensaje personalizado)
- **DioException**: Error de red/conexión
- **401 Unauthorized**: Token expirado (logout automático)

## 🔍 Debug

Para ver los logs de las peticiones HTTP, verifica la consola:

```
🚀 Request: POST /auth/login
📦 Data: {login: admin, password: admin123}
✅ Response: 200 /auth/login
💾 Token guardado automáticamente
```

## ⚠️ Notas Importantes

1. **Campo de Login**: La API espera el campo `login`, no `email` ni `username`
2. **Token Automático**: El DioClient maneja automáticamente el guardado y envío del token
3. **Localhost**: Si pruebas en dispositivo físico, usa la IP de tu computadora en lugar de `localhost`
   ```dart
   static const String baseUrl = 'http://192.168.1.X:8080/api';
   ```
