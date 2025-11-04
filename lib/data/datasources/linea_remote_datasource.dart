import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/linea_model.dart';

/// Interfaz del datasource remoto de Líneas
abstract class LineaRemoteDataSource {
  Future<OperationResult<LineaModel>> createLinea({
    required int codFamilia,
    required String linea,
    required int audUsuario,
  });

  Future<List<LineaModel>> getLineas();

  Future<LineaModel> getLineaById(int codLinea);

  Future<OperationResult<LineaModel>> updateLinea({
    required int codLinea,
    required int codFamilia,
    required String linea,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteLinea(int codLinea);
}

/// Implementación del datasource remoto de Líneas
class LineaRemoteDataSourceImpl implements LineaRemoteDataSource {
  final DioClient _client;

  LineaRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<LineaModel>> createLinea({
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/lineas/',
        data: {
          'codFamilia': codFamilia,
          'linea': linea,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final message = response.data['message'] as String? ?? 'Línea creada exitosamente';
        
        LineaModel lineaModel;
        
        // Si el backend devuelve solo el codLinea (int), obtenemos el objeto completo
        if (data is int) {
          lineaModel = await getLineaById(data);
        }
        // Si el backend devuelve el objeto completo
        else if (data is Map<String, dynamic>) {
          lineaModel = LineaModel.fromJson(data);
        }
        // Si data es null o cualquier otro tipo inesperado
        else {
          throw ApiException(
            message: 'Formato de respuesta inesperado: ${data.runtimeType}',
          );
        }
        
        return OperationResult(data: lineaModel, message: message);
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
      throw ApiException.fromError(e, 'Error al crear línea');
    }
  }

  @override
  Future<List<LineaModel>> getLineas() async {
    try {
      final response = await _client.get('/lineas/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Si data es una lista
        if (data is List) {
          return data
              .map((json) => LineaModel.fromJson(json as Map<String, dynamic>))
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
      throw ApiException.fromError(e, 'Error al obtener líneas');
    }
  }

  @override
  Future<LineaModel> getLineaById(int codLinea) async {
    try {
      final response = await _client.get('/lineas/$codLinea');

      if (response.data['success'] == true) {
        return LineaModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
      throw ApiException.fromError(e, 'Error al obtener línea');
    }
  }

  @override
  Future<OperationResult<LineaModel>> updateLinea({
    required int codLinea,
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/lineas/$codLinea',
        data: {
          'codFamilia': codFamilia,
          'linea': linea,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        final message = response.data['message'] as String? ?? 'Línea actualizada exitosamente';
        
        LineaModel lineaModel;
        
        // Si el backend devuelve solo el codLinea (int), obtenemos el objeto completo
        if (data is int) {
          lineaModel = await getLineaById(data);
        }
        // Si el backend devuelve el objeto completo
        else if (data is Map<String, dynamic>) {
          lineaModel = LineaModel.fromJson(data);
        }
        // Si data es null, asumimos que se actualizó correctamente y obtenemos el objeto
        else if (data == null) {
          lineaModel = await getLineaById(codLinea);
        }
        else {
          throw ApiException(
            message: 'Formato de respuesta inesperado: ${data.runtimeType}',
          );
        }
        
        return OperationResult(data: lineaModel, message: message);
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
      throw ApiException.fromError(e, 'Error al actualizar línea');
    }
  }

  @override
  Future<OperationResult<void>> deleteLinea(int codLinea) async {
    try {
      final response = await _client.delete('/lineas/$codLinea');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Línea eliminada exitosamente';
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
      throw ApiException.fromError(e, 'Error al eliminar línea');
    }
  }
}
