import '../../core/network/dio_client.dart';
import '../models/persona_model.dart';

/// DataSource remoto para Persona
class PersonaRemoteDataSource {
  final DioClient dioClient;

  PersonaRemoteDataSource({required this.dioClient});

  /// Listar todas las personas
  Future<List<PersonaModel>> listar() async {
    try {
      print('📤 GET /personas - Listando personas');
      
      final response = await dioClient.get('/personas');
      
      print('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => PersonaModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error al listar personas: $e');
      rethrow;
    }
  }

  /// Buscar persona por código
  Future<PersonaModel> buscarPorCodigo(int codPersona) async {
    try {
      print('📤 GET /personas/$codPersona');
      
      final response = await dioClient.get('/personas/$codPersona');
      
      print('📥 Response: ${response.statusCode}');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al buscar persona: $e');
      rethrow;
    }
  }

  /// Buscar persona por CI
  Future<PersonaModel> buscarPorCI(String ciNumero, String ciExpedido) async {
    try {
      print('📤 GET /personas/ci/$ciNumero/$ciExpedido');
      
      final response = await dioClient.get('/personas/ci/$ciNumero/$ciExpedido');
      
      print('📥 Response: ${response.statusCode}');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al buscar persona por CI: $e');
      rethrow;
    }
  }

  /// Buscar personas por nombre
  Future<List<PersonaModel>> buscarPorNombre(String nombre) async {
    try {
      print('📤 GET /personas/buscar?nombre=$nombre');
      
      final response = await dioClient.get('/personas/buscar', queryParameters: {
        'nombre': nombre,
      });
      
      print('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => PersonaModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error al buscar personas por nombre: $e');
      rethrow;
    }
  }

  /// Crear persona
  Future<PersonaModel> crear(PersonaModel persona) async {
    try {
      print('📤 POST /personas');
      print('   Body: ${persona.toCreateJson()}');
      
      final response = await dioClient.post(
        '/personas',
        data: persona.toCreateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Persona creada exitosamente');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al crear persona: $e');
      rethrow;
    }
  }

  /// Actualizar persona
  Future<PersonaModel> actualizar(int codPersona, PersonaModel persona) async {
    try {
      print('📤 PUT /personas/$codPersona');
      print('   Body: ${persona.toUpdateJson()}');
      
      final response = await dioClient.put(
        '/personas/$codPersona',
        data: persona.toUpdateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Persona actualizada exitosamente');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al actualizar persona: $e');
      rethrow;
    }
  }

  /// Eliminar persona
  Future<void> eliminar(int codPersona) async {
    try {
      print('📤 DELETE /personas/$codPersona');
      
      final response = await dioClient.delete('/personas/$codPersona');
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Persona eliminada exitosamente');
    } catch (e) {
      print('❌ Error al eliminar persona: $e');
      rethrow;
    }
  }
}
