import '../../domain/entities/pais_entity.dart';
import '../../domain/repositories/pais_repository.dart';
import '../datasources/pais_remote_datasource.dart';

/// Implementación del repositorio de Países
class PaisRepositoryImpl implements PaisRepository {
  final PaisRemoteDataSource _remoteDataSource;

  PaisRepositoryImpl({
    required PaisRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<PaisEntity> createPais({
    required String pais,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createPais(
      pais: pais,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<PaisEntity>> getPaises() async {
    return await _remoteDataSource.getPaises();
  }

  @override
  Future<PaisEntity> getPaisById(int codPais) async {
    return await _remoteDataSource.getPaisById(codPais);
  }

  @override
  Future<PaisEntity> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updatePais(
      codPais: codPais,
      pais: pais,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deletePais(int codPais) async {
    return await _remoteDataSource.deletePais(codPais);
  }
}
