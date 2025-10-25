// To parse this JSON data, do
//
//     final ciudadModel = ciudadModelFromJson(jsonString);

import 'dart:convert';

CiudadModel ciudadModelFromJson(String str) => CiudadModel.fromJson(json.decode(str));

String ciudadModelToJson(CiudadModel data) => json.encode(data.toJson());

class CiudadModel {
    int codCiudad;
    int codPais;
    String ciudad;
    int audUsuario;

    CiudadModel({
        required this.codCiudad,
        required this.codPais,
        required this.ciudad,
        required this.audUsuario,
    });

    factory CiudadModel.fromJson(Map<String, dynamic> json) => CiudadModel(
        codCiudad: json["codCiudad"],
        codPais: json["codPais"],
        ciudad: json["ciudad"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codCiudad": codCiudad,
        "codPais": codPais,
        "ciudad": ciudad,
        "audUsuario": audUsuario,
    };
}
