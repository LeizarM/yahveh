import '../../core/utils/operation_result.dart';
import '../entities/empleado_entity.dart';

/// Repositorio de Empleado
abstract class EmpleadoRepository {
  /// Listar todos los empleados
  Future<OperationResult<List<EmpleadoEntity>>> listar();

  /// Buscar empleado por código
  Future<OperationResult<EmpleadoEntity>> buscarPorCodigo(int codEmpleado);

  /// Buscar empleado por persona
  Future<OperationResult<EmpleadoEntity>> buscarPorPersona(int codPersona);

  /// Buscar empleados por nombre
  Future<OperationResult<List<EmpleadoEntity>>> buscarPorNombre(String nombre);

  /// Crear empleado
  Future<OperationResult<EmpleadoEntity>> crear({
    required int codPersona,
  });

  /// Actualizar empleado
  Future<OperationResult<EmpleadoEntity>> actualizar({
    required int codEmpleado,
    required int codPersona,
  });

  /// Eliminar empleado
  Future<OperationResult<void>> eliminar(int codEmpleado);
}
