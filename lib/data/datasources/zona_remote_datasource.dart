import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/zona_model.dart';

/// Interfaz del datasource remoto de Zonas
abstract class ZonaRemoteDataSource {
  Future<OperationResult<ZonaModel>> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  Future<List<ZonaModel>> getZonas();

  Future<ZonaModel> getZonaById(int codZona);

  Future<OperationResult<ZonaModel>> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteZona(int codZona);
}

/// Implementación del datasource remoto de Zonas
class ZonaRemoteDataSourceImpl implements ZonaRemoteDataSource {
  final DioClient _client;

  ZonaRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<ZonaModel>> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/zonas/',
        data: {
          'codCiudad': codCiudad,
          'zona': zona,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Zona creada exitosamente';
        
        // Crear un ZonaModel temporal con los datos que tenemos
        final zonaModel = ZonaModel(
          codZona: response.data['data'] is int ? response.data['data'] : 0,
          codCiudad: codCiudad,
          zona: zona,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: zonaModel, message: message);
      } else {
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
      throw ApiException.fromError(e, 'Error al crear zona');
    }
  }

  @override
  Future<List<ZonaModel>> getZonas() async {
    try {
      final response = await _client.get('/zonas/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data
              .map((json) => ZonaModel.fromJson(json as Map<String, dynamic>))
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
      throw ApiException.fromError(e, 'Error al obtener zonas');
    }
  }

  @override
  Future<ZonaModel> getZonaById(int codZona) async {
    try {
      final response = await _client.get('/zonas/$codZona');

      if (response.data['success'] == true) {
        return ZonaModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException.fromResponse(response.data, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
      throw ApiException.fromError(e, 'Error al obtener zona');
    }
  }

  @override
  Future<OperationResult<ZonaModel>> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/zonas/$codZona',
        data: {
          'codZona': codZona,
          'codCiudad': codCiudad,
          'zona': zona,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Zona actualizada exitosamente';
        
        // Crear un ZonaModel temporal con los datos que tenemos
        final zonaModel = ZonaModel(
          codZona: codZona,
          codCiudad: codCiudad,
          zona: zona,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: zonaModel, message: message);
      } else {
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
      throw ApiException.fromError(e, 'Error al actualizar zona');
    }
  }

  @override
  Future<OperationResult<void>> deleteZona(int codZona) async {
    try {
      final response = await _client.delete('/zonas/$codZona');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Zona eliminada exitosamente';
        return OperationResult(data: null, message: message);
      } else {
        final errorData = response.data is Map<String, dynamic> 
            ? response.data as Map<String, dynamic>
            : {'message': 'Error desconocido', 'success': false};
        throw ApiException.fromResponse(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
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
      throw ApiException.fromError(e, 'Error al eliminar zona');
    }
  }
}
