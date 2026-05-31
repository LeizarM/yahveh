# ============================================================================
#  Build de RELEASE blindado de Yahveh (Android)
#  Uso:
#     powershell -ExecutionPolicy Bypass -File build_release.ps1 -ApiUrl "https://api.tudominio.com/api"
#
#  Qué hace:
#   - Ofusca el código Dart (--obfuscate) para dificultar la ingeniería inversa.
#   - Guarda los símbolos de des-ofuscación en .\debug-info (NO subir a git, pero
#     CONSERVAR: sirven para leer stack traces de producción).
#   - Inyecta la URL del backend por --dart-define (no queda hardcodeada).
#   - Genera tanto el APK (instalación directa) como el AAB (Play Store).
#
#  Recuerda:
#   - Tener configurado android/key.properties con tu keystore (ver .example).
#   - Para Play Store se sube el .aab; para instalar a mano, el .apk.
# ============================================================================

param(
    [string]$ApiUrl = "https://CAMBIA-ESTA-URL/api"
)

$ErrorActionPreference = "Stop"

Write-Host "==> Limpiando build anterior..." -ForegroundColor Cyan
flutter clean
flutter pub get

Write-Host "==> API_URL = $ApiUrl" -ForegroundColor Yellow

# APK ofuscado (para distribución directa / pruebas)
Write-Host "==> Construyendo APK release (ofuscado)..." -ForegroundColor Cyan
flutter build apk --release `
    --obfuscate `
    --split-debug-info=debug-info `
    --dart-define=API_URL=$ApiUrl

# AAB ofuscado (para Google Play Store)
Write-Host "==> Construyendo App Bundle (.aab) para Play Store..." -ForegroundColor Cyan
flutter build appbundle --release `
    --obfuscate `
    --split-debug-info=debug-info `
    --dart-define=API_URL=$ApiUrl

Write-Host ""
Write-Host "LISTO." -ForegroundColor Green
Write-Host "APK : build\app\outputs\flutter-apk\app-release.apk"
Write-Host "AAB : build\app\outputs\bundle\release\app-release.aab"
Write-Host "Simbolos de des-ofuscacion: .\debug-info  (consérvalos, no los subas a git)"
