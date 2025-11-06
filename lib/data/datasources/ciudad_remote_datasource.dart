import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/ciudad_model.dart';

/// Interfaz del datasource remoto de Ciudades
abstract class CiudadRemoteDataSource {
  Future<OperationResult<CiudadModel>> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  Future<List<CiudadModel>> getCiudades();

  Future<CiudadModel> getCiudadById(int codCiudad);

  Future<OperationResult<CiudadModel>> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteCiudad(int codCiudad);
}

/// Implementación del datasource remoto de Ciudades
class CiudadRemoteDataSourceImpl implements CiudadRemoteDataSource {
  final DioClient _client;

  CiudadRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<CiudadModel>> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/ciudades/',
        data: {
          'codPais': codPais,
          'ciudad': ciudad,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Ciudad creada exitosamente';
        
        // Crear un CiudadModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final ciudadModel = CiudadModel(
          codCiudad: response.data['data'] is int ? response.data['data'] : 0,
          codPais: codPais,
          ciudad: ciudad,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: ciudadModel, message: message);
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
      throw ApiException.fromError(e, 'Error al crear ciudad');
    }
  }

  @override
  Future<List<CiudadModel>> getCiudades() async {
    try {
      final response = await _client.get('/ciudades/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data
              .map((json) => CiudadModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

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
      throw ApiException.fromError(e, 'Error al obtener ciudades');
    }
  }

  @override
  Future<CiudadModel> getCiudadById(int codCiudad) async {
    try {
      final response = await _client.get('/ciudades/$codCiudad');

      if (response.data['success'] == true) {
        return CiudadModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
      throw ApiException.fromError(e, 'Error al obtener ciudad');
    }
  }

  @override
  Future<OperationResult<CiudadModel>> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/ciudades/$codCiudad',
        data: {
          'codCiudad': codCiudad,
          'codPais': codPais,
          'ciudad': ciudad,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Ciudad actualizada exitosamente';
        
        // Crear un CiudadModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final ciudadModel = CiudadModel(
          codCiudad: codCiudad,
          codPais: codPais,
          ciudad: ciudad,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: ciudadModel, message: message);
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
      throw ApiException.fromError(e, 'Error al actualizar ciudad');
    }
  }

  @override
  Future<OperationResult<void>> deleteCiudad(int codCiudad) async {
    try {
      final response = await _client.delete('/ciudades/$codCiudad');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Ciudad eliminada exitosamente';
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
      throw ApiException.fromError(e, 'Error al eliminar ciudad');
    }
  }
}
