/// Configuración global de la aplicación
class AppConfig {
  // API Configuration
  // La URL se puede inyectar en tiempo de build SIN tocar el código:
  //   flutter build apk --dart-define=API_URL=https://api.tudominio.com/api
  // Si no se inyecta, usa el valor por defecto (entorno local de desarrollo).
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.68.51:8080/api',
  );
  static const String apiVersion = 'v1';
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000;

  // App Information
  static const String appName = 'Yahveh';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;
}
