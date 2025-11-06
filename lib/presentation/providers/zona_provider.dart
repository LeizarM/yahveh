import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/zona_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de zonas
class ZonaNotifier extends Notifier<AsyncValue<List<ZonaEntity>>> {
  @override
  AsyncValue<List<ZonaEntity>> build() {
    loadZonas();
    return const AsyncValue.loading();
  }

  /// Cargar todas las zonas
  Future<void> loadZonas() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(zonaRepositoryProvider);
      final zonas = await repository.getZonas();
      state = AsyncValue.data(zonas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear una nueva zona
  Future<String> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(zonaRepositoryProvider);
      final result = await repository.createZona(
        codCiudad: codCiudad,
        zona: zona,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de crear
      await loadZonas();
      
      return result.message;
    } catch (e) {
      await loadZonas();
      rethrow;
    }
  }

  /// Actualizar una zona existente
  Future<String> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(zonaRepositoryProvider);
      final result = await repository.updateZona(
        codZona: codZona,
        codCiudad: codCiudad,
        zona: zona,
        audUsuario: audUsuario,
      );

      // Recargar la lista después de actualizar
      await loadZonas();
      
      return result.message;
    } catch (e) {
      await loadZonas();
      rethrow;
    }
  }

  /// Eliminar una zona
  Future<String> deleteZona(int codZona) async {
    try {
      final repository = ref.read(zonaRepositoryProvider);
      final result = await repository.deleteZona(codZona);

      // Recargar la lista después de eliminar
      await loadZonas();
      
      return result.message;
    } catch (e) {
      await loadZonas();
      rethrow;
    }
  }
}

/// Provider del notificador de zonas
final zonaProvider = NotifierProvider<ZonaNotifier, AsyncValue<List<ZonaEntity>>>(
  ZonaNotifier.new,
);
