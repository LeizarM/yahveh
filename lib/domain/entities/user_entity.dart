/// Entidad de Usuario
class UserEntity {
  final int codUsuario;
  final String nombreCompleto;
  final String tipoUsuario;
  final String token;

  const UserEntity({
    required this.codUsuario,
    required this.nombreCompleto,
    required this.tipoUsuario,
    required this.token,
  });

  /// Verifica si el usuario es administrador
  bool get isAdmin => tipoUsuario.toLowerCase() == 'admin';

  /// Verifica si el usuario tiene permisos limitados
  bool get isLimited => tipoUsuario.toLowerCase() == 'lim';

  /// Verifica si el usuario puede realizar operaciones de escritura (crear, editar, eliminar)
  bool get canWrite => isAdmin;

  /// Verifica si el usuario puede gestionar inventario (entradas/salidas)
  bool get canManageInventory => isAdmin;

  /// Verifica si el usuario puede gestionar precios
  bool get canManagePrices => isAdmin;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.codUsuario == codUsuario;
  }

  @override
  int get hashCode => codUsuario.hashCode;
}
