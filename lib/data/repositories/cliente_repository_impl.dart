import '../../domain/entities/cliente_entity.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../core/utils/operation_result.dart';
import '../datasources/cliente_remote_datasource.dart';

/// Implementación del repositorio de Clientes
class ClienteRepositoryImpl implements ClienteRepository {
  final ClienteRemoteDataSource _remoteDataSource;

  ClienteRepositoryImpl({
    required ClienteRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<OperationResult<ClienteEntity>> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    final result = await _remoteDataSource.createCliente(
      codZona: codZona,
      nit: nit,
      razonSocial: razonSocial,
      nombreCliente: nombreCliente,
      direccion: direccion,
      referencia: referencia,
      obs: obs,
      audUsuario: audUsuario,
    );
    return OperationResult(
      data: result.data,
      message: result.message,
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
  Future<OperationResult<ClienteEntity>> updateCliente({
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
    final result = await _remoteDataSource.updateCliente(
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
    return OperationResult(
      data: result.data,
      message: result.message,
    );
  }

  @override
  Future<OperationResult<void>> deleteCliente(int codCliente) async {
    return await _remoteDataSource.deleteCliente(codCliente);
  }
}
