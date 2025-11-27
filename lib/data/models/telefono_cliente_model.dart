import '../../domain/entities/telefono_cliente_entity.dart';

/// Modelo de Teléfono de Cliente para serialización JSON
class TelefonoClienteModel extends TelefonoClienteEntity {
  TelefonoClienteModel({
    required super.codTlfCliente,
    required super.codCliente,
    required super.telefono,
    required super.audUsuario,
  });

  /// Crear desde JSON
  factory TelefonoClienteModel.fromJson(Map<String, dynamic> json) {
    return TelefonoClienteModel(
      codTlfCliente: json['codTlfCliente'] as int,
      codCliente: json['codCliente'] as int,
      telefono: json['telefono'] as String,
      audUsuario: json['audUsuario'] as int,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'codTlfCliente': codTlfCliente,
      'codCliente': codCliente,
      'telefono': telefono,
      'audUsuario': audUsuario,
    };
  }

  /// Convertir a JSON para crear (sin codTlfCliente)
  Map<String, dynamic> toCreateJson() {
    return {
      'codCliente': codCliente,
      'telefono': telefono,
    };
  }

  /// Convertir a JSON para actualizar
  Map<String, dynamic> toUpdateJson() {
    return {
      'codCliente': codCliente,
      'telefono': telefono,
    };
  }

  /// Convertir a Entity
  TelefonoClienteEntity toEntity() {
    return TelefonoClienteEntity(
      codTlfCliente: codTlfCliente,
      codCliente: codCliente,
      telefono: telefono,
      audUsuario: audUsuario,
    );
  }
}
