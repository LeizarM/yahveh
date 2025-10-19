/// Constantes relacionadas con la API
class ApiConstants {
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/user/profile';
  static const String menu = '/vistas/menu';
  
  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String accept = 'Accept';
  
  // Values
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
}
