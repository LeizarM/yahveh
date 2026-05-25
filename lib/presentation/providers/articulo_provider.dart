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

/// ============================================================
/// PAGED PROVIDER — server-side pagination
/// ============================================================

/// Estado de la pantalla de artículos paginados.
class ArticulosPagedState {
  final ArticuloPage page;
  final int currentPage;
  final int pageSize;
  final String search;
  final bool isLoading;
  final Object? error;

  const ArticulosPagedState({
    required this.page,
    required this.currentPage,
    required this.pageSize,
    required this.search,
    required this.isLoading,
    this.error,
  });

  factory ArticulosPagedState.initial({int pageSize = 20}) => ArticulosPagedState(
        page: ArticuloPage(
          data: const [],
          total: 0,
          page: 1,
          pageSize: pageSize,
          totalPages: 0,
        ),
        currentPage: 1,
        pageSize: pageSize,
        search: '',
        isLoading: true,
      );

  ArticulosPagedState copyWith({
    ArticuloPage? page,
    int? currentPage,
    int? pageSize,
    String? search,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ArticulosPagedState(
      page: page ?? this.page,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier para artículos paginados server-side.
/// La paginación se hace en BD vía stored procedure (p_list_articulo).
class ArticulosPagedNotifier extends Notifier<ArticulosPagedState> {
  @override
  ArticulosPagedState build() {
    // Cargar primera página al montar
    Future.microtask(() => load(page: 1));
    return ArticulosPagedState.initial();
  }

  /// Cargar una página específica.
  /// Si [search] es null, mantiene el search actual.
  Future<void> load({int? page, int? pageSize, String? search}) async {
    final newPage = page ?? state.currentPage;
    final newSize = pageSize ?? state.pageSize;
    final newSearch = search ?? state.search;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final repo = ref.read(articuloRepositoryProvider);
      final result = await repo.getArticulosPaginados(
        page: newPage,
        pageSize: newSize,
        search: newSearch.isEmpty ? null : newSearch,
      );
      // ⭐ Preferimos el pageSize que pedimos (newSize) sobre el que
      // devuelve el backend, para mantener consistencia con la UI.
      // Si el backend devuelve algo distinto y lo aceptáramos, el
      // DropdownButton del selector podría romperse si no está en su lista.
      state = state.copyWith(
        page: result,
        currentPage: result.page,
        pageSize: newSize,
        search: newSearch,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Avanzar a la siguiente página (si existe).
  Future<void> nextPage() async {
    if (state.page.hasNext) {
      await load(page: state.currentPage + 1);
    }
  }

  /// Retroceder a la página anterior (si existe).
  Future<void> prevPage() async {
    if (state.page.hasPrev) {
      await load(page: state.currentPage - 1);
    }
  }

  /// Ir a la primera página.
  Future<void> firstPage() async {
    if (state.currentPage != 1) await load(page: 1);
  }

  /// Ir a la última página.
  Future<void> lastPage() async {
    final last = state.page.totalPages;
    if (last > 0 && state.currentPage != last) await load(page: last);
  }

  /// Cambiar el tamaño de página y volver a página 1.
  Future<void> setPageSize(int size) async {
    await load(page: 1, pageSize: size);
  }

  /// Cambiar el texto de búsqueda y resetear a página 1.
  Future<void> setSearch(String value) async {
    await load(page: 1, search: value);
  }

  /// Recargar la página actual.
  Future<void> refresh() => load();
}

/// Provider de la lista paginada de artículos.
final articulosPagedProvider =
    NotifierProvider<ArticulosPagedNotifier, ArticulosPagedState>(
  ArticulosPagedNotifier.new,
);
