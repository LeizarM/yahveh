import 'dart:typed_data';
import '../../core/utils/operation_result.dart';
import '../entities/nota_entrega_entity.dart';

abstract class NotaEntregaRepository {
  /// Listar todas las notas de entrega válidas
  Future<OperationResult<List<NotaEntregaEntity>>> listar();

  /// Listar todas las notas (válidas y anuladas)
  Future<OperationResult<List<NotaEntregaEntity>>> listarTodas();

  /// Listar solo notas anuladas
  Future<OperationResult<List<NotaEntregaEntity>>> listarAnuladas();

  /// Buscar nota de entrega por código
  Future<OperationResult<NotaEntregaEntity>> buscarPorCodigo(int codNotaEntrega);

  /// Listar notas de entrega por cliente
  Future<OperationResult<List<NotaEntregaEntity>>> listarPorCliente(int codCliente);

  /// Listar notas de entrega por rango de fechas
  Future<OperationResult<List<NotaEntregaEntity>>> listarPorFechas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  /// Crear una nueva nota de entrega
  Future<OperationResult<NotaEntregaEntity>> crear(NotaEntregaEntity notaEntrega);

  /// Actualizar una nota de entrega existente
  Future<OperationResult<NotaEntregaEntity>> actualizar(
    int codNotaEntrega,
    NotaEntregaEntity notaEntrega,
  );

  /// Anular una nota de entrega (devuelve stock automáticamente)
  Future<OperationResult<NotaEntregaEntity>> anular(int codNotaEntrega);

  /// Eliminar una nota de entrega
  Future<OperationResult<void>> eliminar(int codNotaEntrega);

  /// Generar PDF de la nota de entrega
  Future<OperationResult<Uint8List>> generarPDF(int codNotaEntrega);
}
