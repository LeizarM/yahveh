import '../../core/utils/operation_result.dart';
import '../entities/usuario_entity.dart';

abstract class UsuarioRepository {
  /// Listar todos los usuarios
  Future<OperationResult<List<UsuarioEntity>>> listar();

  /// Buscar usuario por código
  Future<OperationResult<UsuarioEntity>> buscarPorCodigo(int codUsuario);

  /// Crear un nuevo usuario
  Future<OperationResult<int>> crear({
    required int codEmpleado,
    required String login,
    required String password,
    required String tipoUsuario,
    required String estado,
  });

  /// Actualizar un usuario existente
  Future<OperationResult<void>> actualizar({
    required int codUsuario,
    required int codEmpleado,
    required String login,
    String? password,
    required String tipoUsuario,
    required String estado,
  });

  /// Eliminar un usuario
  Future<OperationResult<void>> eliminar(int codUsuario);
}
