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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.codUsuario == codUsuario;
  }

  @override
  int get hashCode => codUsuario.hashCode;
}
