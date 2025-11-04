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
  /// Retorna el mensaje de éxito del backend
  Future<String> createLinea({
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      final result = await repository.createLinea(
        codFamilia: codFamilia,
        linea: linea,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadLineas();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar una línea existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updateLinea({
    required int codLinea,
    required int codFamilia,
    required String linea,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      final result = await repository.updateLinea(
        codLinea: codLinea,
        codFamilia: codFamilia,
        linea: linea,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadLineas();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar una línea
  /// Retorna el mensaje de éxito del backend
  Future<String> deleteLinea(int codLinea) async {
    try {
      final repository = ref.read(lineaRepositoryProvider);
      final result = await repository.deleteLinea(codLinea);
      
      // Recargar la lista después de eliminar
      await loadLineas();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notificador de líneas
final lineaProvider = NotifierProvider<LineaNotifier, AsyncValue<List<LineaEntity>>>(
  LineaNotifier.new,
);
