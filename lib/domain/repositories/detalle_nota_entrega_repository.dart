import '../../core/utils/operation_result.dart';
import '../entities/detalle_nota_entrega_entity.dart';

abstract class DetalleNotaEntregaRepository {
  /// Listar detalles de una nota de entrega
  Future<OperationResult<List<DetalleNotaEntregaEntity>>> listarPorNotaEntrega(
    int codNotaEntrega,
  );

  /// Buscar detalle por código
  Future<OperationResult<DetalleNotaEntregaEntity>> buscarPorCodigo(int codDetalle);

  /// Crear un nuevo detalle en una nota de entrega
  Future<OperationResult<DetalleNotaEntregaEntity>> crear(
    int codNotaEntrega,
    DetalleNotaEntregaEntity detalle,
  );

  /// Actualizar un detalle existente
  Future<OperationResult<DetalleNotaEntregaEntity>> actualizar(
    int codDetalle,
    DetalleNotaEntregaEntity detalle,
  );

  /// Eliminar un detalle
  Future<OperationResult<void>> eliminar(int codDetalle);
}
