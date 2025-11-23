import '../../core/utils/operation_result.dart';
import '../entities/persona_entity.dart';

/// Repositorio de Persona
abstract class PersonaRepository {
  /// Listar todas las personas
  Future<OperationResult<List<PersonaEntity>>> listar();

  /// Buscar persona por código
  Future<OperationResult<PersonaEntity>> buscarPorCodigo(int codPersona);

  /// Buscar persona por CI
  Future<OperationResult<PersonaEntity>> buscarPorCI(
    String ciNumero,
    String ciExpedido,
  );

  /// Buscar personas por nombre
  Future<OperationResult<List<PersonaEntity>>> buscarPorNombre(String nombre);

  /// Crear persona
  Future<OperationResult<PersonaEntity>> crear({
    required String nombres,
    required String apPaterno,
    required String apMaterno,
    required String ciNumero,
    required String ciExpedido,
    DateTime? ciFechaVencimiento,
    required String direccion,
    required String estadoCivil,
    DateTime? fechaNacimiento,
    required String lugarNacimiento,
    required String sexo,
  });

  /// Actualizar persona
  Future<OperationResult<PersonaEntity>> actualizar({
    required int codPersona,
    required String nombres,
    required String apPaterno,
    required String apMaterno,
    required String ciNumero,
    required String ciExpedido,
    DateTime? ciFechaVencimiento,
    required String direccion,
    required String estadoCivil,
    DateTime? fechaNacimiento,
    required String lugarNacimiento,
    required String sexo,
  });

  /// Eliminar persona
  Future<OperationResult<void>> eliminar(int codPersona);
}
