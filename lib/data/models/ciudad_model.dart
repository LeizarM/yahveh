import 'dart:convert';
import '../../domain/entities/ciudad_entity.dart';

CiudadModel ciudadModelFromJson(String str) => CiudadModel.fromJson(json.decode(str));

String ciudadModelToJson(CiudadModel data) => json.encode(data.toJson());

class CiudadModel extends CiudadEntity {
  final String? paisNombre; // Para mostrar en el UI

  CiudadModel({
    required super.codCiudad,
    required super.codPais,
    required super.ciudad,
    required super.audUsuario,
    this.paisNombre,
  });

  factory CiudadModel.fromJson(Map<String, dynamic> json) => CiudadModel(
        codCiudad: json["codCiudad"],
        codPais: json["codPais"],
        ciudad: json["ciudad"],
        audUsuario: json["audUsuario"],
        paisNombre: json["paisNombre"] ?? json["pais"], // Backend puede retornar como "pais" o "paisNombre"
      );

  Map<String, dynamic> toJson() => {
        "codCiudad": codCiudad,
        "codPais": codPais,
        "ciudad": ciudad,
        "audUsuario": audUsuario,
        if (paisNombre != null) "paisNombre": paisNombre,
      };

  Map<String, dynamic> toCreateJson() => {
        "codPais": codPais,
        "ciudad": ciudad,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toUpdateJson() => {
        "codCiudad": codCiudad,
        "codPais": codPais,
        "ciudad": ciudad,
        "audUsuario": audUsuario,
      };
}
