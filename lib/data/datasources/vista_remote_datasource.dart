import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/vista_model.dart';

/// Interface para la fuente de datos remota de vistas
abstract class VistaRemoteDataSource {
  /// Menú del usuario autenticado (solo sus vistas permitidas)
  Future<List<VistaModel>> getMenu();

  /// Admin: todas las vistas del sistema
  Future<List<VistaModel>> getAllVistas();

  /// Admin: vistas asignadas a un usuario específico
  Future<List<VistaModel>> getVistasDeUsuario(int codUsuario);

  /// Admin: reemplaza las vistas de un usuario
  Future<void> setVistasDeUsuario(int codUsuario, List<int> codVistas);
}

/// Implementación de la fuente de datos remota de vistas
class VistaRemoteDataSourceImpl implements VistaRemoteDataSource {
  final DioClient client;

  VistaRemoteDataSourceImpl(this.client);

  @override
  Future<List<VistaModel>> getMenu() async {
    try {
      final response = await client.post(ApiConstants.menu);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => VistaModel.fromJson(json)).toList();
      }
      throw ServerException(response.data['message'] ?? 'Error al obtener el menú');
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Error de servidor');
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<List<VistaModel>> getAllVistas() async {
    try {
      final response = await client.get(ApiConstants.vistasAdminTodas);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => VistaModel.fromJson(json)).toList();
      }
      throw ServerException(response.data['message'] ?? 'Error al obtener vistas');
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Error de servidor');
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<List<VistaModel>> getVistasDeUsuario(int codUsuario) async {
    try {
      final response = await client.get(ApiConstants.vistasAdminUsuario(codUsuario));
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => VistaModel.fromJson(json)).toList();
      }
      throw ServerException(response.data['message'] ?? 'Error al obtener vistas del usuario');
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Error de servidor');
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> setVistasDeUsuario(int codUsuario, List<int> codVistas) async {
    try {
      final response = await client.put(
        ApiConstants.vistasAdminUsuario(codUsuario),
        data: {'codVistas': codVistas},
      );
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(response.data['message'] ?? 'Error al actualizar permisos');
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Error de servidor');
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Error inesperado: $e');
    }
  }
}
