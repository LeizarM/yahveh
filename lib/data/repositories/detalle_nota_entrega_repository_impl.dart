import '../../core/utils/operation_result.dart';
import '../../domain/entities/detalle_nota_entrega_entity.dart';
import '../../domain/repositories/detalle_nota_entrega_repository.dart';
import '../datasources/detalle_nota_entrega_remote_datasource.dart';
import '../models/detalle_nota_entrega_model.dart';

class DetalleNotaEntregaRepositoryImpl implements DetalleNotaEntregaRepository {
  final DetalleNotaEntregaRemoteDataSource _remoteDataSource;

  DetalleNotaEntregaRepositoryImpl({
    required DetalleNotaEntregaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<OperationResult<List<DetalleNotaEntregaEntity>>> listarPorNotaEntrega(
    int codNotaEntrega,
  ) async {
    try {
      final detalles = await _remoteDataSource.listarPorNotaEntrega(codNotaEntrega);
      return OperationResult(
        data: detalles.map((model) => model.toEntity()).toList(),
        message: 'Detalles obtenidos exitosamente',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OperationResult<DetalleNotaEntregaEntity>> buscarPorCodigo(int codDetalle) async {
    try {
      final detalle = await _remoteDataSource.buscarPorCodigo(codDetalle);
      return OperationResult(
        data: detalle.toEntity(),
        message: 'Detalle encontrado',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OperationResult<DetalleNotaEntregaEntity>> crear(
    int codNotaEntrega,
    DetalleNotaEntregaEntity detalle,
  ) async {
    try {
      final model = DetalleNotaEntregaModel(
        codDetalle: detalle.codDetalle,
        codNotaEntrega: detalle.codNotaEntrega,
        codArticulo: detalle.codArticulo,
        descripcionArticulo: detalle.descripcionArticulo,
        descripcion2Articulo: detalle.descripcion2Articulo,
        lineaArticulo: detalle.lineaArticulo,
        codLinea: detalle.codLinea,
        cantidad: detalle.cantidad,
        precioUnitario: detalle.precioUnitario,
        precioTotal: detalle.precioTotal,
        precioSinFactura: detalle.precioSinFactura,
        audUsuario: detalle.audUsuario,
      );
      
      final nuevoDetalle = await _remoteDataSource.crear(codNotaEntrega, model);
      return OperationResult(
        data: nuevoDetalle.toEntity(),
        message: 'Detalle creado exitosamente',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OperationResult<DetalleNotaEntregaEntity>> actualizar(
    int codDetalle,
    DetalleNotaEntregaEntity detalle,
  ) async {
    try {
      final model = DetalleNotaEntregaModel(
        codDetalle: detalle.codDetalle,
        codNotaEntrega: detalle.codNotaEntrega,
        codArticulo: detalle.codArticulo,
        descripcionArticulo: detalle.descripcionArticulo,
        descripcion2Articulo: detalle.descripcion2Articulo,
        lineaArticulo: detalle.lineaArticulo,
        codLinea: detalle.codLinea,
        cantidad: detalle.cantidad,
        precioUnitario: detalle.precioUnitario,
        precioTotal: detalle.precioTotal,
        precioSinFactura: detalle.precioSinFactura,
        audUsuario: detalle.audUsuario,
      );
      
      final detalleActualizado = await _remoteDataSource.actualizar(codDetalle, model);
      return OperationResult(
        data: detalleActualizado.toEntity(),
        message: 'Detalle actualizado',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<OperationResult<void>> eliminar(int codDetalle) async {
    try {
      await _remoteDataSource.eliminar(codDetalle);
      return OperationResult(
        data: null,
        message: 'Detalle eliminado',
      );
    } catch (e) {
      rethrow;
    }
  }
}
