
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'providers.dart';

class AuthNotifier extends Notifier<AsyncValue<UserEntity?>> {
  @override
  AsyncValue<UserEntity?> build() {
    _checkAuth();
    return const AsyncValue.loading();
  }

  Future<void> _checkAuth() async {
    try {
     
      final repository = ref.read(authRepositoryProvider);
      final isAuth = await repository.isAuthenticated();

      if (isAuth) {
        
        final user = await repository.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(
        username: username,
        password: password,
      );
     
      state = AsyncValue.data(user);
      // El menú se recargará automáticamente por el listener en menu_provider
    } catch (e, stack) {
      
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    try {
     
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      
      state = const AsyncValue.data(null);
      // El menú se limpiará automáticamente por el listener en menu_provider
    } catch (e, stack) {
      
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresca el estado de autenticación
  /// Se llama cuando el token expira o se necesita verificar
  Future<void> refresh() async {
    
    await _checkAuth();
  }

  /// Verifica si el usuario está actualmente autenticado
  bool get isAuthenticated => state.hasValue && state.value != null;
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>(
  () {
    return AuthNotifier();
  },
);

// ============================================================================
// PROVIDERS DE PERMISOS DE USUARIO
// ============================================================================

/// Provider que indica si el usuario actual es administrador
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.isAdmin ?? false,
    orElse: () => false,
  );
});

/// Provider que indica si el usuario puede escribir (crear, editar, eliminar)
final canWriteProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.canWrite ?? false,
    orElse: () => false,
  );
});

/// Provider que indica si el usuario puede gestionar inventario
final canManageInventoryProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.canManageInventory ?? false,
    orElse: () => false,
  );
});

/// Provider que indica si el usuario puede gestionar precios
final canManagePricesProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.canManagePrices ?? false,
    orElse: () => false,
  );
});

/// Provider que devuelve el tipo de usuario actual
final userTypeProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (user) => user?.tipoUsuario,
    orElse: () => null,
  );
});
