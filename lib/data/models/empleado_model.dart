import '../../domain/entities/empleado_entity.dart';

/// Modelo de Empleado para serialización JSON
class EmpleadoModel extends EmpleadoEntity {
  EmpleadoModel({
    required super.codEmpleado,
    required super.codPersona,
    required super.audUsuario,
    super.nombres = '',
    super.apPaterno = '',
    super.apMaterno = '',
    super.nombreCompleto = '',
    super.ciNumero = '',
  });

  /// Crear desde JSON
  /// ⭐ El backend (EmpleadoResponse) ya devuelve los datos de la persona embebidos.
  /// Defensivo contra valores null.
  factory EmpleadoModel.fromJson(Map<String, dynamic> json) {
    return EmpleadoModel(
      codEmpleado: (json['codEmpleado'] as num?)?.toInt() ?? 0,
      codPersona: (json['codPersona'] as num?)?.toInt() ?? 0,
      audUsuario: (json['audUsuario'] as num?)?.toInt() ?? 0,
      nombres: (json['nombres'] as String?) ?? '',
      apPaterno: (json['apPaterno'] as String?) ?? '',
      apMaterno: (json['apMaterno'] as String?) ?? '',
      nombreCompleto: (json['nombreCompleto'] as String?) ?? '',
      ciNumero: (json['ciNumero'] as String?) ?? '',
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'codEmpleado': codEmpleado,
      'codPersona': codPersona,
      'audUsuario': audUsuario,
      'nombres': nombres,
      'apPaterno': apPaterno,
      'apMaterno': apMaterno,
      'nombreCompleto': nombreCompleto,
      'ciNumero': ciNumero,
    };
  }

  /// Convertir a JSON para crear (sin codEmpleado)
  Map<String, dynamic> toCreateJson() {
    return {
      'codPersona': codPersona,
    };
  }

  /// Convertir a JSON para actualizar
  Map<String, dynamic> toUpdateJson() {
    return toCreateJson();
  }

  /// Convertir a Entity
  EmpleadoEntity toEntity() {
    return EmpleadoEntity(
      codEmpleado: codEmpleado,
      codPersona: codPersona,
      audUsuario: audUsuario,
      nombres: nombres,
      apPaterno: apPaterno,
      apMaterno: apMaterno,
      nombreCompleto: nombreCompleto,
      ciNumero: ciNumero,
    );
  }
}
