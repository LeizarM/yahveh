import '../../core/network/dio_client.dart';
import '../models/linea_model.dart';

/// Interfaz del datasource remoto de Líneas
abstract class LineaRemoteDataSource {
  Future<LineaModel> createLinea({
    required String linea,
    required int audUsuario,
  });

  Future<List<LineaModel>> getLineas();

  Future<LineaModel> getLineaById(int codLinea);

  Future<LineaModel> updateLinea({
    required int codLinea,
    required String linea,
    required int audUsuario,
  });

  Future<void> deleteLinea(int codLinea);
}

/// Implementación del datasource remoto de Líneas
class LineaRemoteDataSourceImpl implements LineaRemoteDataSource {
  final DioClient _client;

  LineaRemoteDataSourceImpl(this._client);

  @override
  Future<LineaModel> createLinea({
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/lineas/',
        data: {
          'linea': linea,
          'audUsuario': audUsuario,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
       
        
        // Si el backend devuelve solo el codLinea (int), obtenemos el objeto completo
        if (data is int) {
          return await getLineaById(data);
        }
        
        // Si el backend devuelve el objeto completo
        if (data is Map<String, dynamic>) {
          return LineaModel.fromJson(data);
        }
        
        // Si data es null o cualquier otro tipo inesperado
        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear línea');
      }
    } catch (e) {
      throw Exception('Error al crear línea: $e');
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
        throw Exception(response.data?['message'] ?? 'Error al obtener líneas');
      }
    } catch (e) {
      throw Exception('Error al obtener líneas: $e');
    }
  }

  @override
  Future<LineaModel> getLineaById(int codLinea) async {
    try {
      final response = await _client.get('/lineas/$codLinea');

      if (response.data['success'] == true) {
        return LineaModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener línea');
      }
    } catch (e) {
      throw Exception('Error al obtener línea: $e');
    }
  }

  @override
  Future<LineaModel> updateLinea({
    required int codLinea,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/lineas/$codLinea',
        data: {
          'linea': linea,
          'audUsuario': audUsuario,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
       
        // Si el backend devuelve solo el codLinea (int), obtenemos el objeto completo
        if (data is int) {
          return await getLineaById(data);
        }
        
        // Si el backend devuelve el objeto completo
        if (data is Map<String, dynamic>) {
          return LineaModel.fromJson(data);
        }
        
        // Si data es null, asumimos que se actualizó correctamente y obtenemos el objeto
        if (data == null) {
          return await getLineaById(codLinea);
        }
        
        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar línea');
      }
    } catch (e) {
      throw Exception('Error al actualizar línea: $e');
    }
  }

  @override
  Future<void> deleteLinea(int codLinea) async {
    try {
      final response = await _client.delete('/lineas/$codLinea');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar línea');
      }
    } catch (e) {
      throw Exception('Error al eliminar línea: $e');
    }
  }
}
