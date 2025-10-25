import '../../core/network/dio_client.dart';
import '../models/pais_model.dart';

/// Interfaz del datasource remoto de Países
abstract class PaisRemoteDataSource {
  Future<PaisModel> createPais({
    required String pais,
    required int audUsuario,
  });

  Future<List<PaisModel>> getPaises();

  Future<PaisModel> getPaisById(int codPais);

  Future<PaisModel> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  });

  Future<void> deletePais(int codPais);
}

/// Implementación del datasource remoto de Países
class PaisRemoteDataSourceImpl implements PaisRemoteDataSource {
  final DioClient _client;

  PaisRemoteDataSourceImpl(this._client);

  @override
  Future<PaisModel> createPais({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Si devuelve el ID, obtener el objeto completo
        if (data is int) {
          return await getPaisById(data);
        }

        // Si devuelve el objeto completo
        if (data is Map<String, dynamic>) {
          return PaisModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear país');
      }
    } catch (e) {
      throw Exception('Error al crear país: $e');
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
        throw Exception(response.data?['message'] ?? 'Error al obtener países');
      }
    } catch (e) {
      throw Exception('Error al obtener países: $e');
    }
  }

  @override
  Future<PaisModel> getPaisById(int codPais) async {
    try {
      final response = await _client.get('/paises/$codPais');

      if (response.data['success'] == true) {
        return PaisModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener país');
      }
    } catch (e) {
      throw Exception('Error al obtener país: $e');
    }
  }

  @override
  Future<PaisModel> updatePais({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int || data == null) {
          return await getPaisById(codPais);
        }

        if (data is Map<String, dynamic>) {
          return PaisModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar país');
      }
    } catch (e) {
      throw Exception('Error al actualizar país: $e');
    }
  }

  @override
  Future<void> deletePais(int codPais) async {
    try {
      final response = await _client.delete('/paises/$codPais');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar país');
      }
    } catch (e) {
      throw Exception('Error al eliminar país: $e');
    }
  }
}
