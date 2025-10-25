import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cliente_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de clientes
class ClienteNotifier extends Notifier<AsyncValue<List<ClienteEntity>>> {
  @override
  AsyncValue<List<ClienteEntity>> build() {
    loadClientes();
    return const AsyncValue.loading();
  }

  /// Cargar todos los clientes
  Future<void> loadClientes() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(clienteRepositoryProvider);
      final clientes = await repository.getClientes();
      state = AsyncValue.data(clientes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear un nuevo cliente
  Future<void> createCliente({
    required int codZona,
    required String nit,
    required String razonSocial,
    required String nombreCliente,
    required String direccion,
    required String referencia,
    required String obs,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(clienteRepositoryProvider);
      await repository.createCliente(
        codZona: codZona,
        nit: nit,
        razonSocial: razonSocial,
        nombreCliente: nombreCliente,
        direccion: direccion,
        referencia: referencia,
        obs: obs,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de crear
      await loadClientes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Actualizar un cliente existente
  Future<void> updateCliente({
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
    try {
      final repository = ref.read(clienteRepositoryProvider);
      await repository.updateCliente(
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

      // Recargar la lista después de actualizar
      await loadClientes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Eliminar un cliente
  Future<void> deleteCliente(int codCliente) async {
    try {
      final repository = ref.read(clienteRepositoryProvider);
      await repository.deleteCliente(codCliente);

      // Recargar la lista después de eliminar
      await loadClientes();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider del notificador de clientes
final clienteProvider = NotifierProvider<ClienteNotifier, AsyncValue<List<ClienteEntity>>>(
  ClienteNotifier.new,
);
