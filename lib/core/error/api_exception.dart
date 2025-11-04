/// Excepción personalizada para errores de API
/// Preserva el mensaje original del backend
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;

  /// Crea una excepción desde una respuesta del backend
  factory ApiException.fromResponse(Map<String, dynamic>? response, [int? statusCode]) {
    if (response == null) {
      return ApiException(
        message: 'Error desconocido - respuesta vacía del servidor',
        statusCode: statusCode,
        originalError: null,
      );
    }
    
    return ApiException(
      message: response['message'] as String? ?? 'Error desconocido',
      statusCode: statusCode,
      originalError: response,
    );
  }

  /// Crea una excepción desde un error genérico
  factory ApiException.fromError(dynamic error, [String? defaultMessage]) {
    if (error is ApiException) {
      return error;
    }
    
    return ApiException(
      message: defaultMessage ?? error.toString(),
      originalError: error,
    );
  }
}
