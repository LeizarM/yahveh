import '../../core/network/dio_client.dart';
import '../models/persona_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';

/// DataSource remoto para Persona
class PersonaRemoteDataSource {
  final DioClient dioClient;

  PersonaRemoteDataSource({required this.dioClient});

  /// Listar todas las personas
  Future<List<PersonaModel>> listar() async {
    try {
      console('📤 GET /personas - Listando personas');
      
      final response = await dioClient.get('/personas');
      
      console('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => PersonaModel.fromJson(json)).toList();
    } catch (e) {
      console('❌ Error al listar personas: $e');
      rethrow;
    }
  }

  /// Buscar persona por código
  Future<PersonaModel> buscarPorCodigo(int codPersona) async {
    try {
      console('📤 GET /personas/$codPersona');
      
      final response = await dioClient.get('/personas/$codPersona');
      
      console('📥 Response: ${response.statusCode}');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al buscar persona: $e');
      rethrow;
    }
  }

  /// Buscar persona por CI
  Future<PersonaModel> buscarPorCI(String ciNumero, String ciExpedido) async {
    try {
      console('📤 GET /personas/ci/$ciNumero/$ciExpedido');
      
      final response = await dioClient.get('/personas/ci/$ciNumero/$ciExpedido');
      
      console('📥 Response: ${response.statusCode}');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al buscar persona por CI: $e');
      rethrow;
    }
  }

  /// Buscar personas por nombre
  Future<List<PersonaModel>> buscarPorNombre(String nombre) async {
    try {
      console('📤 GET /personas/buscar?nombre=$nombre');
      
      final response = await dioClient.get('/personas/buscar', queryParameters: {
        'nombre': nombre,
      });
      
      console('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => PersonaModel.fromJson(json)).toList();
    } catch (e) {
      console('❌ Error al buscar personas por nombre: $e');
      rethrow;
    }
  }

  /// Crear persona
  Future<PersonaModel> crear(PersonaModel persona) async {
    try {
      console('📤 POST /personas');
      console('   Body: ${persona.toCreateJson()}');
      
      final response = await dioClient.post(
        '/personas',
        data: persona.toCreateJson(),
      );
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Persona creada exitosamente');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al crear persona: $e');
      rethrow;
    }
  }

  /// Actualizar persona
  Future<PersonaModel> actualizar(int codPersona, PersonaModel persona) async {
    try {
      console('📤 PUT /personas/$codPersona');
      console('   Body: ${persona.toUpdateJson()}');
      
      final response = await dioClient.put(
        '/personas/$codPersona',
        data: persona.toUpdateJson(),
      );
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Persona actualizada exitosamente');
      
      return PersonaModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al actualizar persona: $e');
      rethrow;
    }
  }

  /// Eliminar persona
  Future<void> eliminar(int codPersona) async {
    try {
      console('📤 DELETE /personas/$codPersona');
      
      final response = await dioClient.delete('/personas/$codPersona');
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Persona eliminada exitosamente');
    } catch (e) {
      console('❌ Error al eliminar persona: $e');
      rethrow;
    }
  }
}
