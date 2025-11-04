import '../../core/utils/operation_result.dart';
import '../entities/linea_entity.dart';

/// Repositorio de Líneas
abstract class LineaRepository {
  /// Crear una nueva línea
  Future<OperationResult<LineaEntity>> createLinea({
    required int codFamilia,
    required String linea,
    required int audUsuario,
  });

  /// Obtener todas las líneas
  Future<List<LineaEntity>> getLineas();

  /// Obtener una línea por código
  Future<LineaEntity> getLineaById(int codLinea);

  /// Actualizar una línea
  Future<OperationResult<LineaEntity>> updateLinea({
    required int codLinea,
    required int codFamilia,
    required String linea,
    required int audUsuario,
  });

  /// Eliminar una línea
  Future<OperationResult<void>> deleteLinea(int codLinea);
}
