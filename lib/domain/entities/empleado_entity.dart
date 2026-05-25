/// Entidad de Empleado
class EmpleadoEntity {
  final int codEmpleado;
  final int codPersona;
  final int audUsuario;
  // ⭐ Datos de la persona embebidos (vienen del backend en EmpleadoResponse)
  final String nombres;
  final String apPaterno;
  final String apMaterno;
  final String nombreCompleto;
  final String ciNumero;

  EmpleadoEntity({
    required this.codEmpleado,
    required this.codPersona,
    required this.audUsuario,
    this.nombres = '',
    this.apPaterno = '',
    this.apMaterno = '',
    this.nombreCompleto = '',
    this.ciNumero = '',
  });

  /// Nombre para mostrar — usa nombreCompleto si viene; sino arma uno
  String get displayName {
    if (nombreCompleto.trim().isNotEmpty) return nombreCompleto.trim();
    final composed = '$nombres $apPaterno $apMaterno'.trim();
    if (composed.isNotEmpty) return composed;
    return 'Empleado #$codEmpleado';
  }

  EmpleadoEntity copyWith({
    int? codEmpleado,
    int? codPersona,
    int? audUsuario,
    String? nombres,
    String? apPaterno,
    String? apMaterno,
    String? nombreCompleto,
    String? ciNumero,
  }) {
    return EmpleadoEntity(
      codEmpleado: codEmpleado ?? this.codEmpleado,
      codPersona: codPersona ?? this.codPersona,
      audUsuario: audUsuario ?? this.audUsuario,
      nombres: nombres ?? this.nombres,
      apPaterno: apPaterno ?? this.apPaterno,
      apMaterno: apMaterno ?? this.apMaterno,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      ciNumero: ciNumero ?? this.ciNumero,
    );
  }
}
