import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import 'providers.dart';

/// Notifier del proveedor de notas de entrega
class NotaEntregaNotifier extends Notifier<AsyncValue<List<NotaEntregaEntity>>> {
  @override
  AsyncValue<List<NotaEntregaEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar todas las notas de entrega
  Future<void> cargarNotas() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas de entrega', st);
    }
  }

  /// Cargar notas por cliente
  Future<void> cargarNotasPorCliente(int codCliente) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarPorCliente(codCliente);
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas del cliente', st);
    }
  }

  /// Cargar notas por rango de fechas
  Future<void> cargarNotasPorFechas({DateTime? fechaInicio, DateTime? fechaFin}) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarPorFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas por fechas', st);
    }
  }

  /// Buscar nota por código
  Future<NotaEntregaEntity?> buscarPorCodigo(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.buscarPorCodigo(codNotaEntrega);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al buscar nota', statusCode: 500);
    }
  }

  /// Crear nueva nota de entrega
  Future<OperationResult<NotaEntregaEntity>?> crear(NotaEntregaEntity notaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.crear(notaEntrega);
      
      // Recargar lista de notas
      await cargarNotas();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al crear nota de entrega', statusCode: 500);
    }
  }

  /// Actualizar nota de entrega existente
  Future<OperationResult<NotaEntregaEntity>?> actualizar(
    int codNotaEntrega,
    NotaEntregaEntity notaEntrega,
  ) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.actualizar(codNotaEntrega, notaEntrega);
      
      // Recargar lista de notas
      await cargarNotas();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al actualizar nota', statusCode: 500);
    }
  }

  /// Eliminar nota de entrega
  Future<OperationResult<void>?> eliminar(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.eliminar(codNotaEntrega);
      
      // Recargar lista de notas
      await cargarNotas();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al eliminar nota', statusCode: 500);
    }
  }
}
