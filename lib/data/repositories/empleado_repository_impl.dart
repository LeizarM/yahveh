import '../../core/utils/operation_result.dart';
import '../../domain/entities/empleado_entity.dart';
import '../../domain/repositories/empleado_repository.dart';
import '../datasources/empleado_remote_datasource.dart';
import '../models/empleado_model.dart';

/// Implementación del repositorio de Empleado
class EmpleadoRepositoryImpl implements EmpleadoRepository {
  final EmpleadoRemoteDataSource remoteDataSource;

  EmpleadoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OperationResult<List<EmpleadoEntity>>> listar() async {
    final models = await remoteDataSource.listar();
    final entities = models.map((m) => m.toEntity()).toList();
    return OperationResult(data: entities, message: 'Empleados obtenidos');
  }

  @override
  Future<OperationResult<EmpleadoEntity>> buscarPorCodigo(int codEmpleado) async {
    final model = await remoteDataSource.buscarPorCodigo(codEmpleado);
    return OperationResult(data: model.toEntity(), message: 'Empleado encontrado');
  }

  @override
  Future<OperationResult<EmpleadoEntity>> buscarPorPersona(int codPersona) async {
    final model = await remoteDataSource.buscarPorPersona(codPersona);
    return OperationResult(data: model.toEntity(), message: 'Empleado encontrado');
  }

  @override
  Future<OperationResult<List<EmpleadoEntity>>> buscarPorNombre(String nombre) async {
    final models = await remoteDataSource.buscarPorNombre(nombre);
    final entities = models.map((m) => m.toEntity()).toList();
    return OperationResult(data: entities, message: 'Empleados encontrados');
  }

  @override
  Future<OperationResult<EmpleadoEntity>> crear({
    required int codPersona,
  }) async {
    final model = EmpleadoModel(
      codEmpleado: 0,
      codPersona: codPersona,
      audUsuario: 0,
    );

    final createdModel = await remoteDataSource.crear(model);
    return OperationResult(data: createdModel.toEntity(), message: 'Empleado creado');
  }

  @override
  Future<OperationResult<EmpleadoEntity>> actualizar({
    required int codEmpleado,
    required int codPersona,
  }) async {
    final model = EmpleadoModel(
      codEmpleado: codEmpleado,
      codPersona: codPersona,
      audUsuario: 0,
    );

    final updatedModel = await remoteDataSource.actualizar(codEmpleado, model);
    return OperationResult(data: updatedModel.toEntity(), message: 'Empleado actualizado');
  }

  @override
  Future<OperationResult<void>> eliminar(int codEmpleado) async {
    await remoteDataSource.eliminar(codEmpleado);
    return const OperationResult(data: null, message: 'Empleado eliminado');
  }
}
