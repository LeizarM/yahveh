import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/empleado_entity.dart';
import '../../core/error/api_exception.dart';
import 'providers.dart';

/// Notifier del proveedor de empleados
class EmpleadoNotifier extends Notifier<AsyncValue<List<EmpleadoEntity>>> {
  @override
  AsyncValue<List<EmpleadoEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar todos los empleados
  Future<void> cargarEmpleados() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar empleados', st);
    }
  }

  /// Buscar empleado por código
  Future<EmpleadoEntity?> buscarPorCodigo(int codEmpleado) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      final result = await repository.buscarPorCodigo(codEmpleado);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar empleado', statusCode: 500);
    }
  }

  /// Buscar empleado por persona
  Future<EmpleadoEntity?> buscarPorPersona(int codPersona) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      final result = await repository.buscarPorPersona(codPersona);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar empleado', statusCode: 500);
    }
  }

  /// Buscar empleados por nombre
  Future<List<EmpleadoEntity>> buscarPorNombre(String nombre) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      final result = await repository.buscarPorNombre(nombre);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar empleados', statusCode: 500);
    }
  }

  /// Crear nuevo empleado
  Future<EmpleadoEntity?> crear({
    required int codPersona,
  }) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      final result = await repository.crear(codPersona: codPersona);

      // Recargar lista de empleados
      await cargarEmpleados();

      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al crear empleado', statusCode: 500);
    }
  }

  /// Actualizar empleado existente
  Future<void> actualizar({
    required int codEmpleado,
    required int codPersona,
  }) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      await repository.actualizar(
        codEmpleado: codEmpleado,
        codPersona: codPersona,
      );

      // Recargar lista de empleados
      await cargarEmpleados();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al actualizar empleado', statusCode: 500);
    }
  }

  /// Eliminar empleado
  Future<void> eliminar(int codEmpleado) async {
    try {
      final repository = ref.read(empleadoRepositoryProvider);
      await repository.eliminar(codEmpleado);

      // Recargar lista de empleados
      await cargarEmpleados();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al eliminar empleado', statusCode: 500);
    }
  }
}
