// To parse this JSON data, do
//
//     final articuloModel = articuloModelFromJson(jsonString);

import 'dart:convert';

ArticuloModel articuloModelFromJson(String str) => ArticuloModel.fromJson(json.decode(str));

String articuloModelToJson(ArticuloModel data) => json.encode(data.toJson());

class ArticuloModel {
    String codArticulo;
    int codLinea;
    String descripcion;
    String descripcion2;
    int audUsuario;

    ArticuloModel({
        required this.codArticulo,
        required this.codLinea,
        required this.descripcion,
        required this.descripcion2,
        required this.audUsuario,
    });

    factory ArticuloModel.fromJson(Map<String, dynamic> json) => ArticuloModel(
        codArticulo: json["codArticulo"],
        codLinea: json["codLinea"],
        descripcion: json["descripcion"],
        descripcion2: json["descripcion2"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codArticulo": codArticulo,
        "codLinea": codLinea,
        "descripcion": descripcion,
        "descripcion2": descripcion2,
        "audUsuario": audUsuario,
    };
}
