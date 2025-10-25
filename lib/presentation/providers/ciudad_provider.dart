import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ciudad_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de ciudades
class CiudadNotifier extends Notifier<AsyncValue<List<CiudadEntity>>> {
  @override
  AsyncValue<List<CiudadEntity>> build() {
    loadCiudades();
    return const AsyncValue.loading();
  }

  /// Cargar todas las ciudades
  Future<void> loadCiudades() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(ciudadRepositoryProvider);
      final ciudades = await repository.getCiudades();
      state = AsyncValue.data(ciudades);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear una nueva ciudad
  Future<void> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      await repository.createCiudad(
        codPais: codPais,
        ciudad: ciudad,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de crear
      await loadCiudades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Actualizar una ciudad existente
  Future<void> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      await repository.updateCiudad(
        codCiudad: codCiudad,
        codPais: codPais,
        ciudad: ciudad,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de actualizar
      await loadCiudades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Eliminar una ciudad
  Future<void> deleteCiudad(int codCiudad) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      await repository.deleteCiudad(codCiudad);

      // Recargar la lista después de eliminar
      await loadCiudades();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider del notificador de ciudades
final ciudadProvider = NotifierProvider<CiudadNotifier, AsyncValue<List<CiudadEntity>>>(
  CiudadNotifier.new,
);
