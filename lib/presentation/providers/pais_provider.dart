import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pais_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de países
class PaisNotifier extends Notifier<AsyncValue<List<PaisEntity>>> {
  @override
  AsyncValue<List<PaisEntity>> build() {
    loadPaises();
    return const AsyncValue.loading();
  }

  /// Cargar todos los países
  Future<void> loadPaises() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(paisRepositoryProvider);
      final paises = await repository.getPaises();
      state = AsyncValue.data(paises);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear un nuevo país
  /// Retorna el mensaje de éxito del backend
  Future<String> createPais({
    required String pais,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(paisRepositoryProvider);
      final result = await repository.createPais(
        pais: pais,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de crear
      await loadPaises();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar un país existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(paisRepositoryProvider);
      final result = await repository.updatePais(
        codPais: codPais,
        pais: pais,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de actualizar
      await loadPaises();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar un país
  /// Retorna el mensaje de éxito del backend
  Future<String> deletePais(int codPais) async {
    try {
      final repository = ref.read(paisRepositoryProvider);
      final result = await repository.deletePais(codPais);

      // Recargar la lista después de eliminar
      await loadPaises();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notificador de países
final paisProvider = NotifierProvider<PaisNotifier, AsyncValue<List<PaisEntity>>>(
  PaisNotifier.new,
);
