import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/telefono_cliente_model.dart';

/// DataSource remoto para Teléfono de Cliente
class TelefonoClienteRemoteDataSource {
  final DioClient dioClient;

  TelefonoClienteRemoteDataSource({required this.dioClient});

  /// Listar todos los teléfonos
  Future<List<TelefonoClienteModel>> listar() async {
    try {
      print('📤 GET /telefonos-cliente - Listando teléfonos');
      
      final response = await dioClient.get('/telefonos-cliente');
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List;
        return data.map((json) => TelefonoClienteModel.fromJson(json)).toList();
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al listar teléfonos: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al listar teléfonos');
    }
  }

  /// Buscar teléfono por código
  Future<TelefonoClienteModel> buscarPorCodigo(int codTlfCliente) async {
    try {
      print('📤 GET /telefonos-cliente/$codTlfCliente');
      
      final response = await dioClient.get('/telefonos-cliente/$codTlfCliente');
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        return TelefonoClienteModel.fromJson(response.data['data']);
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al buscar teléfono: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al buscar teléfono');
    }
  }

  /// Listar teléfonos por cliente
  Future<List<TelefonoClienteModel>> listarPorCliente(int codCliente) async {
    try {
      print('📤 GET /telefonos-cliente/cliente/$codCliente');
      
      final response = await dioClient.get('/telefonos-cliente/cliente/$codCliente');
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List;
        return data.map((json) => TelefonoClienteModel.fromJson(json)).toList();
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al listar teléfonos por cliente: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al listar teléfonos del cliente');
    }
  }

  /// Crear teléfono
  Future<TelefonoClienteModel> crear(TelefonoClienteModel telefono) async {
    try {
      print('📤 POST /telefonos-cliente');
      print('   Body: ${telefono.toCreateJson()}');
      
      final response = await dioClient.post(
        '/telefonos-cliente',
        data: telefono.toCreateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        print('✅ Teléfono creado exitosamente');
        return TelefonoClienteModel.fromJson(response.data['data']);
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al crear teléfono: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al crear teléfono');
    }
  }

  /// Actualizar teléfono
  Future<TelefonoClienteModel> actualizar(int codTlfCliente, TelefonoClienteModel telefono) async {
    try {
      print('📤 PUT /telefonos-cliente/$codTlfCliente');
      print('   Body: ${telefono.toUpdateJson()}');
      
      final response = await dioClient.put(
        '/telefonos-cliente/$codTlfCliente',
        data: telefono.toUpdateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      
      if (response.data != null && response.data['success'] == true) {
        print('✅ Teléfono actualizado exitosamente');
        return TelefonoClienteModel.fromJson(response.data['data']);
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al actualizar teléfono: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al actualizar teléfono');
    }
  }

  /// Eliminar teléfono
  Future<void> eliminar(int codTlfCliente) async {
    try {
      print('📤 DELETE /telefonos-cliente/$codTlfCliente');
      
      final response = await dioClient.delete('/telefonos-cliente/$codTlfCliente');
      
      if (response.data != null && response.data['success'] == true) {
        print('✅ Teléfono eliminado exitosamente');
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      print('❌ Error al eliminar teléfono: $e');
      if (e is ApiException) rethrow;
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al eliminar teléfono');
    }
  }
}
