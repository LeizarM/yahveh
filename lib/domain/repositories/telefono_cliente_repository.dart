import '../../core/utils/operation_result.dart';
import '../entities/telefono_cliente_entity.dart';

/// Repositorio de Teléfono de Cliente
abstract class TelefonoClienteRepository {
  /// Listar todos los teléfonos
  Future<OperationResult<List<TelefonoClienteEntity>>> listar();

  /// Buscar teléfono por código
  Future<OperationResult<TelefonoClienteEntity>> buscarPorCodigo(int codTlfCliente);

  /// Listar teléfonos por cliente
  Future<OperationResult<List<TelefonoClienteEntity>>> listarPorCliente(int codCliente);

  /// Crear teléfono
  Future<OperationResult<TelefonoClienteEntity>> crear({
    required int codCliente,
    required String telefono,
  });

  /// Actualizar teléfono
  Future<OperationResult<TelefonoClienteEntity>> actualizar({
    required int codTlfCliente,
    required int codCliente,
    required String telefono,
  });

  /// Eliminar teléfono
  Future<OperationResult<void>> eliminar(int codTlfCliente);
}
