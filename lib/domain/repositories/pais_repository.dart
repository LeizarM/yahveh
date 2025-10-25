import '../entities/pais_entity.dart';

/// Repositorio de Países
abstract class PaisRepository {
  /// Crear un nuevo país
  Future<PaisEntity> createPais({
    required String pais,
    required int audUsuario,
  });

  /// Obtener todos los países
  Future<List<PaisEntity>> getPaises();

  /// Obtener un país por código
  Future<PaisEntity> getPaisById(int codPais);

  /// Actualizar un país
  Future<PaisEntity> updatePais({
    required int codPais,
    required String pais,
    required int audUsuario,
  });

  /// Eliminar un país
  Future<void> deletePais(int codPais);
}
