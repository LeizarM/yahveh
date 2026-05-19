import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/inventario_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import 'providers.dart';

/// Notifier del proveedor de inventario
class InventarioNotifier extends Notifier<AsyncValue<List<InventarioEntity>>> {
  @override
  AsyncValue<List<InventarioEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar movimientos por artículo
  Future<void> cargarMovimientosPorArticulo(String codArticulo) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(inventarioRepositoryProvider);
      final movimientos = await repository.listarPorArticulo(codArticulo);
      state = AsyncValue.data(movimientos);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar movimientos', st);
    }
  }

  /// Crear movimiento de inventario
  Future<OperationResult<InventarioEntity>?> crearMovimiento({
    required String codArticulo,
    required String tipoMovimiento,
    required int cantidad,
    required double precioUnitario,
    String? observacion,
    String? codImportacion,
  }) async {
    try {
      final repository = ref.read(inventarioRepositoryProvider);
      final result = await repository.crear(
        codArticulo: codArticulo,
        tipoMovimiento: tipoMovimiento,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        observacion: observacion,
        codImportacion: codImportacion,
      );
      
      // Recargar movimientos del artículo
      await cargarMovimientosPorArticulo(codArticulo);
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al crear movimiento', statusCode: 500);
    }
  }
}
