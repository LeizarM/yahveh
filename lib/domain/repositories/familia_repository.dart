import '../entities/familia_entity.dart';

/// Repositorio abstracto para Familias
abstract class FamiliaRepository {
  Future<FamiliaEntity> createFamilia({
    required String familia,
    required int audUsuario,
  });

  Future<List<FamiliaEntity>> getAllFamilias();

  Future<FamiliaEntity> getFamiliaById(int codFamilia);

  Future<FamiliaEntity> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  });

  Future<void> deleteFamilia(int codFamilia);
}
