import '../../core/network/dio_client.dart';
import '../models/zona_model.dart';

/// Interfaz del datasource remoto de Zonas
abstract class ZonaRemoteDataSource {
  Future<ZonaModel> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  Future<List<ZonaModel>> getZonas();

  Future<ZonaModel> getZonaById(int codZona);

  Future<ZonaModel> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  Future<void> deleteZona(int codZona);
}

/// Implementación del datasource remoto de Zonas
class ZonaRemoteDataSourceImpl implements ZonaRemoteDataSource {
  final DioClient _client;

  ZonaRemoteDataSourceImpl(this._client);

  @override
  Future<ZonaModel> createZona({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int) {
          return await getZonaById(data);
        }

        if (data is Map<String, dynamic>) {
          return ZonaModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear zona');
      }
    } catch (e) {
      throw Exception('Error al crear zona: $e');
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
        throw Exception(response.data?['message'] ?? 'Error al obtener zonas');
      }
    } catch (e) {
      throw Exception('Error al obtener zonas: $e');
    }
  }

  @override
  Future<ZonaModel> getZonaById(int codZona) async {
    try {
      final response = await _client.get('/zonas/$codZona');

      if (response.data['success'] == true) {
        return ZonaModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener zona');
      }
    } catch (e) {
      throw Exception('Error al obtener zona: $e');
    }
  }

  @override
  Future<ZonaModel> updateZona({
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

      if (response.data['success'] == true) {
        final data = response.data['data'];

        if (data is int || data == null) {
          return await getZonaById(codZona);
        }

        if (data is Map<String, dynamic>) {
          return ZonaModel.fromJson(data);
        }

        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar zona');
      }
    } catch (e) {
      throw Exception('Error al actualizar zona: $e');
    }
  }

  @override
  Future<void> deleteZona(int codZona) async {
    try {
      final response = await _client.delete('/zonas/$codZona');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar zona');
      }
    } catch (e) {
      throw Exception('Error al eliminar zona: $e');
    }
  }
}
