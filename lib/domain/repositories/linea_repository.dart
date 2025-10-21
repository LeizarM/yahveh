import '../entities/linea_entity.dart';

/// Repositorio de Líneas
abstract class LineaRepository {
  /// Crear una nueva línea
  Future<LineaEntity> createLinea({
    required String linea,
    required int audUsuario,
  });

  /// Obtener todas las líneas
  Future<List<LineaEntity>> getLineas();

  /// Obtener una línea por código
  Future<LineaEntity> getLineaById(int codLinea);

  /// Actualizar una línea
  Future<LineaEntity> updateLinea({
    required int codLinea,
    required String linea,
    required int audUsuario,
  });

  /// Eliminar una línea
  Future<void> deleteLinea(int codLinea);
}
