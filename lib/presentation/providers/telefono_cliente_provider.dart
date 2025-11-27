import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/telefono_cliente_entity.dart';
import '../../core/error/api_exception.dart';
import 'providers.dart';

/// Notifier del proveedor de teléfonos de cliente
class TelefonoClienteNotifier extends Notifier<AsyncValue<List<TelefonoClienteEntity>>> {
  @override
  AsyncValue<List<TelefonoClienteEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar todos los teléfonos
  Future<void> cargarTelefonos() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar teléfonos', st);
    }
  }

  /// Cargar teléfonos por cliente
  Future<List<TelefonoClienteEntity>> cargarPorCliente(int codCliente) async {
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      final result = await repository.listarPorCliente(codCliente);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al cargar teléfonos del cliente',
        statusCode: 500,
      );
    }
  }

  /// Buscar teléfono por código
  Future<TelefonoClienteEntity?> buscarPorCodigo(int codTlfCliente) async {
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      final result = await repository.buscarPorCodigo(codTlfCliente);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al buscar teléfono',
        statusCode: 500,
      );
    }
  }

  /// Crear nuevo teléfono
  Future<TelefonoClienteEntity?> crear({
    required int codCliente,
    required String telefono,
  }) async {
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      final result = await repository.crear(
        codCliente: codCliente,
        telefono: telefono,
      );
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al crear teléfono',
        statusCode: 500,
      );
    }
  }

  /// Crear múltiples teléfonos a la vez
  Future<List<TelefonoClienteEntity>> crearMultiples({
    required int codCliente,
    required List<String> telefonos,
  }) async {
    final List<TelefonoClienteEntity> creados = [];
    final List<String> errores = [];

    for (final telefono in telefonos) {
      if (telefono.trim().isEmpty) continue;
      
      try {
        final result = await crear(
          codCliente: codCliente,
          telefono: telefono.trim(),
        );
        if (result != null) {
          creados.add(result);
        }
      } on ApiException catch (e) {
        errores.add('$telefono: ${e.message}');
      } catch (e) {
        errores.add('$telefono: Error inesperado');
      }
    }

    if (errores.isNotEmpty && creados.isEmpty) {
      throw ApiException(
        message: 'Error al crear teléfonos:\n${errores.join('\n')}',
        statusCode: 500,
      );
    }

    return creados;
  }

  /// Actualizar teléfono existente
  Future<void> actualizar({
    required int codTlfCliente,
    required int codCliente,
    required String telefono,
  }) async {
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      await repository.actualizar(
        codTlfCliente: codTlfCliente,
        codCliente: codCliente,
        telefono: telefono,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al actualizar teléfono',
        statusCode: 500,
      );
    }
  }

  /// Eliminar teléfono
  Future<void> eliminar(int codTlfCliente) async {
    try {
      final repository = ref.read(telefonoClienteRepositoryProvider);
      await repository.eliminar(codTlfCliente);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Error inesperado al eliminar teléfono',
        statusCode: 500,
      );
    }
  }
}
