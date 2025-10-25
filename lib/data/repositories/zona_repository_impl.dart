import '../../domain/entities/zona_entity.dart';
import '../../domain/repositories/zona_repository.dart';
import '../datasources/zona_remote_datasource.dart';

/// Implementación del repositorio de Zonas
class ZonaRepositoryImpl implements ZonaRepository {
  final ZonaRemoteDataSource _remoteDataSource;

  ZonaRepositoryImpl({
    required ZonaRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ZonaEntity> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createZona(
      codCiudad: codCiudad,
      zona: zona,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<ZonaEntity>> getZonas() async {
    return await _remoteDataSource.getZonas();
  }

  @override
  Future<ZonaEntity> getZonaById(int codZona) async {
    return await _remoteDataSource.getZonaById(codZona);
  }

  @override
  Future<ZonaEntity> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateZona(
      codZona: codZona,
      codCiudad: codCiudad,
      zona: zona,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteZona(int codZona) async {
    return await _remoteDataSource.deleteZona(codZona);
  }
}
