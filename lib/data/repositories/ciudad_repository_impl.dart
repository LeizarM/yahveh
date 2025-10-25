import '../../domain/entities/ciudad_entity.dart';
import '../../domain/repositories/ciudad_repository.dart';
import '../datasources/ciudad_remote_datasource.dart';

/// Implementación del repositorio de Ciudades
class CiudadRepositoryImpl implements CiudadRepository {
  final CiudadRemoteDataSource _remoteDataSource;

  CiudadRepositoryImpl({
    required CiudadRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<CiudadEntity> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createCiudad(
      codPais: codPais,
      ciudad: ciudad,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<CiudadEntity>> getCiudades() async {
    return await _remoteDataSource.getCiudades();
  }

  @override
  Future<CiudadEntity> getCiudadById(int codCiudad) async {
    return await _remoteDataSource.getCiudadById(codCiudad);
  }

  @override
  Future<CiudadEntity> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateCiudad(
      codCiudad: codCiudad,
      codPais: codPais,
      ciudad: ciudad,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteCiudad(int codCiudad) async {
    return await _remoteDataSource.deleteCiudad(codCiudad);
  }
}
