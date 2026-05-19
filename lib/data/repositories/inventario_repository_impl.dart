import '../../domain/entities/inventario_entity.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../../core/utils/operation_result.dart';
import '../datasources/inventario_remote_datasource.dart';

/// Implementación del repositorio de Inventario
class InventarioRepositoryImpl implements InventarioRepository {
  final InventarioRemoteDataSource _remoteDataSource;

  InventarioRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<InventarioEntity>> listar() async {
    final models = await _remoteDataSource.listar();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventarioEntity> buscarPorCodigo(int codInventario) async {
    final model = await _remoteDataSource.buscarPorCodigo(codInventario);
    return model.toEntity();
  }

  @override
  Future<List<InventarioEntity>> listarPorArticulo(String codArticulo) async {
    final models = await _remoteDataSource.listarPorArticulo(codArticulo);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventarioEntity>> listarPorTipo(String tipoMovimiento) async {
    final models = await _remoteDataSource.listarPorTipo(tipoMovimiento);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<InventarioEntity>> listarPorFechas({
    required DateTime? desde,
    required DateTime? hasta,
  }) async {
    final models = await _remoteDataSource.listarPorFechas(
      desde: desde,
      hasta: hasta,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<OperationResult<InventarioEntity>> crear({
    required String codArticulo,
    required String tipoMovimiento,
    required int cantidad,
    required double precioUnitario,
    String? observacion,
    String? codImportacion,
  }) async {
    final result = await _remoteDataSource.crear(
      codArticulo: codArticulo,
      tipoMovimiento: tipoMovimiento,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      observacion: observacion,
      codImportacion: codImportacion,
    );
    
    return OperationResult(
      data: result.data.toEntity(),
      message: result.message,
    );
  }

  @override
  Future<OperationResult<InventarioEntity>> modificar({
    required int codInventario,
    required String? observacion,
  }) async {
    final result = await _remoteDataSource.modificar(
      codInventario: codInventario,
      observacion: observacion,
    );
    
    return OperationResult(
      data: result.data.toEntity(),
      message: result.message,
    );
  }

  @override
  Future<OperationResult<void>> eliminar(int codInventario) async {
    return await _remoteDataSource.eliminar(codInventario);
  }
}
