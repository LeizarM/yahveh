import 'dart:convert';

/// Utilidades para manejo de tokens JWT
class JwtUtils {
  /// Decodifica el payload de un token JWT sin verificar la firma
  /// Solo extrae la información del payload para verificar expiración
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // El payload está en la segunda parte del token
      final payload = parts[1];
      
      // Agregar padding si es necesario para base64
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un token JWT ha expirado
  /// Retorna true si el token ha expirado o es inválido
  static bool isTokenExpired(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null) {
        return true;
      }

      // Buscar el campo 'exp' (expiration time) en el payload
      final exp = (payload['exp'] as num?)?.toInt();
      if (exp == null) {
        // Sin campo de expiración (o no parseable) lo tratamos como
        // EXPIRADO/inválido por seguridad.
        return true;
      }

      // El campo 'exp' es un timestamp en segundos desde epoch
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
      );

      // Agregar un margen de 30 segundos para evitar problemas de sincronización
      final now = DateTime.now().add(const Duration(seconds: 30));
      
      return now.isAfter(expirationDate);
    } catch (e) {
      // Si hay cualquier error, consideramos el token como expirado
      return true;
    }
  }

  /// Obtiene la fecha de expiración del token
  static DateTime? getExpirationDate(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null) {
        return null;
      }

      final exp = payload['exp'];
      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el tiempo restante hasta la expiración
  static Duration? getTimeUntilExpiration(String token) {
    final expirationDate = getExpirationDate(token);
    if (expirationDate == null) {
      return null;
    }

    final now = DateTime.now();
    if (now.isAfter(expirationDate)) {
      return Duration.zero;
    }

    return expirationDate.difference(now);
  }

  /// Extrae el ID de usuario del token (si existe)
  static int? getUserId(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null) {
        return null;
      }

      // Intentar diferentes nombres de campo comunes para el ID
      return payload['userId'] as int? ??
          payload['user_id'] as int? ??
          payload['id'] as int? ??
          payload['sub'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Extrae el nombre de usuario del token (si existe)
  static String? getUsername(String token) {
    try {
      final payload = decodePayload(token);
      if (payload == null) {
        return null;
      }

      return payload['username'] as String? ??
          payload['user_name'] as String? ??
          payload['login'] as String? ??
          payload['sub'] as String?;
    } catch (e) {
      return null;
    }
  }
}
