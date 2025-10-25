import '../../core/network/dio_client.dart';
import '../models/ciudad_model.dart';

/// Interfaz del datasource remoto de Ciudades
abstract class CiudadRemoteDataSource {
  Future<CiudadModel> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  Future<List<CiudadModel>> getCiudades();

  Future<CiudadModel> getCiudadById(int codCiudad);

  Future<CiudadModel> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  Future<void> deleteCiudad(int codCiudad);
}

/// Implementación del datasource remoto de Ciudades
class CiudadRemoteDataSourceImpl implements CiudadRemoteDataSource {
  final DioClient _client;

  CiudadRemoteDataSourceImpl(this._client);

  @override
  Future<CiudadModel> createCiudad({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int) {
          return await getCiudadById(data);
        }

        if (data is Map<String, dynamic>) {
          return CiudadModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear ciudad');
      }
    } catch (e) {
      throw Exception('Error al crear ciudad: $e');
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
        throw Exception(response.data?['message'] ?? 'Error al obtener ciudades');
      }
    } catch (e) {
      throw Exception('Error al obtener ciudades: $e');
    }
  }

  @override
  Future<CiudadModel> getCiudadById(int codCiudad) async {
    try {
      final response = await _client.get('/ciudades/$codCiudad');

      if (response.data['success'] == true) {
        return CiudadModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener ciudad');
      }
    } catch (e) {
      throw Exception('Error al obtener ciudad: $e');
    }
  }

  @override
  Future<CiudadModel> updateCiudad({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int || data == null) {
          return await getCiudadById(codCiudad);
        }

        if (data is Map<String, dynamic>) {
          return CiudadModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar ciudad');
      }
    } catch (e) {
      throw Exception('Error al actualizar ciudad: $e');
    }
  }

  @override
  Future<void> deleteCiudad(int codCiudad) async {
    try {
      final response = await _client.delete('/ciudades/$codCiudad');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar ciudad');
      }
    } catch (e) {
      throw Exception('Error al eliminar ciudad: $e');
    }
  }
}
