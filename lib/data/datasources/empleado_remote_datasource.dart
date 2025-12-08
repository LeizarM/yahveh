import '../../core/network/dio_client.dart';
import '../models/empleado_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';

/// DataSource remoto para Empleado
class EmpleadoRemoteDataSource {
  final DioClient dioClient;

  EmpleadoRemoteDataSource({required this.dioClient});

  /// Listar todos los empleados
  Future<List<EmpleadoModel>> listar() async {
    try {
      console('📤 GET /empleados - Listando empleados');
      
      final response = await dioClient.get('/empleados');
      
      console('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => EmpleadoModel.fromJson(json)).toList();
    } catch (e) {
      console('❌ Error al listar empleados: $e');
      rethrow;
    }
  }

  /// Buscar empleado por código
  Future<EmpleadoModel> buscarPorCodigo(int codEmpleado) async {
    try {
      console('📤 GET /empleados/$codEmpleado');
      
      final response = await dioClient.get('/empleados/$codEmpleado');
      
      console('📥 Response: ${response.statusCode}');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al buscar empleado: $e');
      rethrow;
    }
  }

  /// Buscar empleado por persona
  Future<EmpleadoModel> buscarPorPersona(int codPersona) async {
    try {
      console('📤 GET /empleados/persona/$codPersona');
      
      final response = await dioClient.get('/empleados/persona/$codPersona');
      
      console('📥 Response: ${response.statusCode}');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al buscar empleado por persona: $e');
      rethrow;
    }
  }

  /// Buscar empleados por nombre
  Future<List<EmpleadoModel>> buscarPorNombre(String nombre) async {
    try {
      console('📤 GET /empleados/buscar?nombre=$nombre');
      
      final response = await dioClient.get('/empleados/buscar', queryParameters: {
        'nombre': nombre,
      });
      
      console('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => EmpleadoModel.fromJson(json)).toList();
    } catch (e) {
      console('❌ Error al buscar empleados por nombre: $e');
      rethrow;
    }
  }

  /// Crear empleado
  Future<EmpleadoModel> crear(EmpleadoModel empleado) async {
    try {
      console('📤 POST /empleados');
      console('   Body: ${empleado.toCreateJson()}');
      
      final response = await dioClient.post(
        '/empleados',
        data: empleado.toCreateJson(),
      );
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Empleado creado exitosamente');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al crear empleado: $e');
      rethrow;
    }
  }

  /// Actualizar empleado
  Future<EmpleadoModel> actualizar(int codEmpleado, EmpleadoModel empleado) async {
    try {
      console('📤 PUT /empleados/$codEmpleado');
      console('   Body: ${empleado.toUpdateJson()}');
      
      final response = await dioClient.put(
        '/empleados/$codEmpleado',
        data: empleado.toUpdateJson(),
      );
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Empleado actualizado exitosamente');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      console('❌ Error al actualizar empleado: $e');
      rethrow;
    }
  }

  /// Eliminar empleado
  Future<void> eliminar(int codEmpleado) async {
    try {
      console('📤 DELETE /empleados/$codEmpleado');
      
      final response = await dioClient.delete('/empleados/$codEmpleado');
      
      console('📥 Response: ${response.statusCode}');
      console('✅ Empleado eliminado exitosamente');
    } catch (e) {
      console('❌ Error al eliminar empleado: $e');
      rethrow;
    }
  }
}
