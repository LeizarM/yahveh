# 🔧 Solución de Problemas - Yahveh

## ✅ Correcciones Aplicadas

### 1. Configuración de Gradle actualizada
- ✅ Java 11 configurado correctamente
- ✅ Kotlin optimizado
- ✅ BuildFeatures habilitado
- ✅ Gradle properties optimizadas

### 2. Limpieza del proyecto realizada
```bash
flutter clean
cd android && ./gradlew clean
flutter pub get
```

## 🚀 Intentar Ejecutar Nuevamente

### Opción 1: Ejecutar desde VS Code
1. Asegúrate de tener un emulador/dispositivo conectado
2. Presiona `F5` o usa el botón "Run"

### Opción 2: Ejecutar desde terminal
```bash
cd "d:\Escritorio NEW\Yahveh\Yahveh Frontend\yahveh"
flutter run
```

## 🐛 Si Aún Hay Errores

### Error: "Daemon compilation failed"

**Solución 1: Invalidar caché de Gradle**
```bash
cd android
.\gradlew --stop
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**Solución 2: Actualizar Gradle Wrapper**
```bash
cd android
.\gradlew wrapper --gradle-version=8.5
cd ..
flutter run
```

**Solución 3: Borrar caché de Gradle manualmente**
```bash
# Cerrar Android Studio y VS Code
# En PowerShell:
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches"
Remove-Item -Recurse -Force ".\android\.gradle"
Remove-Item -Recurse -Force ".\android\build"
flutter clean
flutter pub get
flutter run
```

### Error: Java Version

**Verificar versión de Java:**
```bash
java -version
```

Debe mostrar Java 11 o superior. Si no:

**Windows:**
1. Descarga JDK 17: https://adoptium.net/
2. Instala y configura JAVA_HOME:
   ```powershell
   [Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Eclipse Adoptium\jdk-17.x.x", "Machine")
   ```
3. Reinicia el terminal

### Error: Kotlin Version

**Verificar settings.gradle.kts:**
Asegúrate de que el archivo `android/settings.gradle.kts` tenga:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.5.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.20" apply false
}
```

### Error: SDK no encontrado

```bash
flutter doctor -v
```

Esto mostrará todos los problemas con tu instalación de Flutter.

## 🎯 Comandos Útiles

### Verificar estado de Flutter
```bash
flutter doctor -v
```

### Limpiar completamente
```bash
flutter clean
cd android
.\gradlew clean
.\gradlew --stop
cd ..
flutter pub get
```

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ejecutar en dispositivo específico
```bash
flutter run -d <device-id>
```

### Ver logs detallados
```bash
flutter run -v
```

### Compilar sin ejecutar
```bash
flutter build apk --debug
```

## 📱 Emulador

### Iniciar emulador Android
```bash
flutter emulators
flutter emulators --launch <emulator-id>
```

### Crear nuevo emulador
```bash
flutter emulators --create --name pixel_7
```

## 🔄 Proceso de Desarrollo Recomendado

### 1. Antes de empezar cada día:
```bash
git pull
flutter pub get
flutter clean  # solo si hay problemas
```

### 2. Durante desarrollo:
- Usa Hot Reload: Presiona `r` en el terminal o `Ctrl+S` en el editor
- Usa Hot Restart: Presiona `R` en el terminal o `Ctrl+Shift+F5`

### 3. Si hay errores extraños:
```bash
flutter clean
flutter pub get
flutter run
```

## 🆘 Ayuda Adicional

### Verificar versiones
```bash
flutter --version
dart --version
java -version
```

### Actualizar Flutter
```bash
flutter upgrade
flutter pub upgrade
```

### Verificar problemas de dependencias
```bash
flutter pub outdated
```

## 📞 Contacto

Si los problemas persisten:

1. **GitHub Issues**: Crea un issue con el log completo
2. **Stack Overflow**: Busca el error específico
3. **Flutter Discord**: Pregunta en la comunidad

## 🎓 Recursos

- [Flutter Troubleshooting](https://docs.flutter.dev/testing/debugging)
- [Gradle Issues](https://docs.gradle.org/current/userguide/troubleshooting.html)
- [Android Build Issues](https://developer.android.com/studio/build/building-cmdline)

---

## ✅ Checklist Post-Corrección

- [x] Gradle properties actualizado
- [x] Build config habilitado
- [x] Java 11 configurado
- [x] Kotlin optimizado
- [x] Proyecto limpiado
- [x] Dependencias actualizadas

**Siguiente paso**: Ejecutar `flutter run` en el terminal

---

**Última actualización**: Octubre 13, 2025  
**Estado**: Configuraciones aplicadas y listas
