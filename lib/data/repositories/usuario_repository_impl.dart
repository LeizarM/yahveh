import '../../core/utils/operation_result.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../datasources/usuario_remote_datasource.dart';

class UsuarioRepositoryImpl implements UsuarioRepository {
  final UsuarioRemoteDataSource _remoteDataSource;

  UsuarioRepositoryImpl({
    required UsuarioRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<OperationResult<List<UsuarioEntity>>> listar() async {
    try {
      final usuarios = await _remoteDataSource.listar();
      return OperationResult(
        data: usuarios.map((model) => model.toEntity()).toList(),
        message: 'Usuarios obtenidos exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<UsuarioEntity>> buscarPorCodigo(int codUsuario) async {
    try {
      final usuario = await _remoteDataSource.buscarPorCodigo(codUsuario);
      return OperationResult(
        data: usuario.toEntity(),
        message: 'Usuario encontrado',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<int>> crear({
    required int codEmpleado,
    required String login,
    required String password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      final nuevoId = await _remoteDataSource.crear(
        codEmpleado: codEmpleado,
        login: login,
        password: password,
        tipoUsuario: tipoUsuario,
        estado: estado,
      );
      return OperationResult(
        data: nuevoId,
        message: 'Usuario creado exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<void>> actualizar({
    required int codUsuario,
    required int codEmpleado,
    required String login,
    String? password,
    required String tipoUsuario,
    required String estado,
  }) async {
    try {
      await _remoteDataSource.actualizar(
        codUsuario: codUsuario,
        codEmpleado: codEmpleado,
        login: login,
        password: password,
        tipoUsuario: tipoUsuario,
        estado: estado,
      );
      return OperationResult(
        data: null,
        message: 'Usuario actualizado exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<OperationResult<void>> eliminar(int codUsuario) async {
    try {
      await _remoteDataSource.eliminar(codUsuario);
      return OperationResult(
        data: null,
        message: 'Usuario eliminado exitosamente',
      );
    } catch (e) {
      throw e;
    }
  }
}
