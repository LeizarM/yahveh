import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detalle_nota_entrega_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import 'providers.dart';

/// Notifier del proveedor de detalles de nota de entrega
class DetalleNotaEntregaNotifier extends Notifier<AsyncValue<List<DetalleNotaEntregaEntity>>> {
  @override
  AsyncValue<List<DetalleNotaEntregaEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar detalles de una nota de entrega
  Future<void> cargarDetallesPorNota(int codNotaEntrega) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(detalleNotaEntregaRepositoryProvider);
      final result = await repository.listarPorNotaEntrega(codNotaEntrega);
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar detalles', st);
    }
  }

  /// Buscar detalle por código
  Future<DetalleNotaEntregaEntity?> buscarPorCodigo(int codDetalle) async {
    try {
      final repository = ref.read(detalleNotaEntregaRepositoryProvider);
      final result = await repository.buscarPorCodigo(codDetalle);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al buscar detalle', statusCode: 500);
    }
  }

  /// Crear nuevo detalle en una nota de entrega
  Future<OperationResult<DetalleNotaEntregaEntity>?> crear(
    int codNotaEntrega,
    DetalleNotaEntregaEntity detalle,
  ) async {
    try {
      final repository = ref.read(detalleNotaEntregaRepositoryProvider);
      final result = await repository.crear(codNotaEntrega, detalle);
      
      // Recargar detalles de la nota
      await cargarDetallesPorNota(codNotaEntrega);
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al crear detalle', statusCode: 500);
    }
  }

  /// Actualizar un detalle existente
  Future<OperationResult<DetalleNotaEntregaEntity>?> actualizar(
    int codDetalle,
    DetalleNotaEntregaEntity detalle,
  ) async {
    try {
      final repository = ref.read(detalleNotaEntregaRepositoryProvider);
      final result = await repository.actualizar(codDetalle, detalle);
      
      // Recargar detalles de la nota
      await cargarDetallesPorNota(detalle.codNotaEntrega);
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al actualizar detalle', statusCode: 500);
    }
  }

  /// Eliminar un detalle
  Future<OperationResult<void>?> eliminar(int codDetalle, int codNotaEntrega) async {
    try {
      final repository = ref.read(detalleNotaEntregaRepositoryProvider);
      final result = await repository.eliminar(codDetalle);
      
      // Recargar detalles de la nota
      await cargarDetallesPorNota(codNotaEntrega);
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al eliminar detalle', statusCode: 500);
    }
  }
}
