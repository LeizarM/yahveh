import '../entities/zona_entity.dart';
import '../../core/utils/operation_result.dart';

/// Repositorio de Zonas
abstract class ZonaRepository {
  /// Crear una nueva zona
  Future<OperationResult<ZonaEntity>> createZona({
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  /// Obtener todas las zonas
  Future<List<ZonaEntity>> getZonas();

  /// Obtener una zona por código
  Future<ZonaEntity> getZonaById(int codZona);

  /// Actualizar una zona
  Future<OperationResult<ZonaEntity>> updateZona({
    required int codZona,
    required int codCiudad,
    required String zona,
    required int audUsuario,
  });

  /// Eliminar una zona
  Future<OperationResult<void>> deleteZona(int codZona);
}
