import 'dart:convert';
import '../../domain/entities/usuario_entity.dart';

UsuarioModel usuarioModelFromJson(String str) =>
    UsuarioModel.fromJson(json.decode(str));

String usuarioModelToJson(UsuarioModel data) => json.encode(data.toJson());

class UsuarioModel extends UsuarioEntity {
  UsuarioModel({
    required super.codUsuario,
    required super.codEmpleado,
    required super.login,
    required super.tipoUsuario,
    required super.estado,
    required super.audUsuario,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        codUsuario: json["codUsuario"] ?? 0,
        codEmpleado: json["codEmpleado"] ?? 0,
        login: json["login"] ?? '',
        tipoUsuario: json["tipoUsuario"] ?? '',
        estado: json["estado"] ?? '',
        audUsuario: json["audUsuario"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "codUsuario": codUsuario,
        "codEmpleado": codEmpleado,
        "login": login,
        "tipoUsuario": tipoUsuario,
        "estado": estado,
        "audUsuario": audUsuario,
      };

  /// JSON para crear un nuevo usuario
  Map<String, dynamic> toCreateJson({
    required String password,
  }) =>
      {
        "codEmpleado": codEmpleado,
        "login": login,
        "password": password,
        "tipoUsuario": tipoUsuario,
        "estado": estado,
      };

  /// JSON para actualizar un usuario existente
  Map<String, dynamic> toUpdateJson({
    String? password,
  }) {
    final map = {
      "codEmpleado": codEmpleado,
      "login": login,
      "tipoUsuario": tipoUsuario,
      "estado": estado,
    };
    
    if (password != null && password.isNotEmpty) {
      map["password"] = password;
    }
    
    return map;
  }

  UsuarioEntity toEntity() => UsuarioEntity(
        codUsuario: codUsuario,
        codEmpleado: codEmpleado,
        login: login,
        tipoUsuario: tipoUsuario,
        estado: estado,
        audUsuario: audUsuario,
      );
}
