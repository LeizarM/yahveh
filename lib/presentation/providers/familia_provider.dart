import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/familia_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de familias
class FamiliaNotifier extends Notifier<AsyncValue<List<FamiliaEntity>>> {
  @override
  AsyncValue<List<FamiliaEntity>> build() {
    loadFamilias();
    return const AsyncValue.loading();
  }

  /// Cargar todas las familias
  Future<void> loadFamilias() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(familiaRepositoryProvider);
      final familias = await repository.getAllFamilias();
      state = AsyncValue.data(familias);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear una nueva familia
  Future<void> createFamilia({
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      await repository.createFamilia(
        familia: familia,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadFamilias();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Actualizar una familia existente
  Future<void> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      await repository.updateFamilia(
        codFamilia: codFamilia,
        familia: familia,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadFamilias();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Eliminar una familia
  Future<void> deleteFamilia(int codFamilia) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      await repository.deleteFamilia(codFamilia);
      
      // Recargar la lista después de eliminar
      await loadFamilias();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider del notificador de familias
final familiaProvider = NotifierProvider<FamiliaNotifier, AsyncValue<List<FamiliaEntity>>>(
  FamiliaNotifier.new,
);
