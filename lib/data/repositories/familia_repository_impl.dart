import '../../domain/entities/familia_entity.dart';
import '../../domain/repositories/familia_repository.dart';
import '../datasources/familia_remote_datasource.dart';

/// Implementación del repositorio de Familias
class FamiliaRepositoryImpl implements FamiliaRepository {
  final FamiliaRemoteDataSource _remoteDataSource;

  FamiliaRepositoryImpl(this._remoteDataSource);

  @override
  Future<FamiliaEntity> createFamilia({
    required String familia,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createFamilia(
      familia: familia,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<FamiliaEntity>> getAllFamilias() async {
    return await _remoteDataSource.getAllFamilias();
  }

  @override
  Future<FamiliaEntity> getFamiliaById(int codFamilia) async {
    return await _remoteDataSource.getFamiliaById(codFamilia);
  }

  @override
  Future<FamiliaEntity> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateFamilia(
      codFamilia: codFamilia,
      familia: familia,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteFamilia(int codFamilia) async {
    return await _remoteDataSource.deleteFamilia(codFamilia);
  }
}
