/// Clase base para excepciones
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Excepción de servidor
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Excepción de caché
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Excepción de red
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Excepción de validación
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Excepción de autenticación
class AuthException extends AppException {
  const AuthException(super.message);
}
