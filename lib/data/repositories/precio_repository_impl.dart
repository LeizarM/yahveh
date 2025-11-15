import '../../core/utils/operation_result.dart';
import '../../domain/entities/precio_entity.dart';
import '../../domain/repositories/precio_repository.dart';
import '../datasources/precio_remote_datasource.dart';

/// Implementación del repositorio de precios
class PrecioRepositoryImpl implements PrecioRepository {
  final PrecioRemoteDataSource _remoteDataSource;

  PrecioRepositoryImpl(this._remoteDataSource);

  @override
  Future<OperationResult<PrecioEntity>> createPrecio({
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createPrecio(
      codArticulo: codArticulo,
      precioBase: precioBase,
      precio: precio,
      precioSinFactura: precioSinFactura,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<PrecioEntity>> getPrecios() async {
    return await _remoteDataSource.getPrecios();
  }

  @override
  Future<List<PrecioEntity>> getPreciosByArticulo(String codArticulo) async {
    return await _remoteDataSource.getPreciosByArticulo(codArticulo);
  }

  @override
  Future<PrecioEntity> getPrecioById(int codPrecio) async {
    return await _remoteDataSource.getPrecioById(codPrecio);
  }

  @override
  Future<OperationResult<PrecioEntity>> updatePrecio({
    required int codPrecio,
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updatePrecio(
      codPrecio: codPrecio,
      codArticulo: codArticulo,
      precioBase: precioBase,
      precio: precio,
      precioSinFactura: precioSinFactura,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<OperationResult<void>> deletePrecio(int codPrecio) async {
    return await _remoteDataSource.deletePrecio(codPrecio);
  }
}
