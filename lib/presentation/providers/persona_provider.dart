import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/persona_entity.dart';
import '../../core/error/api_exception.dart';
import 'providers.dart';

/// Notifier del proveedor de personas
class PersonaNotifier extends Notifier<AsyncValue<List<PersonaEntity>>> {
  @override
  AsyncValue<List<PersonaEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar todas las personas
  Future<void> cargarPersonas() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(personaRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar personas', st);
    }
  }

  /// Buscar persona por código
  Future<PersonaEntity?> buscarPorCodigo(int codPersona) async {
    try {
      final repository = ref.read(personaRepositoryProvider);
      final result = await repository.buscarPorCodigo(codPersona);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar persona', statusCode: 500);
    }
  }

  /// Buscar persona por CI
  Future<PersonaEntity?> buscarPorCI(String ciNumero, String ciExpedido) async {
    try {
      final repository = ref.read(personaRepositoryProvider);
      final result = await repository.buscarPorCI(ciNumero, ciExpedido);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar persona por CI', statusCode: 500);
    }
  }

  /// Buscar personas por nombre
  Future<List<PersonaEntity>> buscarPorNombre(String nombre) async {
    try {
      final repository = ref.read(personaRepositoryProvider);
      final result = await repository.buscarPorNombre(nombre);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al buscar personas', statusCode: 500);
    }
  }

  /// Crear nueva persona
  Future<PersonaEntity?> crear({
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
    try {
      final repository = ref.read(personaRepositoryProvider);
      final result = await repository.crear(
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
      );

      // Recargar lista de personas
      await cargarPersonas();

      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al crear persona', statusCode: 500);
    }
  }

  /// Actualizar persona existente
  Future<void> actualizar({
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
    try {
      final repository = ref.read(personaRepositoryProvider);
      await repository.actualizar(
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
      );

      // Recargar lista de personas
      await cargarPersonas();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al actualizar persona', statusCode: 500);
    }
  }

  /// Eliminar persona
  Future<void> eliminar(int codPersona) async {
    try {
      final repository = ref.read(personaRepositoryProvider);
      await repository.eliminar(codPersona);

      // Recargar lista de personas
      await cargarPersonas();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          message: 'Error inesperado al eliminar persona', statusCode: 500);
    }
  }
}
