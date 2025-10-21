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
  Future<void> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      await repository.createArticulo(
        codArticulo: codArticulo,
        codLinea: codLinea,
        descripcion: descripcion,
        descripcion2: descripcion2,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadArticulos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Actualizar un artículo existente
  Future<void> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      await repository.updateArticulo(
        codArticulo: codArticulo,
        codLinea: codLinea,
        descripcion: descripcion,
        descripcion2: descripcion2,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadArticulos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Eliminar un artículo
  Future<void> deleteArticulo(String codArticulo) async {
    try {
      final repository = ref.read(articuloRepositoryProvider);
      await repository.deleteArticulo(codArticulo);
      
      // Recargar la lista después de eliminar
      await loadArticulos();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

/// Provider del notificador de artículos
final articuloProvider = NotifierProvider<ArticuloNotifier, AsyncValue<List<ArticuloEntity>>>(
  ArticuloNotifier.new,
);
