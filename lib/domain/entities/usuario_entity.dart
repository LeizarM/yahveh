/// Entidad de Usuario
class UsuarioEntity {
  final int codUsuario;
  final int codEmpleado;
  final String login;
  final String tipoUsuario;
  final String estado;
  final int audUsuario;

  UsuarioEntity({
    required this.codUsuario,
    required this.codEmpleado,
    required this.login,
    required this.tipoUsuario,
    required this.estado,
    required this.audUsuario,
  });

  UsuarioEntity copyWith({
    int? codUsuario,
    int? codEmpleado,
    String? login,
    String? tipoUsuario,
    String? estado,
    int? audUsuario,
  }) {
    return UsuarioEntity(
      codUsuario: codUsuario ?? this.codUsuario,
      codEmpleado: codEmpleado ?? this.codEmpleado,
      login: login ?? this.login,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      estado: estado ?? this.estado,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
