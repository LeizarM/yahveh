import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/linea_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de líneas
class LineaNotifier extends Notifier<AsyncValue<List<LineaEntity>>> {
  @override
  AsyncValue<List<LineaEntity>> build() {
    loadLineas();
    return const AsyncValue.loading();
  }

  /// Cargar todas las líneas
  Future<void> loadLineas() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(lineaRepositoryProvider);
      final lineas = await repository.getLineas();
      state = AsyncValue.data(lineas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear una nueva línea
  Future<void> createLinea({
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      await repository.createLinea(
        linea: linea,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadLineas();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Actualizar una línea existente
  Future<void> updateLinea({
    required int codLinea,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      await repository.updateLinea(
        codLinea: codLinea,
        linea: linea,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadLineas();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Eliminar una línea
  Future<void> deleteLinea(int codLinea) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      await repository.deleteLinea(codLinea);
      
      // Recargar la lista después de eliminar
      await loadLineas();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider del notificador de líneas
final lineaProvider = NotifierProvider<LineaNotifier, AsyncValue<List<LineaEntity>>>(
  LineaNotifier.new,
);
