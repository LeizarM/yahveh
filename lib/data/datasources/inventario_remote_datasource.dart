import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/inventario_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';


/// Interfaz del datasource remoto de Inventario
abstract class InventarioRemoteDataSource {
  Future<List<InventarioModel>> listar();
  Future<InventarioModel> buscarPorCodigo(int codInventario);
  Future<List<InventarioModel>> listarPorArticulo(String codArticulo);
  Future<List<InventarioModel>> listarPorTipo(String tipoMovimiento);
  Future<List<InventarioModel>> listarPorFechas({
    required DateTime? desde,
    required DateTime? hasta,
  });
  Future<OperationResult<InventarioModel>> crear({
    required String codArticulo,
    required String tipoMovimiento,
    required int cantidad,
    required double precioUnitario,
    String? observacion,
  });
  Future<OperationResult<InventarioModel>> modificar({
    required int codInventario,
    required String? observacion,
  });
  Future<OperationResult<void>> eliminar(int codInventario);
}

/// Implementación del datasource remoto de Inventario
class InventarioRemoteDataSourceImpl implements InventarioRemoteDataSource {
  final DioClient _client;

  InventarioRemoteDataSourceImpl(this._client);

  @override
  Future<List<InventarioModel>> listar() async {
    try {
      final response = await _client.get('/inventario');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return [];
        if (data is List) {
          return data.map((json) => InventarioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener inventario');
    }
  }

  @override
  Future<InventarioModel> buscarPorCodigo(int codInventario) async {
    try {
      final response = await _client.get('/inventario/$codInventario');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          return InventarioModel.fromJson(data);
        }
      }

      throw ApiException(message: 'Movimiento no encontrado', statusCode: 404);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al buscar movimiento');
    }
  }

  @override
  Future<List<InventarioModel>> listarPorArticulo(String codArticulo) async {
    try {
      final response = await _client.get('/inventario/articulo/$codArticulo');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return [];
        if (data is List) {
          return data.map((json) => InventarioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener movimientos del artículo');
    }
  }

  @override
  Future<List<InventarioModel>> listarPorTipo(String tipoMovimiento) async {
    try {
      final response = await _client.get('/inventario/tipo/$tipoMovimiento');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return [];
        if (data is List) {
          return data.map((json) => InventarioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener movimientos por tipo');
    }
  }

  @override
  Future<List<InventarioModel>> listarPorFechas({
    required DateTime? desde,
    required DateTime? hasta,
  }) async {
    try {
      final params = <String, String>{};
      if (desde != null) {
        params['desde'] = '${desde.year}-${desde.month.toString().padLeft(2, '0')}-${desde.day.toString().padLeft(2, '0')}';
      }
      if (hasta != null) {
        params['hasta'] = '${hasta.year}-${hasta.month.toString().padLeft(2, '0')}-${hasta.day.toString().padLeft(2, '0')}';
      }

      final response = await _client.get('/inventario/fechas', queryParameters: params);

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return [];
        if (data is List) {
          return data.map((json) => InventarioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener movimientos por fechas');
    }
  }

  @override
  Future<OperationResult<InventarioModel>> crear({
    required String codArticulo,
    required String tipoMovimiento,
    required int cantidad,
    required double precioUnitario,
    String? observacion,
  }) async {
    try {
      console('📤 Enviando movimiento de inventario:');
      console('   codArticulo: $codArticulo');
      console('   tipoMovimiento: $tipoMovimiento');
      console('   cantidad: $cantidad');
      console('   precioUnitario: $precioUnitario');
      console('   observacion: $observacion');
      
      final response = await _client.post(
        '/inventario',
        data: {
          'codArticulo': codArticulo,
          'tipoMovimiento': tipoMovimiento,
          'cantidad': cantidad,
          'precioUnitario': precioUnitario,
          if (observacion != null && observacion.isNotEmpty) 'observacion': observacion,
        },
      );

      console('📥 Respuesta recibida:');
      console('   statusCode: ${response.statusCode}');
      console('   data: ${response.data}');

      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Movimiento creado exitosamente';
        final data = response.data['data'];
        
        if (data != null) {
          final movimiento = InventarioModel.fromJson(data);
          return OperationResult(data: movimiento, message: message);
        }
      }

      throw ApiException(message: 'Error al crear movimiento', statusCode: 500);
    } on DioException catch (e) {
      console('❌ DioException capturado:');
      console('   type: ${e.type}');
      console('   message: ${e.message}');
      console('   statusCode: ${e.response?.statusCode}');
      console('   responseData: ${e.response?.data}');
      
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al crear movimiento de inventario');
    } catch (e, stackTrace) {
      console('❌ Error genérico capturado:');
      console('   error: $e');
      console('   stackTrace: $stackTrace');
      throw ApiException(message: 'Error inesperado: $e', statusCode: 500);
    }
  }

  @override
  Future<OperationResult<InventarioModel>> modificar({
    required int codInventario,
    required String? observacion,
  }) async {
    try {
      final response = await _client.put(
        '/inventario/$codInventario',
        data: {
          'observacion': observacion,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Observación modificada exitosamente';
        final data = response.data['data'];
        
        if (data != null) {
          final movimiento = InventarioModel.fromJson(data);
          return OperationResult(data: movimiento, message: message);
        }
      }

      throw ApiException(message: 'Error al modificar observación', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al modificar observación');
    }
  }

  @override
  Future<OperationResult<void>> eliminar(int codInventario) async {
    try {
      final response = await _client.delete('/inventario/$codInventario');

      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Movimiento reversado exitosamente';
        return OperationResult(data: null, message: message);
      }

      throw ApiException(message: 'Error al reversar movimiento', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al reversar movimiento');
    }
  }
}
