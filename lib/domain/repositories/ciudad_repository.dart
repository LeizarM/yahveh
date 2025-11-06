import '../../core/utils/operation_result.dart';
import '../entities/ciudad_entity.dart';

/// Repositorio de Ciudades
abstract class CiudadRepository {
  /// Crear una nueva ciudad
  Future<OperationResult<CiudadEntity>> createCiudad({
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  /// Obtener todas las ciudades
  Future<List<CiudadEntity>> getCiudades();

  /// Obtener una ciudad por código
  Future<CiudadEntity> getCiudadById(int codCiudad);

  /// Actualizar una ciudad
  Future<OperationResult<CiudadEntity>> updateCiudad({
    required int codCiudad,
    required int codPais,
    required String ciudad,
    required int audUsuario,
  });

  /// Eliminar una ciudad
  Future<OperationResult<void>> deleteCiudad(int codCiudad);
}
