import '../../core/network/dio_client.dart';
import '../models/cliente_model.dart';

/// Interfaz del datasource remoto de Clientes
abstract class ClienteRemoteDataSource {
  Future<ClienteModel> createCliente({
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

  Future<ClienteModel> updateCliente({
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

  Future<void> deleteCliente(int codCliente);
}

/// Implementación del datasource remoto de Clientes
class ClienteRemoteDataSourceImpl implements ClienteRemoteDataSource {
  final DioClient _client;

  ClienteRemoteDataSourceImpl(this._client);

  @override
  Future<ClienteModel> createCliente({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int) {
          return await getClienteById(data);
        }

        if (data is Map<String, dynamic>) {
          return ClienteModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear cliente');
      }
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
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
        throw Exception(response.data?['message'] ?? 'Error al obtener clientes');
      }
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  @override
  Future<ClienteModel> getClienteById(int codCliente) async {
    try {
      final response = await _client.get('/clientes/$codCliente');

      if (response.data['success'] == true) {
        return ClienteModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener cliente');
      }
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  @override
  Future<ClienteModel> updateCliente({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int || data == null) {
          return await getClienteById(codCliente);
        }

        if (data is Map<String, dynamic>) {
          return ClienteModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar cliente');
      }
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  @override
  Future<void> deleteCliente(int codCliente) async {
    try {
      final response = await _client.delete('/clientes/$codCliente');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar cliente');
      }
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }
}
