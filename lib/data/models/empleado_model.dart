import '../../domain/entities/empleado_entity.dart';

/// Modelo de Empleado para serialización JSON
class EmpleadoModel extends EmpleadoEntity {
  EmpleadoModel({
    required super.codEmpleado,
    required super.codPersona,
    required super.audUsuario,
  });

  /// Crear desde JSON
  factory EmpleadoModel.fromJson(Map<String, dynamic> json) {
    return EmpleadoModel(
      codEmpleado: json['codEmpleado'] as int,
      codPersona: json['codPersona'] as int,
      audUsuario: json['audUsuario'] as int,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'codEmpleado': codEmpleado,
      'codPersona': codPersona,
      'audUsuario': audUsuario,
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
    );
  }
}
