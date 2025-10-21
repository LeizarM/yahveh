import '../../domain/entities/articulo_entity.dart';
import '../../domain/repositories/articulo_repository.dart';
import '../datasources/articulo_remote_datasource.dart';

/// Implementación del repositorio de artículos
class ArticuloRepositoryImpl implements ArticuloRepository {
  final ArticuloRemoteDataSource _remoteDataSource;

  ArticuloRepositoryImpl(this._remoteDataSource);

  @override
  Future<ArticuloEntity> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createArticulo(
      codArticulo: codArticulo,
      codLinea: codLinea,
      descripcion: descripcion,
      descripcion2: descripcion2,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<ArticuloEntity>> getArticulos() async {
    return await _remoteDataSource.getArticulos();
  }

  @override
  Future<ArticuloEntity> getArticuloById(String codArticulo) async {
    return await _remoteDataSource.getArticuloById(codArticulo);
  }

  @override
  Future<ArticuloEntity> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateArticulo(
      codArticulo: codArticulo,
      codLinea: codLinea,
      descripcion: descripcion,
      descripcion2: descripcion2,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteArticulo(String codArticulo) async {
    return await _remoteDataSource.deleteArticulo(codArticulo);
  }
}
