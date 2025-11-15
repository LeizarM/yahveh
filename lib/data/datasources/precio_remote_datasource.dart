import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/precio_model.dart';

/// Interfaz del datasource remoto de Precios
abstract class PrecioRemoteDataSource {
  Future<OperationResult<PrecioModel>> createPrecio({
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  });

  Future<List<PrecioModel>> getPrecios();

  Future<List<PrecioModel>> getPreciosByArticulo(String codArticulo);

  Future<PrecioModel> getPrecioById(int codPrecio);

  Future<OperationResult<PrecioModel>> updatePrecio({
    required int codPrecio,
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  });

  Future<OperationResult<void>> deletePrecio(int codPrecio);
}

/// Implementación del datasource remoto de Precios
class PrecioRemoteDataSourceImpl implements PrecioRemoteDataSource {
  final DioClient _client;

  PrecioRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<PrecioModel>> createPrecio({
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    try {
      // Usar endpoint /merge para UPSERT (inserta o actualiza según codArticulo + listaPrecio)
      final response = await _client.put(
        '/precios-articulos/merge',
        data: {
          'codArticulo': codArticulo,
          'listaPrecio': 1, // Lista de precios por defecto (ajustar según tu lógica)
          'precioBase': precioBase,
          'precio': precio,
          'precioSinFactura': precioSinFactura,
          // audUsuario se obtiene automáticamente del token JWT en el backend
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Precio procesado exitosamente';
        
        // El backend devuelve el codPrecio (creado o actualizado) en el campo 'data'
        final codPrecioCreado = response.data['data'] as int? ?? 0;
        
        // Crear un PrecioModel temporal con los datos que tenemos
        final precioModel = PrecioModel(
          listaPrecio: 1, // Lista por defecto
          codPrecio: codPrecioCreado, // Devuelto por el backend
          codArticulo: codArticulo,
          precioBase: precioBase,
          precio: precio,
          precioSinFactura: precioSinFactura,
          audUsuario: audUsuario,
          audFecha: DateTime.now(),
        );
        
        return OperationResult(data: precioModel, message: message);
      } else {
        // Lanzar excepción con el mensaje del backend cuando success = false
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } on DioException catch (e) {
      // Extraer mensaje del backend si está disponible
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al crear precio');
    }
  }

  @override
  Future<List<PrecioModel>> getPrecios() async {
    try {
      final response = await _client.get('/precios-articulos');

      // El backend devuelve ApiResponse con success, message y data (lista)
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((json) => PrecioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener precios');
    }
  }

  @override
  Future<List<PrecioModel>> getPreciosByArticulo(String codArticulo) async {
    try {
      final response = await _client.get('/precios-articulos/articulo/$codArticulo');

      // El backend devuelve ApiResponse con success, message y data (lista)
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        // Si data es null o una lista vacía, devolver lista vacía (sin error)
        if (data == null) {
          return [];
        }
        if (data is List) {
          return data.map((json) => PrecioModel.fromJson(json)).toList();
        }
      }

      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener precios del artículo');
    }
  }

  @override
  Future<PrecioModel> getPrecioById(int codPrecio) async {
    try {
      final response = await _client.get('/precios-articulos/$codPrecio');

      // El backend devuelve ApiResponse con success, message y data (objeto)
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          return PrecioModel.fromJson(data);
        }
      }

      throw ApiException(message: 'Precio no encontrado', statusCode: 404);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener precio');
    }
  }

  @override
  Future<OperationResult<PrecioModel>> updatePrecio({
    required int codPrecio,
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/precios-articulos/$codPrecio',
        data: {
          'codArticulo': codArticulo,
          'precioBase': precioBase,
          'precio': precio,
          'precioSinFactura': precioSinFactura,
          // audUsuario se obtiene automáticamente del token JWT en el backend
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Precio actualizado exitosamente';
        
        // Crear un PrecioModel temporal con los datos actualizados
        final precioModel = PrecioModel(
          listaPrecio: 0, // Se mantiene el del backend
          codPrecio: codPrecio,
          codArticulo: codArticulo,
          precioBase: precioBase,
          precio: precio,
          precioSinFactura: precioSinFactura,
          audUsuario: audUsuario,
          audFecha: DateTime.now(),
        );
        
        return OperationResult(data: precioModel, message: message);
      } else {
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al actualizar precio');
    }
  }

  @override
  Future<OperationResult<void>> deletePrecio(int codPrecio) async {
    try {
      final response = await _client.delete('/precios-articulos/$codPrecio');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Precio eliminado exitosamente';
        return OperationResult(data: null, message: message);
      } else {
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al eliminar precio');
    }
  }
}
