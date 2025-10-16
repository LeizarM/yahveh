/// Clase base para failures (errores de negocio)
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Failure de servidor
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure de caché/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure de red (sin conexión)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Failure de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure genérico
class GenericFailure extends Failure {
  const GenericFailure(super.message);
}
