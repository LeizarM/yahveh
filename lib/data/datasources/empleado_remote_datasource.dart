import '../../core/network/dio_client.dart';
import '../models/empleado_model.dart';

/// DataSource remoto para Empleado
class EmpleadoRemoteDataSource {
  final DioClient dioClient;

  EmpleadoRemoteDataSource({required this.dioClient});

  /// Listar todos los empleados
  Future<List<EmpleadoModel>> listar() async {
    try {
      print('📤 GET /empleados - Listando empleados');
      
      final response = await dioClient.get('/empleados');
      
      print('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => EmpleadoModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error al listar empleados: $e');
      rethrow;
    }
  }

  /// Buscar empleado por código
  Future<EmpleadoModel> buscarPorCodigo(int codEmpleado) async {
    try {
      print('📤 GET /empleados/$codEmpleado');
      
      final response = await dioClient.get('/empleados/$codEmpleado');
      
      print('📥 Response: ${response.statusCode}');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al buscar empleado: $e');
      rethrow;
    }
  }

  /// Buscar empleado por persona
  Future<EmpleadoModel> buscarPorPersona(int codPersona) async {
    try {
      print('📤 GET /empleados/persona/$codPersona');
      
      final response = await dioClient.get('/empleados/persona/$codPersona');
      
      print('📥 Response: ${response.statusCode}');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al buscar empleado por persona: $e');
      rethrow;
    }
  }

  /// Buscar empleados por nombre
  Future<List<EmpleadoModel>> buscarPorNombre(String nombre) async {
    try {
      print('📤 GET /empleados/buscar?nombre=$nombre');
      
      final response = await dioClient.get('/empleados/buscar', queryParameters: {
        'nombre': nombre,
      });
      
      print('📥 Response: ${response.statusCode}');
      
      final List<dynamic> data = response.data['data'] as List;
      return data.map((json) => EmpleadoModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error al buscar empleados por nombre: $e');
      rethrow;
    }
  }

  /// Crear empleado
  Future<EmpleadoModel> crear(EmpleadoModel empleado) async {
    try {
      print('📤 POST /empleados');
      print('   Body: ${empleado.toCreateJson()}');
      
      final response = await dioClient.post(
        '/empleados',
        data: empleado.toCreateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Empleado creado exitosamente');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al crear empleado: $e');
      rethrow;
    }
  }

  /// Actualizar empleado
  Future<EmpleadoModel> actualizar(int codEmpleado, EmpleadoModel empleado) async {
    try {
      print('📤 PUT /empleados/$codEmpleado');
      print('   Body: ${empleado.toUpdateJson()}');
      
      final response = await dioClient.put(
        '/empleados/$codEmpleado',
        data: empleado.toUpdateJson(),
      );
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Empleado actualizado exitosamente');
      
      return EmpleadoModel.fromJson(response.data['data']);
    } catch (e) {
      print('❌ Error al actualizar empleado: $e');
      rethrow;
    }
  }

  /// Eliminar empleado
  Future<void> eliminar(int codEmpleado) async {
    try {
      print('📤 DELETE /empleados/$codEmpleado');
      
      final response = await dioClient.delete('/empleados/$codEmpleado');
      
      print('📥 Response: ${response.statusCode}');
      print('✅ Empleado eliminado exitosamente');
    } catch (e) {
      print('❌ Error al eliminar empleado: $e');
      rethrow;
    }
  }
}
