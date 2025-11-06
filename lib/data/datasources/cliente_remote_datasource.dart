import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/cliente_model.dart';

/// Interfaz del datasource remoto de Clientes
abstract class ClienteRemoteDataSource {
  Future<OperationResult<ClienteModel>> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  });

  Future<List<ClienteModel>> getClientes();

  Future<ClienteModel> getClienteById(int codCliente);

  Future<OperationResult<ClienteModel>> updateCliente({
    required int codCliente,
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteCliente(int codCliente);
}

/// Implementación del datasource remoto de Clientes
class ClienteRemoteDataSourceImpl implements ClienteRemoteDataSource {
  final DioClient _client;

  ClienteRemoteDataSourceImpl(this._client);

  @override
  Future<OperationResult<ClienteModel>> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/clientes/',
        data: {
          'codZona': codZona,
          'nit': nit,
          'razonSocial': razonSocial,
          'nombreCliente': nombreCliente,
          'direccion': direccion,
          'referencia': referencia,
          'obs': obs,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Cliente creado exitosamente';
        
        // Crear un ClienteModel temporal con los datos que tenemos
        final clienteModel = ClienteModel(
          codCliente: response.data['data'] is int ? response.data['data'] : 0,
          codZona: codZona,
          nit: nit,
          razonSocial: razonSocial,
          nombreCliente: nombreCliente,
          direccion: direccion,
          referencia: referencia,
          obs: obs,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: clienteModel, message: message);
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
      throw ApiException.fromError(e, 'Error al crear cliente');
    }
  }

  @override
  Future<List<ClienteModel>> getClientes() async {
    try {
      final response = await _client.get('/clientes/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          return data
              .map((json) => ClienteModel.fromJson(json as Map<String, dynamic>))
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
      throw ApiException.fromError(e, 'Error al obtener clientes');
    }
  }

  @override
  Future<ClienteModel> getClienteById(int codCliente) async {
    try {
      final response = await _client.get('/clientes/$codCliente');

      if (response.data['success'] == true) {
        return ClienteModel.fromJson(response.data['data'] as Map<String, dynamic>);
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
      throw ApiException.fromError(e, 'Error al obtener cliente');
    }
  }

  @override
  Future<OperationResult<ClienteModel>> updateCliente({
    required int codCliente,
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/clientes/$codCliente',
        data: {
          'codCliente': codCliente,
          'codZona': codZona,
          'nit': nit,
          'razonSocial': razonSocial,
          'nombreCliente': nombreCliente,
          'direccion': direccion,
          'referencia': referencia,
          'obs': obs,
          'audUsuario': audUsuario,
        },
      );

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Cliente actualizado exitosamente';
        
        // Crear un ClienteModel temporal con los datos que tenemos
        final clienteModel = ClienteModel(
          codCliente: codCliente,
          codZona: codZona,
          nit: nit,
          razonSocial: razonSocial,
          nombreCliente: nombreCliente,
          direccion: direccion,
          referencia: referencia,
          obs: obs,
          audUsuario: audUsuario,
        );
        
        return OperationResult(data: clienteModel, message: message);
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
      throw ApiException.fromError(e, 'Error al actualizar cliente');
    }
  }

  @override
  Future<OperationResult<void>> deleteCliente(int codCliente) async {
    try {
      final response = await _client.delete('/clientes/$codCliente');

      // Verificar si la respuesta fue exitosa
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Cliente eliminado exitosamente';
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
      throw ApiException.fromError(e, 'Error al eliminar cliente');
    }
  }
}
