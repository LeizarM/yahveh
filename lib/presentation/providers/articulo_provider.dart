import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/articulo_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de artículos
class ArticuloNotifier extends Notifier<AsyncValue<List<ArticuloEntity>>> {
  @override
  AsyncValue<List<ArticuloEntity>> build() {
    loadArticulos();
    return const AsyncValue.loading();
  }

  /// Cargar todos los artículos
  Future<void> loadArticulos() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(articuloRepositoryProvider);
      final articulos = await repository.getArticulos();
      state = AsyncValue.data(articulos);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crear un nuevo artículo
  /// Retorna el mensaje de éxito del backend
  Future<String> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      final result = await repository.createArticulo(
        codArticulo: codArticulo,
        codLinea: codLinea,
        descripcion: descripcion,
        descripcion2: descripcion2,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadArticulos();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar un artículo existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      final result = await repository.updateArticulo(
        codArticulo: codArticulo,
        codLinea: codLinea,
        descripcion: descripcion,
        descripcion2: descripcion2,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadArticulos();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar un artículo
  /// Retorna el mensaje de éxito del backend
  Future<String> deleteArticulo(String codArticulo) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      final result = await repository.deleteArticulo(codArticulo);
      
      // Recargar la lista después de eliminar
      await loadArticulos();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notificador de artículos
final articuloProvider = NotifierProvider<ArticuloNotifier, AsyncValue<List<ArticuloEntity>>>(
  ArticuloNotifier.new,
);
