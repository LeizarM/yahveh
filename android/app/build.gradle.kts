import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ============================================================================
// Firma de release: se cargan las credenciales desde android/key.properties
// (archivo NO versionado). Si no existe, se usa la firma debug para que
// `flutter run --release` siga funcionando en local SIN configuración extra.
// Para publicar en Play Store / generar un APK distribuible, crea el keystore
// y el archivo key.properties (ver android/key.properties.example).
// ============================================================================
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // TODO PLAY STORE: cambiar "com.example.yahveh" por un ID propio definitivo
    // (ej. "com.tuempresa.yahveh"). Play Store RECHAZA paquetes con "com.example".
    // Al cambiarlo, mover también la carpeta de MainActivity.kt al paquete nuevo.
    namespace = "com.example.yahveh"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.example.yahveh"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Default del placeholder para todos los build types (debug/profile/release).
        // Se sobrescribe en release a "false".
        manifestPlaceholders["usesCleartextTraffic"] = "true"
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("debug") {
            // En desarrollo se permite tráfico HTTP en claro (backend local sin TLS).
            manifestPlaceholders["usesCleartextTraffic"] = "true"
        }
        getByName("release") {
            // Firma real si existe el keystore; si no, debug (solo para pruebas locales).
            signingConfig = if (hasReleaseKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            // --- Blindaje contra ingeniería inversa ---
            // R8: ofusca y elimina código/recursos no usados del wrapper Android.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // En release se BLOQUEA el tráfico HTTP en claro: obliga a usar HTTPS.
            manifestPlaceholders["usesCleartextTraffic"] = "false"

            // No incluir símbolos de depuración nativos en el binario distribuido.
            ndk {
                debugSymbolLevel = "none"
            }
        }
    }
}

flutter {
    source = "../.."
}
