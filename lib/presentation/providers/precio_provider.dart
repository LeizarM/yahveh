import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/precio_entity.dart';
import 'providers.dart';

/// Notifier para gestionar el estado de precios
class PrecioNotifier extends Notifier<AsyncValue<List<PrecioEntity>>> {
  @override
  AsyncValue<List<PrecioEntity>> build() {
    loadPrecios();
    return const AsyncValue.loading();
  }

  /// Cargar todos los precios
  Future<void> loadPrecios() async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(precioRepositoryProvider);
      final precios = await repository.getPrecios();
      state = AsyncValue.data(precios);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cargar precios de un artículo específico
  Future<List<PrecioEntity>> loadPreciosByArticulo(String codArticulo) async {
    try {
      final repository = ref.read(precioRepositoryProvider);
      return await repository.getPreciosByArticulo(codArticulo);
    } catch (e) {
      rethrow;
    }
  }

  /// Crear un nuevo precio
  /// Retorna el mensaje de éxito del backend
  Future<String> createPrecio({
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(precioRepositoryProvider);
      final result = await repository.createPrecio(
        codArticulo: codArticulo,
        precioBase: precioBase,
        precio: precio,
        precioSinFactura: precioSinFactura,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de crear
      await loadPrecios();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Actualizar un precio existente
  /// Retorna el mensaje de éxito del backend
  Future<String> updatePrecio({
    required int codPrecio,
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  }) async {
    try {
      final repository = ref.read(precioRepositoryProvider);
      final result = await repository.updatePrecio(
        codPrecio: codPrecio,
        codArticulo: codArticulo,
        precioBase: precioBase,
        precio: precio,
        precioSinFactura: precioSinFactura,
        audUsuario: audUsuario,
      );
      
      // Recargar la lista después de actualizar
      await loadPrecios();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }

  /// Eliminar un precio
  /// Retorna el mensaje de éxito del backend
  Future<String> deletePrecio(int codPrecio) async {
    try {
      final repository = ref.read(precioRepositoryProvider);
      final result = await repository.deletePrecio(codPrecio);
      
      // Recargar la lista después de eliminar
      await loadPrecios();
      
      return result.message;
    } catch (e) {
      // NO cambiar el estado de la lista cuando falla una operación individual
      // Solo relanzar el error para que lo maneje la UI
      rethrow;
    }
  }
}

/// Provider del notifier de precios
final precioProvider = NotifierProvider<PrecioNotifier, AsyncValue<List<PrecioEntity>>>(() {
  return PrecioNotifier();
});
