import 'package:flutter/foundation.dart';
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
      debugPrint('🔐 Verificando autenticación...');
      final repository = ref.read(authRepositoryProvider);
      final isAuth = await repository.isAuthenticated();

      if (isAuth) {
        debugPrint('✅ Usuario autenticado - cargando datos');
        final user = await repository.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        debugPrint('❌ No autenticado o token expirado');
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      debugPrint('❌ Error en verificación de auth: $e');
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
      debugPrint(' Login exitoso: ${user.nombreCompleto}');
      state = AsyncValue.data(user);
      // El menú se recargará automáticamente por el listener en menu_provider
    } catch (e, stack) {
      debugPrint('Error en login: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('🚪 Cerrando sesión...');
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      debugPrint('✅ Sesión cerrada');
      state = const AsyncValue.data(null);
      // El menú se limpiará automáticamente por el listener en menu_provider
    } catch (e, stack) {
      debugPrint('❌ Error en logout: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresca el estado de autenticación
  /// Se llama cuando el token expira o se necesita verificar
  Future<void> refresh() async {
    debugPrint('🔄 Refrescando estado de autenticación...');
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
