import '../../core/network/dio_client.dart';
import '../models/articulo_model.dart';

/// Interfaz del datasource remoto de Artículos
abstract class ArticuloRemoteDataSource {
  Future<ArticuloModel> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  Future<List<ArticuloModel>> getArticulos();

  Future<ArticuloModel> getArticuloById(String codArticulo);

  Future<ArticuloModel> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  Future<void> deleteArticulo(String codArticulo);
}

/// Implementación del datasource remoto de Artículos
class ArticuloRemoteDataSourceImpl implements ArticuloRemoteDataSource {
  final DioClient _client;

  ArticuloRemoteDataSourceImpl(this._client);

  @override
  Future<ArticuloModel> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.post(
        '/articulos/',
        data: {
          'codArticulo': codArticulo,
          'codLinea': codLinea,
          'descripcion': descripcion,
          'descripcion2': descripcion2,
          'audUsuario': audUsuario,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // Debug: ver qué tipo de dato es
        print('Create articulo response data type: ${data.runtimeType}');
        print('Create articulo response data: $data');
        
        // Si el backend devuelve solo el codArticulo (String), obtenemos el objeto completo
        if (data is String) {
          return await getArticuloById(data);
        }
        
        // Si el backend devuelve el objeto completo
        if (data is Map<String, dynamic>) {
          return ArticuloModel.fromJson(data);
        }
        
        // Si data es null, asumimos que se creó correctamente y obtenemos el objeto
        if (data == null) {
          return await getArticuloById(codArticulo);
        }
        
        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al crear artículo');
      }
    } catch (e) {
      throw Exception('Error al crear artículo: $e');
    }
  }

  @override
  Future<List<ArticuloModel>> getArticulos() async {
    try {
      final response = await _client.get('/articulos/');

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        
        // Si data es una lista
        if (data is List) {
          return data
              .map((json) => ArticuloModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        // Si data es null o está vacío, retornar lista vacía
        return [];
      } else {
        throw Exception(response.data?['message'] ?? 'Error al obtener artículos');
      }
    } catch (e) {
      throw Exception('Error al obtener artículos: $e');
    }
  }

  @override
  Future<ArticuloModel> getArticuloById(String codArticulo) async {
    try {
      final response = await _client.get('/articulos/$codArticulo');

      if (response.data['success'] == true) {
        return ArticuloModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Error al obtener artículo');
      }
    } catch (e) {
      throw Exception('Error al obtener artículo: $e');
    }
  }

  @override
  Future<ArticuloModel> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final response = await _client.put(
        '/articulos/$codArticulo',
        data: {
          'codLinea': codLinea,
          'descripcion': descripcion,
          'descripcion2': descripcion2,
          'audUsuario': audUsuario,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // Debug: ver qué tipo de dato es
        print('Update articulo response data type: ${data.runtimeType}');
        print('Update articulo response data: $data');
        
        // Si el backend devuelve solo el codArticulo (String), obtenemos el objeto completo
        if (data is String) {
          return await getArticuloById(data);
        }
        
        // Si el backend devuelve el objeto completo
        if (data is Map<String, dynamic>) {
          return ArticuloModel.fromJson(data);
        }
        
        // Si data es null, asumimos que se actualizó correctamente y obtenemos el objeto
        if (data == null) {
          return await getArticuloById(codArticulo);
        }
        
        throw Exception('Formato de respuesta inesperado: ${data.runtimeType}');
      } else {
        throw Exception(response.data['message'] ?? 'Error al actualizar artículo');
      }
    } catch (e) {
      throw Exception('Error al actualizar artículo: $e');
    }
  }

  @override
  Future<void> deleteArticulo(String codArticulo) async {
    try {
      final response = await _client.delete('/articulos/$codArticulo');

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Error al eliminar artículo');
      }
    } catch (e) {
      throw Exception('Error al eliminar artículo: $e');
    }
  }
}
