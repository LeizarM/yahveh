import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/familia_model.dart';

/// Interfaz del Remote DataSource para Familias
abstract class FamiliaRemoteDataSource {
  Future<OperationResult<FamiliaModel>> createFamilia({
    required String familia,
    required int audUsuario,
  });

  Future<List<FamiliaModel>> getAllFamilias();

  Future<FamiliaModel> getFamiliaById(int codFamilia);

  Future<OperationResult<FamiliaModel>> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteFamilia(int codFamilia);
}

/// Implementación del Remote DataSource para Familias
class FamiliaRemoteDataSourceImpl implements FamiliaRemoteDataSource {
  final DioClient _client;

  FamiliaRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<FamiliaModel>> createFamilia({
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/familias/',
        data: {
          'familia': familia,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Familia creada exitosamente';
        
        FamiliaModel familiaModel;
        
        // Si el backend retorna el objeto completo
        if (response.data['data'] is Map<String, dynamic>) {
          familiaModel = FamiliaModel.fromJson(response.data['data']);
        }
        // Si solo retorna el ID, hacer un GET
        else if (response.data['data'] is int) {
          final codFamilia = response.data['data'] as int;
          familiaModel = await getFamiliaById(codFamilia);
        }
        else {
          throw ApiException(
            message: 'Formato de respuesta inesperado: ${response.data['data'].runtimeType}',
          );
        }
        
        return OperationResult(data: familiaModel, message: message);
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
      throw ApiException.fromError(e, 'Error al crear familia');
    }
  }

  @override
  Future<List<FamiliaModel>> getAllFamilias() async {
    try {
      final response = await _client.get('/familias/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Si data es una lista
        if (data is List) {
          return data
              .map((json) => FamiliaModel.fromJson(json as Map<String, dynamic>))
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
      throw ApiException.fromError(e, 'Error al obtener familias');
    }
  }

  @override
  Future<FamiliaModel> getFamiliaById(int codFamilia) async {
    try {
      final response = await _client.get('/familias/$codFamilia');

      if (response.data['success'] == true) {
        return FamiliaModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
      throw ApiException.fromError(e, 'Error al obtener familia');
    }
  }

  @override
  Future<OperationResult<FamiliaModel>> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/familias/$codFamilia',
        data: {
          'codFamilia': codFamilia,
          'familia': familia,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Familia actualizada exitosamente';
        
        FamiliaModel familiaModel;
        
        // Si el backend retorna el objeto completo
        if (response.data['data'] is Map<String, dynamic>) {
          familiaModel = FamiliaModel.fromJson(response.data['data']);
        }
        // Si data es null, hacer un GET
        else if (response.data['data'] == null) {
          familiaModel = await getFamiliaById(codFamilia);
        }
        else {
          throw ApiException(
            message: 'Formato de respuesta inesperado: ${response.data['data'].runtimeType}',
          );
        }
        
        return OperationResult(data: familiaModel, message: message);
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
      throw ApiException.fromError(e, 'Error al actualizar familia');
    }
  }

  @override
  Future<OperationResult<void>> deleteFamilia(int codFamilia) async {
    try {
      final response = await _client.delete('/familias/$codFamilia');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Familia eliminada exitosamente';
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
      throw ApiException.fromError(e, 'Error al eliminar familia');
    }
  }
}
