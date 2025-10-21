import '../../domain/entities/linea_entity.dart';
import '../../domain/repositories/linea_repository.dart';
import '../datasources/linea_remote_datasource.dart';

/// Implementación del repositorio de Líneas
class LineaRepositoryImpl implements LineaRepository {
  final LineaRemoteDataSource _remoteDataSource;

  LineaRepositoryImpl({
    required LineaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LineaEntity> createLinea({
    required String linea,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createLinea(
      linea: linea,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<LineaEntity>> getLineas() async {
    return await _remoteDataSource.getLineas();
  }

  @override
  Future<LineaEntity> getLineaById(int codLinea) async {
    return await _remoteDataSource.getLineaById(codLinea);
  }

  @override
  Future<LineaEntity> updateLinea({
    required int codLinea,
    required String linea,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateLinea(
      codLinea: codLinea,
      linea: linea,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteLinea(int codLinea) async {
    return await _remoteDataSource.deleteLinea(codLinea);
  }
}
