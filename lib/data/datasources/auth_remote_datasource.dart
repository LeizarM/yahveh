import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Interface para la fuente de datos remota de autenticación
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<void> logout();
}

/// Implementación de la fuente de datos remota de autenticación
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: {
          'login': username, // Campo esperado por la API
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        final message = response.data['message'] ?? 'Error al iniciar sesión';
        throw ServerException(_parseLoginErrorMessage(message));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          'Tiempo de espera agotado. Por favor, verifica tu conexión a internet.',
        );
      }

      if (e.type == DioExceptionType.connectionError) {
        throw ServerException(
          'No se pudo conectar al servidor. Verifica tu conexión a internet.',
        );
      }

      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? '';
        final statusCode = e.response!.statusCode;

        // Mensajes específicos según código de estado
        if (statusCode == 401) {
          throw ServerException(
            'Usuario o contraseña incorrectos. Por favor, verifica tus credenciales.',
          );
        } else if (statusCode == 404) {
          throw ServerException(
            'El usuario ingresado no existe en el sistema.',
          );
        } else if (statusCode == 403) {
          throw ServerException(
            'Tu cuenta está deshabilitada. Contacta al administrador.',
          );
        } else if (statusCode == 429) {
          throw ServerException(
            'Demasiados intentos fallidos. Espera unos minutos antes de intentar de nuevo.',
          );
        } else if (statusCode! >= 500) {
          throw ServerException(
            'Error en el servidor. Por favor, intenta más tarde.',
          );
        }

        throw ServerException(_parseLoginErrorMessage(message));
      }
      throw ServerException(
        'Error de conexión. Por favor, verifica tu internet e intenta de nuevo.',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        'Ocurrió un error inesperado. Por favor, intenta de nuevo.',
      );
    }
  }

  /// Parsea mensajes de error del servidor para hacerlos más amigables
  String _parseLoginErrorMessage(String serverMessage) {
    final lowerMessage = serverMessage.toLowerCase();

    // Si el mensaje es "Credenciales inválidas" del backend, mostrarlo directamente
    if (lowerMessage.contains('credenciales inválidas') ||
        lowerMessage.contains('credenciales invalidas')) {
      return 'Credenciales inválidas. Verifica tu usuario y contraseña.';
    }

    if (lowerMessage.contains('password') ||
        lowerMessage.contains('contraseña') ||
        lowerMessage.contains('incorrect') ||
        lowerMessage.contains('invalid')) {
      return 'Usuario o contraseña incorrectos. Por favor, verifica tus credenciales.';
    }

    if (lowerMessage.contains('user not found') ||
        lowerMessage.contains('usuario no encontrado') ||
        lowerMessage.contains('no existe')) {
      return 'El usuario ingresado no existe en el sistema.';
    }

    if (lowerMessage.contains('disabled') ||
        lowerMessage.contains('deshabilitado') ||
        lowerMessage.contains('inactive') ||
        lowerMessage.contains('inactivo')) {
      return 'Tu cuenta está deshabilitada. Contacta al administrador.';
    }

    if (lowerMessage.contains('locked') || lowerMessage.contains('bloqueado')) {
      return 'Tu cuenta ha sido bloqueada temporalmente. Intenta más tarde.';
    }

    if (serverMessage.isNotEmpty && serverMessage.length < 100) {
      return serverMessage;
    }

    return 'Error al iniciar sesión. Por favor, intenta de nuevo.';
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Ignorar errores en logout si el token ya expiró
      if (e.response?.statusCode != 401) {
        throw ServerException(
          e.response?.data['message'] ?? 'Error al cerrar sesión',
        );
      }
    }
  }
}
