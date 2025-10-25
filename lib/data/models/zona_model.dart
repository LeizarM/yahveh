// To parse this JSON data, do
//
//     final zonaModel = zonaModelFromJson(jsonString);

import 'dart:convert';

ZonaModel zonaModelFromJson(String str) => ZonaModel.fromJson(json.decode(str));

String zonaModelToJson(ZonaModel data) => json.encode(data.toJson());

class ZonaModel {
    int codZona;
    int codCiudad;
    String zona;
    int audUsuario;

    ZonaModel({
        required this.codZona,
        required this.codCiudad,
        required this.zona,
        required this.audUsuario,
    });

    factory ZonaModel.fromJson(Map<String, dynamic> json) => ZonaModel(
        codZona: json["codZona"],
        codCiudad: json["codCiudad"],
        zona: json["zona"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codZona": codZona,
        "codCiudad": codCiudad,
        "zona": zona,
        "audUsuario": audUsuario,
    };
}
