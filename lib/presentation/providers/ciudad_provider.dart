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
  /// Retorna el mensaje de éxito del backend
  Future<String> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      final result = await repository.createCiudad(
        codPais: codPais,
        ciudad: ciudad,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de crear
      await loadCiudades();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar una ciudad existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      final result = await repository.updateCiudad(
        codCiudad: codCiudad,
        codPais: codPais,
        ciudad: ciudad,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de actualizar
      await loadCiudades();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar una ciudad
  /// Retorna el mensaje de éxito del backend
  Future<String> deleteCiudad(int codCiudad) async {
    try {
      final repository = ref.read(ciudadRepositoryProvider);
      final result = await repository.deleteCiudad(codCiudad);

      // Recargar la lista después de eliminar
      await loadCiudades();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notificador de ciudades
final ciudadProvider = NotifierProvider<CiudadNotifier, AsyncValue<List<CiudadEntity>>>(
  CiudadNotifier.new,
);
