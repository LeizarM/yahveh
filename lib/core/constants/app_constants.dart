/// Constantes generales de la aplicación
class AppConstants {
  // Routes
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  
  // Messages
  static const String genericError = 'Ha ocurrido un error. Por favor, intenta de nuevo.';
  static const String noInternetConnection = 'No hay conexión a internet';
  static const String sessionExpired = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
}
