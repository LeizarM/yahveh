import 'dart:convert';
import '../../domain/entities/zona_entity.dart';

ZonaModel zonaModelFromJson(String str) => ZonaModel.fromJson(json.decode(str));

String zonaModelToJson(ZonaModel data) => json.encode(data.toJson());

class ZonaModel extends ZonaEntity {
  final String? ciudadNombre; // Para mostrar en el UI
  final String? paisNombre; // Para mostrar en el UI

  ZonaModel({
    required super.codZona,
    required super.codCiudad,
    required super.zona,
    required super.audUsuario,
    this.ciudadNombre,
    this.paisNombre,
  });

  factory ZonaModel.fromJson(Map<String, dynamic> json) => ZonaModel(
        codZona: json["codZona"],
        codCiudad: json["codCiudad"],
        zona: json["zona"],
        audUsuario: json["audUsuario"],
        ciudadNombre: json["ciudadNombre"] ?? json["ciudad"],
        paisNombre: json["paisNombre"] ?? json["pais"],
      );

  Map<String, dynamic> toJson() => {
        "codZona": codZona,
        "codCiudad": codCiudad,
        "zona": zona,
        "audUsuario": audUsuario,
        if (ciudadNombre != null) "ciudadNombre": ciudadNombre,
        if (paisNombre != null) "paisNombre": paisNombre,
      };

  Map<String, dynamic> toCreateJson() => {
        "codCiudad": codCiudad,
        "zona": zona,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toUpdateJson() => {
        "codZona": codZona,
        "codCiudad": codCiudad,
        "zona": zona,
        "audUsuario": audUsuario,
      };
}
