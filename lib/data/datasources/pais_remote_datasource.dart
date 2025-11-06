import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/pais_model.dart';

/// Interfaz del datasource remoto de Países
abstract class PaisRemoteDataSource {
  Future<OperationResult<PaisModel>> createPais({
    required String pais,
    required int audUsuario,
  });

  Future<List<PaisModel>> getPaises();

  Future<PaisModel> getPaisById(int codPais);

  Future<OperationResult<PaisModel>> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  });

  Future<OperationResult<void>> deletePais(int codPais);
}

/// Implementación del datasource remoto de Países
class PaisRemoteDataSourceImpl implements PaisRemoteDataSource {
  final DioClient _client;

  PaisRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<PaisModel>> createPais({
    required String pais,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/paises/',
        data: {
          'pais': pais,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'País creado exitosamente';
        
        // Crear un PaisModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final paisModel = PaisModel(
          codPais: response.data['data'] is int ? response.data['data'] : 0,
          pais: pais,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: paisModel, message: message);
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
      throw ApiException.fromError(e, 'Error al crear país');
    }
  }

  @override
  Future<List<PaisModel>> getPaises() async {
    try {
      final response = await _client.get('/paises/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data
              .map((json) => PaisModel.fromJson(json as Map<String, dynamic>))
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
      throw ApiException.fromError(e, 'Error al obtener países');
    }
  }

  @override
  Future<PaisModel> getPaisById(int codPais) async {
    try {
      final response = await _client.get('/paises/$codPais');

      if (response.data['success'] == true) {
        return PaisModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
      throw ApiException.fromError(e, 'Error al obtener país');
    }
  }

  @override
  Future<OperationResult<PaisModel>> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/paises/$codPais',
        data: {
          'codPais': codPais,
          'pais': pais,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'País actualizado exitosamente';
        
        // Crear un PaisModel temporal con los datos que tenemos
        // El provider recargará la lista completa después
        final paisModel = PaisModel(
          codPais: codPais,
          pais: pais,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: paisModel, message: message);
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
      throw ApiException.fromError(e, 'Error al actualizar país');
    }
  }

  @override
  Future<OperationResult<void>> deletePais(int codPais) async {
    try {
      final response = await _client.delete('/paises/$codPais');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'País eliminado exitosamente';
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
      throw ApiException.fromError(e, 'Error al eliminar país');
    }
  }
}
