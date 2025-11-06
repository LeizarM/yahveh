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
  /// Retorna el mensaje de éxito del backend
  Future<String> createFamilia({
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      final result = await repository.createFamilia(
        familia: familia,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadFamilias();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar una familia existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      final result = await repository.updateFamilia(
        codFamilia: codFamilia,
        familia: familia,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadFamilias();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar una familia
  /// Retorna el mensaje de éxito del backend
  Future<String> deleteFamilia(int codFamilia) async {
    try {
      final repository = ref.read(familiaRepositoryProvider);
      final result = await repository.deleteFamilia(codFamilia);
      
      // Recargar la lista después de eliminar
      await loadFamilias();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notificador de familias
final familiaProvider = NotifierProvider<FamiliaNotifier, AsyncValue<List<FamiliaEntity>>>(
  FamiliaNotifier.new,
);
