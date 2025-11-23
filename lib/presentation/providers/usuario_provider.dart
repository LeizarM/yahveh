import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../core/error/api_exception.dart';
import 'providers.dart';

/// Notifier del proveedor de usuarios
class UsuarioNotifier extends Notifier<AsyncValue<List<UsuarioEntity>>> {
  @override
  AsyncValue<List<UsuarioEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar todos los usuarios
  Future<void> cargarUsuarios() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(usuarioRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar usuarios', st);
    }
  }

  /// Buscar usuario por código
  Future<UsuarioEntity?> buscarPorCodigo(int codUsuario) async {
    try {
      final repository = ref.read(usuarioRepositoryProvider);
      final result = await repository.buscarPorCodigo(codUsuario);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar usuario', statusCode: 500);
    }
  }

  /// Crear nuevo usuario
  Future<int?> crear({
    required int codEmpleado,
    required String login,
    required String password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      final repository = ref.read(usuarioRepositoryProvider);
      final result = await repository.crear(
        codEmpleado: codEmpleado,
        login: login,
        password: password,
        tipoUsuario: tipoUsuario,
        estado: estado,
      );

      // Recargar lista de usuarios
      await cargarUsuarios();

      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al crear usuario', statusCode: 500);
    }
  }

  /// Actualizar usuario existente
  Future<void> actualizar({
    required int codUsuario,
    required int codEmpleado,
    required String login,
    String? password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      final repository = ref.read(usuarioRepositoryProvider);
      await repository.actualizar(
        codUsuario: codUsuario,
        codEmpleado: codEmpleado,
        login: login,
        password: password,
        tipoUsuario: tipoUsuario,
        estado: estado,
      );

      // Recargar lista de usuarios
      await cargarUsuarios();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al actualizar usuario', statusCode: 500);
    }
  }

  /// Eliminar usuario
  Future<void> eliminar(int codUsuario) async {
    try {
      final repository = ref.read(usuarioRepositoryProvider);
      await repository.eliminar(codUsuario);

      // Recargar lista de usuarios
      await cargarUsuarios();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al eliminar usuario', statusCode: 500);
    }
  }
}
