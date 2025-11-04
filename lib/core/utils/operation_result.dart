/// Clase para encapsular el resultado de una operación con su mensaje
class OperationResult<T> {
  final T data;
  final String message;

  const OperationResult({
    required this.data,
    required this.message,
  });
}
