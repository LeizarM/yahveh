import '../../core/utils/operation_result.dart';
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
  Future<OperationResult<LineaEntity>> createLinea({
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createLinea(
      codFamilia: codFamilia,
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
  Future<OperationResult<LineaEntity>> updateLinea({
    required int codLinea,
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateLinea(
      codLinea: codLinea,
      codFamilia: codFamilia,
      linea: linea,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<OperationResult<void>> deleteLinea(int codLinea) async {
    return await _remoteDataSource.deleteLinea(codLinea);
  }
}
