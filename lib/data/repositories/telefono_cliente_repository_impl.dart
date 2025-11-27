import '../../core/utils/operation_result.dart';
import '../../domain/entities/telefono_cliente_entity.dart';
import '../../domain/repositories/telefono_cliente_repository.dart';
import '../datasources/telefono_cliente_remote_datasource.dart';
import '../models/telefono_cliente_model.dart';

/// Implementación del repositorio de Teléfono de Cliente
class TelefonoClienteRepositoryImpl implements TelefonoClienteRepository {
  final TelefonoClienteRemoteDataSource remoteDataSource;

  TelefonoClienteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OperationResult<List<TelefonoClienteEntity>>> listar() async {
    final result = await remoteDataSource.listar();
    return OperationResult(
      data: result.map((model) => model.toEntity()).toList(),
      message: 'Teléfonos listados exitosamente',
    );
  }

  @override
  Future<OperationResult<TelefonoClienteEntity>> buscarPorCodigo(int codTlfCliente) async {
    final result = await remoteDataSource.buscarPorCodigo(codTlfCliente);
    return OperationResult(
      data: result.toEntity(),
      message: 'Teléfono encontrado',
    );
  }

  @override
  Future<OperationResult<List<TelefonoClienteEntity>>> listarPorCliente(int codCliente) async {
    final result = await remoteDataSource.listarPorCliente(codCliente);
    return OperationResult(
      data: result.map((model) => model.toEntity()).toList(),
      message: 'Teléfonos del cliente listados exitosamente',
    );
  }

  @override
  Future<OperationResult<TelefonoClienteEntity>> crear({
    required int codCliente,
    required String telefono,
  }) async {
    final model = TelefonoClienteModel(
      codTlfCliente: 0,
      codCliente: codCliente,
      telefono: telefono,
      audUsuario: 0,
    );
    final result = await remoteDataSource.crear(model);
    return OperationResult(
      data: result.toEntity(),
      message: 'Teléfono creado exitosamente',
    );
  }

  @override
  Future<OperationResult<TelefonoClienteEntity>> actualizar({
    required int codTlfCliente,
    required int codCliente,
    required String telefono,
  }) async {
    final model = TelefonoClienteModel(
      codTlfCliente: codTlfCliente,
      codCliente: codCliente,
      telefono: telefono,
      audUsuario: 0,
    );
    final result = await remoteDataSource.actualizar(codTlfCliente, model);
    return OperationResult(
      data: result.toEntity(),
      message: 'Teléfono actualizado exitosamente',
    );
  }

  @override
  Future<OperationResult<void>> eliminar(int codTlfCliente) async {
    await remoteDataSource.eliminar(codTlfCliente);
    return OperationResult(
      data: null,
      message: 'Teléfono eliminado exitosamente',
    );
  }
}
