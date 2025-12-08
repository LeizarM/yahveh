import 'package:flutter/foundation.dart';

import '../error/api_exception.dart';

/// Utilidad para convertir errores técnicos en mensajes amigables para el usuario
class ErrorMessages {
  /// Convierte un error técnico en un mensaje amigable
  static String getFriendlyMessage(dynamic error) {
    // Si es ApiException, usar su mensaje directamente (viene del backend)
    if (error is ApiException) {
      return error.message;
    }

    final errorStr = error.toString().toLowerCase();

    // Errores de red/conexión
    if (errorStr.contains('socketexception') || 
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
    }

    // Timeout
    if (errorStr.contains('timeout')) {
      return 'La solicitud tardó demasiado. Por favor, intenta nuevamente.';
    }

    // Error 401 - No autorizado
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
    }

    // Error 403 - Prohibido
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'No tienes permisos para realizar esta acción.';
    }

    // Error 404 - No encontrado
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'No se encontró el recurso solicitado.';
    }

    // Error 500 - Error del servidor
    if (errorStr.contains('500') || errorStr.contains('server error')) {
      return 'Error en el servidor. Por favor, intenta más tarde.';
    }

    // Error de validación
    if (errorStr.contains('validation') || errorStr.contains('invalid')) {
      return 'Los datos ingresados no son válidos. Por favor, verifica la información.';
    }

    // Error de duplicado
    if (errorStr.contains('duplicate') || 
        errorStr.contains('already exists') ||
        errorStr.contains('unique constraint')) {
      return 'Este registro ya existe en el sistema.';
    }

    // Error DioException específico
    if (errorStr.contains('dioexception')) {
      if (errorStr.contains('bad response')) {
        return 'Error al procesar la solicitud. Por favor, intenta nuevamente.';
      }
      if (errorStr.contains('bad certificate')) {
        return 'Error de seguridad en la conexión.';
      }
    }

    // Mensaje genérico para otros errores
    return 'Ocurrió un error inesperado. Por favor, intenta nuevamente o contacta al soporte.';
  }

  /// Obtiene un mensaje específico para operaciones CRUD
  static String getCrudErrorMessage(String operation, dynamic error) {
    final baseMessage = getFriendlyMessage(error);
    
    switch (operation) {
      case 'create':
        return 'No se pudo crear el registro. $baseMessage';
      case 'update':
        return 'No se pudo actualizar el registro. $baseMessage';
      case 'delete':
        return 'No se pudo eliminar el registro. $baseMessage';
      case 'load':
        return 'No se pudieron cargar los datos. $baseMessage';
      default:
        return baseMessage;
    }
  }

}

void console(Object? object) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(object);
  }
}