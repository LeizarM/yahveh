import '../../core/utils/operation_result.dart';
import '../../domain/entities/persona_entity.dart';
import '../../domain/repositories/persona_repository.dart';
import '../datasources/persona_remote_datasource.dart';
import '../models/persona_model.dart';

/// Implementación del repositorio de Persona
class PersonaRepositoryImpl implements PersonaRepository {
  final PersonaRemoteDataSource remoteDataSource;

  PersonaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OperationResult<List<PersonaEntity>>> listar() async {
    final models = await remoteDataSource.listar();
    final entities = models.map((m) => m.toEntity()).toList();
    return OperationResult(data: entities, message: 'Personas obtenidas');
  }

  @override
  Future<OperationResult<PersonaEntity>> buscarPorCodigo(int codPersona) async {
    final model = await remoteDataSource.buscarPorCodigo(codPersona);
    return OperationResult(data: model.toEntity(), message: 'Persona encontrada');
  }

  @override
  Future<OperationResult<PersonaEntity>> buscarPorCI(
    String ciNumero,
    String ciExpedido,
  ) async {
    final model = await remoteDataSource.buscarPorCI(ciNumero, ciExpedido);
    return OperationResult(data: model.toEntity(), message: 'Persona encontrada');
  }

  @override
  Future<OperationResult<List<PersonaEntity>>> buscarPorNombre(String nombre) async {
    final models = await remoteDataSource.buscarPorNombre(nombre);
    final entities = models.map((m) => m.toEntity()).toList();
    return OperationResult(data: entities, message: 'Personas encontradas');
  }

  @override
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
  }) async {
    final model = PersonaModel(
      codPersona: 0,
      nombres: nombres,
      apPaterno: apPaterno,
      apMaterno: apMaterno,
      ciNumero: ciNumero,
      ciExpedido: ciExpedido,
      ciFechaVencimiento: ciFechaVencimiento,
      direccion: direccion,
      estadoCivil: estadoCivil,
      fechaNacimiento: fechaNacimiento,
      lugarNacimiento: lugarNacimiento,
      sexo: sexo,
      audUsuario: 0,
    );

    final createdModel = await remoteDataSource.crear(model);
    return OperationResult(data: createdModel.toEntity(), message: 'Persona creada');
  }

  @override
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
  }) async {
    final model = PersonaModel(
      codPersona: codPersona,
      nombres: nombres,
      apPaterno: apPaterno,
      apMaterno: apMaterno,
      ciNumero: ciNumero,
      ciExpedido: ciExpedido,
      ciFechaVencimiento: ciFechaVencimiento,
      direccion: direccion,
      estadoCivil: estadoCivil,
      fechaNacimiento: fechaNacimiento,
      lugarNacimiento: lugarNacimiento,
      sexo: sexo,
      audUsuario: 0,
    );

    final updatedModel = await remoteDataSource.actualizar(codPersona, model);
    return OperationResult(data: updatedModel.toEntity(), message: 'Persona actualizada');
  }

  @override
  Future<OperationResult<void>> eliminar(int codPersona) async {
    await remoteDataSource.eliminar(codPersona);
    return const OperationResult(data: null, message: 'Persona eliminada');
  }
}
