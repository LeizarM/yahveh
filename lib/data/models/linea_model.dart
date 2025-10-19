// To parse this JSON data, do
//
//     final lineaEntity = lineaEntityFromJson(jsonString);

import 'dart:convert';

LineaEntity lineaEntityFromJson(String str) => LineaEntity.fromJson(json.decode(str));

String lineaEntityToJson(LineaEntity data) => json.encode(data.toJson());

class LineaEntity {
    int codLinea;
    String linea;
    int audUsuario;

    LineaEntity({
        required this.codLinea,
        required this.linea,
        required this.audUsuario,
    });

    factory LineaEntity.fromJson(Map<String, dynamic> json) => LineaEntity(
        codLinea: json["codLinea"],
        linea: json["linea"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codLinea": codLinea,
        "linea": linea,
        "audUsuario": audUsuario,
    };
}
