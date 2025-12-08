import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/usuario_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';

class UsuarioRemoteDataSource {
  final DioClient _dioClient;

  UsuarioRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  /// GET /api/usuarios - Listar todos los usuarios
  Future<List<UsuarioModel>> listar() async {
    try {
      console('📤 Solicitando lista de usuarios...');

      final response = await _dioClient.get('/usuarios');

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final usuarios =
            dataList.map((json) => UsuarioModel.fromJson(json)).toList();
        console('✅ ${usuarios.length} usuarios obtenidos');
        return usuarios;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Error al listar usuarios');
      }
    } catch (e) {
      console('❌ Error al listar usuarios: $e');
      rethrow;
    }
  }

  /// GET /api/usuarios/{id} - Buscar usuario por código
  Future<UsuarioModel> buscarPorCodigo(int codUsuario) async {
    try {
      console('📤 Buscando usuario con código: $codUsuario');

      final response = await _dioClient.get('/usuarios/$codUsuario');

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        final usuario = UsuarioModel.fromJson(response.data['data']);
        console('✅ Usuario encontrado');
        return usuario;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Usuario no encontrado');
      }
    } catch (e) {
      console('❌ Error al buscar usuario: $e');
      rethrow;
    }
  }

  /// POST /api/usuarios - Crear nuevo usuario
  Future<int> crear({
    required int codEmpleado,
    required String login,
    required String password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      console('📤 Creando nuevo usuario...');

      final data = {
        "codEmpleado": codEmpleado,
        "login": login,
        "password": password,
        "tipoUsuario": tipoUsuario,
        "estado": estado,
      };

      console('📋 Datos: $data');

      final response = await _dioClient.post(
        '/usuarios',
        data: data,
      );

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        final nuevoId = response.data['data'] as int;
        console('✅ Usuario creado: $nuevoId');
        return nuevoId;
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      console('❌ Error al crear usuario: $e');
      rethrow;
    }
  }

  /// PUT /api/usuarios/{id} - Actualizar usuario
  Future<void> actualizar({
    required int codUsuario,
    required int codEmpleado,
    required String login,
    String? password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      console('📤 Actualizando usuario: $codUsuario');

      final data = {
        "codEmpleado": codEmpleado,
        "login": login,
        "tipoUsuario": tipoUsuario,
        "estado": estado,
      };

      if (password != null && password.isNotEmpty) {
        data["password"] = password;
      }

      final response = await _dioClient.put(
        '/usuarios/$codUsuario',
        data: data,
      );

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        console('✅ Usuario actualizado');
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Error al actualizar usuario');
      }
    } catch (e) {
      console('❌ Error al actualizar usuario: $e');
      rethrow;
    }
  }

  /// DELETE /api/usuarios/{id} - Eliminar usuario
  Future<void> eliminar(int codUsuario) async {
    try {
      console('📤 Eliminando usuario: $codUsuario');

      final response = await _dioClient.delete('/usuarios/$codUsuario');

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        console('✅ Usuario eliminado');
      } else {
        throw ApiException(
            message: response.data['message'] ?? 'Error al eliminar usuario');
      }
    } catch (e) {
      console('❌ Error al eliminar usuario: $e');
      rethrow;
    }
  }
}
