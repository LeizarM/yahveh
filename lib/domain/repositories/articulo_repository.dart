import '../../core/utils/operation_result.dart';
import '../entities/articulo_entity.dart';

/// Repositorio abstracto para operaciones con artículos
abstract class ArticuloRepository {
  /// Crear un nuevo artículo
  Future<OperationResult<ArticuloEntity>> createArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  /// Obtener todos los artículos
  Future<List<ArticuloEntity>> getArticulos();

  /// Obtener un artículo por su código
  Future<ArticuloEntity> getArticuloById(String codArticulo);

  /// Actualizar un artículo existente
  Future<OperationResult<ArticuloEntity>> updateArticulo({
    required String codArticulo,
    required int codLinea,
    required String descripcion,
    required String descripcion2,
    required int audUsuario,
  });

  /// Eliminar un artículo
  Future<OperationResult<void>> deleteArticulo(String codArticulo);
}
