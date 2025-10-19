import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vista_entity.dart';
import '../../domain/repositories/vista_repository.dart';
import 'providers.dart';

/// Provider para el estado del menú
final menuProvider = NotifierProvider<MenuNotifier, AsyncValue<List<VistaEntity>>>(() {
  return MenuNotifier();
});

/// Notifier para manejar el estado del menú
class MenuNotifier extends Notifier<AsyncValue<List<VistaEntity>>> {
  late final VistaRepository _repository;

  @override
  AsyncValue<List<VistaEntity>> build() {
    _repository = ref.watch(vistaRepositoryProvider);
    loadMenu();
    return const AsyncValue.loading();
  }

  /// Carga el menú desde el backend
  Future<void> loadMenu() async {
    state = const AsyncValue.loading();
    try {
      final menu = await _repository.getMenu();
      state = AsyncValue.data(menu);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Recarga el menú
  Future<void> refreshMenu() async {
    await loadMenu();
  }
}
