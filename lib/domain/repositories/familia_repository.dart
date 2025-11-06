import '../../core/utils/operation_result.dart';
import '../entities/familia_entity.dart';

/// Repositorio abstracto para Familias
abstract class FamiliaRepository {
  Future<OperationResult<FamiliaEntity>> createFamilia({
    required String familia,
    required int audUsuario,
  });

  Future<List<FamiliaEntity>> getAllFamilias();

  Future<FamiliaEntity> getFamiliaById(int codFamilia);

  Future<OperationResult<FamiliaEntity>> updateFamilia({
    required int codFamilia,
    required String familia,
    required int audUsuario,
  });

  Future<OperationResult<void>> deleteFamilia(int codFamilia);
}
