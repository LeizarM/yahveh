import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/detalle_nota_entrega_model.dart';

class DetalleNotaEntregaRemoteDataSource {
  final DioClient _dioClient;

  DetalleNotaEntregaRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  /// GET /api/detalles-nota-entrega/nota/{codNotaEntrega} - Listar detalles de una nota
  Future<List<DetalleNotaEntregaModel>> listarPorNotaEntrega(int codNotaEntrega) async {
    try {
      print('📤 Solicitando detalles de nota de entrega: $codNotaEntrega');
      
      final response = await _dioClient.get('/detalles-nota-entrega/nota/$codNotaEntrega');
      
      print('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final detalles = dataList.map((json) => DetalleNotaEntregaModel.fromJson(json)).toList();
        print('✅ ${detalles.length} detalles obtenidos');
        return detalles;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar detalles');
      }
    } catch (e) {
      print('❌ Error al listar detalles: $e');
      rethrow;
    }
  }

  /// GET /api/detalles-nota-entrega/{id} - Buscar detalle por código
  Future<DetalleNotaEntregaModel> buscarPorCodigo(int codDetalle) async {
    try {
      print('📤 Buscando detalle con código: $codDetalle');
      
      final response = await _dioClient.get('/detalles-nota-entrega/$codDetalle');
      
      print('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final detalle = DetalleNotaEntregaModel.fromJson(response.data['data']);
        print('✅ Detalle encontrado');
        return detalle;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Detalle no encontrado');
      }
    } catch (e) {
      print('❌ Error al buscar detalle: $e');
      rethrow;
    }
  }

  /// POST /api/detalles-nota-entrega/nota/{codNotaEntrega} - Crear nuevo detalle
  Future<DetalleNotaEntregaModel> crear(
    int codNotaEntrega,
    DetalleNotaEntregaModel detalle,
  ) async {
    try {
      print('📤 Creando nuevo detalle para nota: $codNotaEntrega');
      print('📋 Datos: ${detalle.toCreateJson()}');
      
      final response = await _dioClient.post(
        '/detalles-nota-entrega/nota/$codNotaEntrega',
        data: detalle.toCreateJson(),
      );
      
      print('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final nuevoDetalle = DetalleNotaEntregaModel.fromJson(response.data['data']);
        print('✅ Detalle creado: ${nuevoDetalle.codDetalle}');
        return nuevoDetalle;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al crear detalle');
      }
    } catch (e) {
      print('❌ Error al crear detalle: $e');
      rethrow;
    }
  }

  /// PUT /api/detalles-nota-entrega/{id} - Actualizar detalle
  Future<DetalleNotaEntregaModel> actualizar(
    int codDetalle,
    DetalleNotaEntregaModel detalle,
  ) async {
    try {
      print('📤 Actualizando detalle: $codDetalle');
      
      final response = await _dioClient.put(
        '/detalles-nota-entrega/$codDetalle',
        data: detalle.toCreateJson(),
      );
      
      print('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final detalleActualizado = DetalleNotaEntregaModel.fromJson(response.data['data']);
        print('✅ Detalle actualizado');
        return detalleActualizado;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al actualizar detalle');
      }
    } catch (e) {
      print('❌ Error al actualizar detalle: $e');
      rethrow;
    }
  }

  /// DELETE /api/detalles-nota-entrega/{id} - Eliminar detalle
  Future<void> eliminar(int codDetalle) async {
    try {
      print('📤 Eliminando detalle: $codDetalle');
      
      final response = await _dioClient.delete('/detalles-nota-entrega/$codDetalle');
      
      print('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        print('✅ Detalle eliminado');
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al eliminar detalle');
      }
    } catch (e) {
      print('❌ Error al eliminar detalle: $e');
      rethrow;
    }
  }
}
