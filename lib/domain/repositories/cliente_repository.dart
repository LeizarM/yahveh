import '../entities/cliente_entity.dart';

/// Repositorio de Clientes
abstract class ClienteRepository {
  /// Crear un nuevo cliente
  Future<ClienteEntity> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  });

  /// Obtener todos los clientes
  Future<List<ClienteEntity>> getClientes();

  /// Obtener un cliente por código
  Future<ClienteEntity> getClienteById(int codCliente);

  /// Actualizar un cliente
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
  });

  /// Eliminar un cliente
  Future<void> deleteCliente(int codCliente);
}
