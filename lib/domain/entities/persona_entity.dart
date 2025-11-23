/// Entidad de Persona
class PersonaEntity {
  final int codPersona;
  final String nombres;
  final String apPaterno;
  final String apMaterno;
  final String ciNumero;
  final String ciExpedido;
  final DateTime? ciFechaVencimiento;
  final String direccion;
  final String estadoCivil;
  final DateTime? fechaNacimiento;
  final String lugarNacimiento;
  final String sexo;
  final int audUsuario;

  PersonaEntity({
    required this.codPersona,
    required this.nombres,
    required this.apPaterno,
    required this.apMaterno,
    required this.ciNumero,
    required this.ciExpedido,
    this.ciFechaVencimiento,
    required this.direccion,
    required this.estadoCivil,
    this.fechaNacimiento,
    required this.lugarNacimiento,
    required this.sexo,
    required this.audUsuario,
  });

  /// Obtener nombre completo
  String get nombreCompleto => '$nombres $apPaterno $apMaterno';

  PersonaEntity copyWith({
    int? codPersona,
    String? nombres,
    String? apPaterno,
    String? apMaterno,
    String? ciNumero,
    String? ciExpedido,
    DateTime? ciFechaVencimiento,
    String? direccion,
    String? estadoCivil,
    DateTime? fechaNacimiento,
    String? lugarNacimiento,
    String? sexo,
    int? audUsuario,
  }) {
    return PersonaEntity(
      codPersona: codPersona ?? this.codPersona,
      nombres: nombres ?? this.nombres,
      apPaterno: apPaterno ?? this.apPaterno,
      apMaterno: apMaterno ?? this.apMaterno,
      ciNumero: ciNumero ?? this.ciNumero,
      ciExpedido: ciExpedido ?? this.ciExpedido,
      ciFechaVencimiento: ciFechaVencimiento ?? this.ciFechaVencimiento,
      direccion: direccion ?? this.direccion,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      lugarNacimiento: lugarNacimiento ?? this.lugarNacimiento,
      sexo: sexo ?? this.sexo,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
