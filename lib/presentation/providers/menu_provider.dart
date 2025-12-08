import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vista_entity.dart';
import '../../domain/repositories/vista_repository.dart';
import 'auth_provider.dart';
import 'providers.dart';

/// Provider para el estado del menú
final menuProvider =
    NotifierProvider<MenuNotifier, AsyncValue<List<VistaEntity>>>(() {
      return MenuNotifier();
    });

/// Notifier para manejar el estado del menú
/// Escucha cambios en authProvider para recargar el menú cuando cambia el usuario
class MenuNotifier extends Notifier<AsyncValue<List<VistaEntity>>> {
  late final VistaRepository _repository;

  @override
  AsyncValue<List<VistaEntity>> build() {
    _repository = ref.watch(vistaRepositoryProvider);

    // Escuchar cambios en el estado de autenticación
    // Cuando el usuario cambia (login/logout), recargamos el menú
    ref.listen(authProvider, (previous, next) {
      final previousUser = previous?.hasValue == true ? previous?.value : null;
      final currentUser = next.hasValue ? next.value : null;

      // Si cambió el usuario (diferente ID o de null a usuario o viceversa)
      final userChanged = previousUser?.codUsuario != currentUser?.codUsuario;

      if (userChanged) {
        debugPrint(
          '🔄 Usuario cambió: ${previousUser?.nombreCompleto ?? 'null'} → ${currentUser?.nombreCompleto ?? 'null'}',
        );

        if (currentUser != null) {
          // Nuevo usuario logueado - cargar su menú
          debugPrint('📋 Recargando menú para nuevo usuario...');
          loadMenu();
        } else {
          // Usuario cerró sesión - limpiar menú
          debugPrint('🧹 Limpiando menú (logout)');
          state = const AsyncValue.data([]);
        }
      }
    });

    // Verificar si hay un usuario autenticado para cargar el menú inicial
    final authState = ref.read(authProvider);
    if (authState.hasValue && authState.value != null) {
      loadMenu();
    }

    return const AsyncValue.loading();
  }

  /// Carga el menú desde el backend
  Future<void> loadMenu() async {
    state = const AsyncValue.loading();
    try {
      debugPrint('📋 Cargando menú desde el backend...');
      final menu = await _repository.getMenu();
      debugPrint('✅ Menú cargado: ${menu.length} elementos');
      state = AsyncValue.data(menu);
    } catch (e, stackTrace) {
      debugPrint('❌ Error cargando menú: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Recarga el menú
  Future<void> refreshMenu() async {
    await loadMenu();
  }

  /// Limpia el menú (útil para logout)
  void clearMenu() {
    state = const AsyncValue.data([]);
  }
}
