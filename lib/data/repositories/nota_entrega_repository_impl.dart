import 'dart:typed_data';
import '../../core/utils/operation_result.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../domain/repositories/nota_entrega_repository.dart';
import '../datasources/nota_entrega_remote_datasource.dart';
import '../models/nota_entrega_model.dart';

class NotaEntregaRepositoryImpl implements NotaEntregaRepository {
  final NotaEntregaRemoteDataSource _remoteDataSource;

  NotaEntregaRepositoryImpl({
    required NotaEntregaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<OperationResult<List<NotaEntregaEntity>>> listar() async {
    try {
      final notas = await _remoteDataSource.listar();
      return OperationResult(
        data: notas.map((model) => model.toEntity()).toList(),
        message: 'Notas de entrega válidas obtenidas exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<List<NotaEntregaEntity>>> listarTodas() async {
    try {
      final notas = await _remoteDataSource.listarTodas();
      return OperationResult(
        data: notas.map((model) => model.toEntity()).toList(),
        message: 'Todas las notas de entrega obtenidas exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<List<NotaEntregaEntity>>> listarAnuladas() async {
    try {
      final notas = await _remoteDataSource.listarAnuladas();
      return OperationResult(
        data: notas.map((model) => model.toEntity()).toList(),
        message: 'Notas anuladas obtenidas exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<NotaEntregaEntity>> buscarPorCodigo(int codNotaEntrega) async {
    try {
      final nota = await _remoteDataSource.buscarPorCodigo(codNotaEntrega);
      return OperationResult(
        data: nota.toEntity(),
        message: 'Nota de entrega encontrada',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<List<NotaEntregaEntity>>> listarPorCliente(int codCliente) async {
    try {
      final notas = await _remoteDataSource.listarPorCliente(codCliente);
      return OperationResult(
        data: notas.map((model) => model.toEntity()).toList(),
        message: 'Notas del cliente obtenidas',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<List<NotaEntregaEntity>>> listarPorFechas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final notas = await _remoteDataSource.listarPorFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      return OperationResult(
        data: notas.map((model) => model.toEntity()).toList(),
        message: 'Notas por fechas obtenidas',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<NotaEntregaEntity>> crear(NotaEntregaEntity notaEntrega) async {
    try {
      final model = NotaEntregaModel(
        codNotaEntrega: notaEntrega.codNotaEntrega,
        codCliente: notaEntrega.codCliente,
        nombreCliente: notaEntrega.nombreCliente,
        fecha: notaEntrega.fecha,
        direccion: notaEntrega.direccion,
        zona: notaEntrega.zona,
        estado: notaEntrega.estado,
        estadoTexto: notaEntrega.estadoTexto,
        audUsuario: notaEntrega.audUsuario,
      );
      
      final nuevaNota = await _remoteDataSource.crear(model);
      return OperationResult(
        data: nuevaNota.toEntity(),
        message: 'Nota de entrega creada exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<NotaEntregaEntity>> actualizar(
    int codNotaEntrega,
    NotaEntregaEntity notaEntrega,
  ) async {
    try {
      final model = NotaEntregaModel(
        codNotaEntrega: notaEntrega.codNotaEntrega,
        codCliente: notaEntrega.codCliente,
        nombreCliente: notaEntrega.nombreCliente,
        fecha: notaEntrega.fecha,
        direccion: notaEntrega.direccion,
        zona: notaEntrega.zona,
        estado: notaEntrega.estado,
        estadoTexto: notaEntrega.estadoTexto,
        audUsuario: notaEntrega.audUsuario,
      );
      
      final notaActualizada = await _remoteDataSource.actualizar(codNotaEntrega, model);
      return OperationResult(
        data: notaActualizada.toEntity(),
        message: 'Nota de entrega actualizada',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<NotaEntregaEntity>> anular(int codNotaEntrega) async {
    try {
      final notaAnulada = await _remoteDataSource.anular(codNotaEntrega);
      return OperationResult(
        data: notaAnulada.toEntity(),
        message: 'Nota de entrega anulada. Stock devuelto al inventario',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<void>> eliminar(int codNotaEntrega) async {
    try {
      await _remoteDataSource.eliminar(codNotaEntrega);
      return OperationResult(
        data: null,
        message: 'Nota de entrega eliminada',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<Uint8List>> generarPDF(int codNotaEntrega) async {
    try {
      final pdfBytes = await _remoteDataSource.generarPDF(codNotaEntrega);
      return OperationResult(
        data: pdfBytes,
        message: 'PDF generado exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }
}
