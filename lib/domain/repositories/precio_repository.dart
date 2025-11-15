import '../../core/utils/operation_result.dart';
import '../entities/precio_entity.dart';

/// Repositorio abstracto para operaciones con precios
abstract class PrecioRepository {
  /// Crear un nuevo precio para un artículo
  Future<OperationResult<PrecioEntity>> createPrecio({
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  });

  /// Obtener todos los precios
  Future<List<PrecioEntity>> getPrecios();

  /// Obtener precios de un artículo específico
  Future<List<PrecioEntity>> getPreciosByArticulo(String codArticulo);

  /// Obtener un precio específico por su código
  Future<PrecioEntity> getPrecioById(int codPrecio);

  /// Actualizar un precio existente
  Future<OperationResult<PrecioEntity>> updatePrecio({
    required int codPrecio,
    required String codArticulo,
    required double precioBase,
    required double precio,
    required double precioSinFactura,
    required int audUsuario,
  });

  /// Eliminar un precio
  Future<OperationResult<void>> deletePrecio(int codPrecio);
}
