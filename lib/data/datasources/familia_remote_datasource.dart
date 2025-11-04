import '../../core/network/dio_client.dart';
import '../models/familia_model.dart';

/// Interfaz del Remote DataSource para Familias
abstract class FamiliaRemoteDataSource {
  Future<FamiliaModel> createFamilia({
    required String familia,
    required int audUsuario,
  });

  Future<List<FamiliaModel>> getAllFamilias();

  Future<FamiliaModel> getFamiliaById(int codFamilia);

  Future<FamiliaModel> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  });

  Future<void> deleteFamilia(int codFamilia);
}

/// Implementación del Remote DataSource para Familias
class FamiliaRemoteDataSourceImpl implements FamiliaRemoteDataSource {
  final DioClient _client;

  FamiliaRemoteDataSourceImpl(this._client);

  @override
  Future<FamiliaModel> createFamilia({
    required String familia,
    required int audUsuario,
  }) async {
    final response = await _client.post(
      '/familias/',
      data: {
        'familia': familia,
        'audUsuario': audUsuario,
      },
    );

    if (response.data['success'] == true) {
      // Si el backend retorna el objeto completo
      if (response.data['data'] is Map) {
        return FamiliaModel.fromJson(response.data['data']);
      }
      // Si solo retorna el ID, hacer un GET
      final codFamilia = response.data['data'] as int;
      return await getFamiliaById(codFamilia);
    }

    throw Exception('Error al crear familia: ${response.data['message']}');
  }

  @override
  Future<List<FamiliaModel>> getAllFamilias() async {
    final response = await _client.get('/familias/');

    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => FamiliaModel.fromJson(json)).toList();
    }

    throw Exception('Error al obtener familias: ${response.data['message']}');
  }

  @override
  Future<FamiliaModel> getFamiliaById(int codFamilia) async {
    final response = await _client.get('/familias/$codFamilia');

    if (response.data['success'] == true) {
      return FamiliaModel.fromJson(response.data['data']);
    }

    throw Exception('Error al obtener familia: ${response.data['message']}');
  }

  @override
  Future<FamiliaModel> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  }) async {
    final response = await _client.put(
      '/familias/$codFamilia',
      data: {
        'codFamilia': codFamilia,
        'familia': familia,
        'audUsuario': audUsuario,
      },
    );

    if (response.data['success'] == true) {
      // Si el backend retorna el objeto completo
      if (response.data['data'] is Map) {
        return FamiliaModel.fromJson(response.data['data']);
      }
      // Si solo confirma, hacer un GET
      return await getFamiliaById(codFamilia);
    }

    throw Exception('Error al actualizar familia: ${response.data['message']}');
  }

  @override
  Future<void> deleteFamilia(int codFamilia) async {
    final response = await _client.delete('/familias/$codFamilia');

    if (response.data['success'] != true) {
      throw Exception('Error al eliminar familia: ${response.data['message']}');
    }
  }
}
