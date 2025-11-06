import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/articulo_model.dart';

/// Interfaz del datasource remoto de Artículos
abstract class ArticuloRemoteDataSource {
  Future<OperationResult<ArticuloModel>> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  Future<List<ArticuloModel>> getArticulos();

  Future<ArticuloModel> getArticuloById(String codArticulo);

  Future<OperationResult<ArticuloModel>> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteArticulo(String codArticulo);
}

/// Implementación del datasource remoto de Artículos
class ArticuloRemoteDataSourceImpl implements ArticuloRemoteDataSource {
  final DioClient _client;

  ArticuloRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<ArticuloModel>> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/articulos/',
        data: {
          'codArticulo': codArticulo,
          'codLinea': codLinea,
          'descripcion': descripcion,
          'descripcion2': descripcion2,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Artículo creado exitosamente';
        
        // Crear un ArticuloModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final articuloModel = ArticuloModel(
          codArticulo: codArticulo,
          codLinea: codLinea,
          descripcion: descripcion,
          descripcion2: descripcion2,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: articuloModel, message: message);
      } else {
        // Lanzar excepción con el mensaje del backend cuando success = false
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Si es un DioException, intentar extraer el mensaje del response
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
      throw ApiException.fromError(e, 'Error al crear artículo');
    }
  }

  @override
  Future<List<ArticuloModel>> getArticulos() async {
    try {
      final response = await _client.get('/articulos/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Si data es una lista
        if (data is List) {
          return data
              .map((json) => ArticuloModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        // Si data es null o está vacío, retornar lista vacía
        return [];
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Si es un DioException, intentar extraer el mensaje del response
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
      throw ApiException.fromError(e, 'Error al obtener artículos');
    }
  }

  @override
  Future<ArticuloModel> getArticuloById(String codArticulo) async {
    try {
      final response = await _client.get('/articulos/$codArticulo');

      if (response.data['success'] == true) {
        return ArticuloModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Si es un DioException, intentar extraer el mensaje del response
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
      throw ApiException.fromError(e, 'Error al obtener artículo');
    }
  }

  @override
  Future<OperationResult<ArticuloModel>> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {

    debugPrint('=== UPDATE ARTICULO ===');
    debugPrint('URL: /articulos/$codArticulo');
    debugPrint('codArticulo: $codArticulo');
    debugPrint('codLinea: $codLinea');
    debugPrint('descripcion: $descripcion');
    debugPrint('descripcion2: $descripcion2');
    debugPrint('audUsuario: $audUsuario');

    try {
      final requestData = {
        'codArticulo': codArticulo,  // El backend lo requiere en el body también
        'codLinea': codLinea,
        'descripcion': descripcion,
        'descripcion2': descripcion2,
        'audUsuario': audUsuario,
      };
      
      debugPrint('Request Data: $requestData');

      final response = await _client.put(
        '/articulos/$codArticulo',
        data: requestData,
      );

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Artículo actualizado exitosamente';
        
        // Crear un ArticuloModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final articuloModel = ArticuloModel(
          codArticulo: codArticulo,
          codLinea: codLinea,
          descripcion: descripcion,
          descripcion2: descripcion2,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: articuloModel, message: message);
      } else {
        // Lanzar excepción con el mensaje del backend cuando success = false
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      debugPrint('Error en updateArticulo: $e');
      if (e is ApiException) {
        rethrow;
      }
      // Si es un DioException, intentar extraer el mensaje del response
      if (e is DioException && e.response?.data != null) {
        debugPrint('DioException Response Data: ${e.response?.data}');
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['message'] != null) {
          throw ApiException(
            message: responseData['message'] as String,
            statusCode: e.response?.statusCode,
            originalError: e,
          );
        }
      }
      throw ApiException.fromError(e, 'Error al actualizar artículo');
    }
  }

  @override
  Future<OperationResult<void>> deleteArticulo(String codArticulo) async {
    try {
      final response = await _client.delete('/articulos/$codArticulo');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Artículo eliminado exitosamente';
        return OperationResult(data: null, message: message);
      } else {
        // Lanzar excepción con el mensaje del backend cuando success = false
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      // Si es un DioException, intentar extraer el mensaje del response
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
      throw ApiException.fromError(e, 'Error al eliminar artículo');
    }
  }
}
