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
          'login': username,  // Campo esperado por la API
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al iniciar sesión'
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Error de servidor';
        throw ServerException(message);
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Ignorar errores en logout si el token ya expiró
      if (e.response?.statusCode != 401) {
        throw ServerException(
          e.response?.data['message'] ?? 'Error al cerrar sesión'
        );
      }
    }
  }
}
