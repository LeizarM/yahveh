import '../../core/utils/operation_result.dart';
import '../entities/inventario_entity.dart';

/// Repositorio abstracto para operaciones con inventario
abstract class InventarioRepository {
  /// Listar todos los movimientos de inventario
  Future<List<InventarioEntity>> listar();

  /// Buscar un movimiento por código
  Future<InventarioEntity> buscarPorCodigo(int codInventario);

  /// Listar movimientos por artículo
  Future<List<InventarioEntity>> listarPorArticulo(String codArticulo);

  /// Listar movimientos por tipo
  Future<List<InventarioEntity>> listarPorTipo(String tipoMovimiento);

  /// Listar movimientos por rango de fechas
  Future<List<InventarioEntity>> listarPorFechas({
    required DateTime? desde,
    required DateTime? hasta,
  });

  /// Crear un nuevo movimiento de inventario
  Future<OperationResult<InventarioEntity>> crear({
    required String codArticulo,
    required String tipoMovimiento,
    required int cantidad,
    required double precioUnitario,
    String? observacion,
    String? codImportacion,
  });

  /// Modificar un movimiento (solo observación)
  Future<OperationResult<InventarioEntity>> modificar({
    required int codInventario,
    required String? observacion,
  });

  /// Eliminar/reversar un movimiento
  Future<OperationResult<void>> eliminar(int codInventario);
}
