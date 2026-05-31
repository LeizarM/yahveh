# ============================================================================
# Reglas ProGuard / R8 para el build release de Yahveh
# Objetivo: ofuscar y reducir el wrapper Android sin romper Flutter ni plugins.
# ============================================================================

# --- Flutter engine / embedding ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# --- Mantener nombres de clases con métodos nativos (JNI) ---
-keepclasseswithmembernames class * {
    native <methods>;
}

# --- Anotaciones y atributos necesarios ---
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# --- flutter_secure_storage (usa el Keystore de Android vía canales de plataforma) ---
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# --- Tink / AndroidX Security (cifrado usado por secure storage) ---
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# --- Suprimir warnings de javax/annotations opcionales ---
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# --- Mantener enums (evita problemas de valueOf) ---
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# --- Parcelables ---
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
