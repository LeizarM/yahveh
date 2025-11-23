import '../../domain/entities/persona_entity.dart';

/// Modelo de Persona para serialización JSON
class PersonaModel extends PersonaEntity {
  PersonaModel({
    required super.codPersona,
    required super.nombres,
    required super.apPaterno,
    required super.apMaterno,
    required super.ciNumero,
    required super.ciExpedido,
    super.ciFechaVencimiento,
    required super.direccion,
    required super.estadoCivil,
    super.fechaNacimiento,
    required super.lugarNacimiento,
    required super.sexo,
    required super.audUsuario,
  });

  /// Crear desde JSON
  factory PersonaModel.fromJson(Map<String, dynamic> json) {
    return PersonaModel(
      codPersona: json['codPersona'] as int,
      nombres: json['nombres'] as String,
      apPaterno: json['apPaterno'] as String,
      apMaterno: json['apMaterno'] as String,
      ciNumero: json['ciNumero'] as String,
      ciExpedido: json['ciExpedido'] as String,
      ciFechaVencimiento: json['ciFechaVencimiento'] != null
          ? DateTime.parse(json['ciFechaVencimiento'] as String)
          : null,
      direccion: json['direccion'] as String,
      estadoCivil: json['estadoCivil'] as String,
      fechaNacimiento: json['fechaNacimiento'] != null
          ? DateTime.parse(json['fechaNacimiento'] as String)
          : null,
      lugarNacimiento: json['lugarNacimiento'] as String,
      sexo: json['sexo'] as String,
      audUsuario: json['audUsuario'] as int,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'codPersona': codPersona,
      'nombres': nombres,
      'apPaterno': apPaterno,
      'apMaterno': apMaterno,
      'ciNumero': ciNumero,
      'ciExpedido': ciExpedido,
      'ciFechaVencimiento': ciFechaVencimiento?.toIso8601String(),
      'direccion': direccion,
      'estadoCivil': estadoCivil,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'lugarNacimiento': lugarNacimiento,
      'sexo': sexo,
      'audUsuario': audUsuario,
    };
  }

  /// Convertir a JSON para crear (sin codPersona)
  Map<String, dynamic> toCreateJson() {
    return {
      'nombres': nombres,
      'apPaterno': apPaterno,
      'apMaterno': apMaterno,
      'ciNumero': ciNumero,
      'ciExpedido': ciExpedido,
      'ciFechaVencimiento': ciFechaVencimiento?.toIso8601String(),
      'direccion': direccion,
      'estadoCivil': estadoCivil,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'lugarNacimiento': lugarNacimiento,
      'sexo': sexo,
    };
  }

  /// Convertir a JSON para actualizar
  Map<String, dynamic> toUpdateJson() {
    return toCreateJson();
  }

  /// Convertir a Entity
  PersonaEntity toEntity() {
    return PersonaEntity(
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
      audUsuario: audUsuario,
    );
  }
}
