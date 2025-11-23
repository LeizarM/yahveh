/// Entidad de Empleado
class EmpleadoEntity {
  final int codEmpleado;
  final int codPersona;
  final int audUsuario;

  EmpleadoEntity({
    required this.codEmpleado,
    required this.codPersona,
    required this.audUsuario,
  });

  EmpleadoEntity copyWith({
    int? codEmpleado,
    int? codPersona,
    int? audUsuario,
  }) {
    return EmpleadoEntity(
      codEmpleado: codEmpleado ?? this.codEmpleado,
      codPersona: codPersona ?? this.codPersona,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
