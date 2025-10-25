// To parse this JSON data, do
//
//     final paisModel = paisModelFromJson(jsonString);

import 'dart:convert';

PaisModel paisModelFromJson(String str) => PaisModel.fromJson(json.decode(str));

String paisModelToJson(PaisModel data) => json.encode(data.toJson());

class PaisModel {
    int codPais;
    String pais;
    int audUsuario;

    PaisModel({
        required this.codPais,
        required this.pais,
        required this.audUsuario,
    });

    factory PaisModel.fromJson(Map<String, dynamic> json) => PaisModel(
        codPais: json["codPais"],
        pais: json["pais"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codPais": codPais,
        "pais": pais,
        "audUsuario": audUsuario,
    };
}
