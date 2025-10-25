import '../../domain/entities/cliente_entity.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../datasources/cliente_remote_datasource.dart';

/// Implementación del repositorio de Clientes
class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource _remoteDataSource;

  ClienteRepositoryImpl({
    required ClienteRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ClienteEntity> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.createCliente(
      codZona: codZona,
      nit: nit,
      razonSocial: razonSocial,
      nombreCliente: nombreCliente,
      direccion: direccion,
      referencia: referencia,
      obs: obs,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<List<ClienteEntity>> getClientes() async {
    return await _remoteDataSource.getClientes();
  }

  @override
  Future<ClienteEntity> getClienteById(int codCliente) async {
    return await _remoteDataSource.getClienteById(codCliente);
  }

  @override
  Future<ClienteEntity> updateCliente({
    required int codCliente,
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    return await _remoteDataSource.updateCliente(
      codCliente: codCliente,
      codZona: codZona,
      nit: nit,
      razonSocial: razonSocial,
      nombreCliente: nombreCliente,
      direccion: direccion,
      referencia: referencia,
      obs: obs,
      audUsuario: audUsuario,
    );
  }

  @override
  Future<void> deleteCliente(int codCliente) async {
    return await _remoteDataSource.deleteCliente(codCliente);
  }
}
