// To parse this JSON data, do
//
//     final articuloModel = articuloModelFromJson(jsonString);

import 'dart:convert';
import '../../domain/entities/articulo_entity.dart';

ArticuloModel articuloModelFromJson(String str) => ArticuloModel.fromJson(json.decode(str));

String articuloModelToJson(ArticuloModel data) => json.encode(data.toJson());

class ArticuloModel extends ArticuloEntity {
    ArticuloModel({
        super.codArticulo,
        required super.codLinea,
        super.linea,
        required super.descripcion,
        required super.descripcion2,
        super.stockActual,
        super.precioActual,
        required super.audUsuario,
        super.audFecha,
    });

    factory ArticuloModel.fromJson(Map<String, dynamic> json) => ArticuloModel(
        codArticulo: json["codArticulo"],
        codLinea: json["codLinea"],
        linea: json["linea"],
        descripcion: json["descripcion"],
        descripcion2: json["descripcion2"],
        stockActual: json["stockActual"],
        precioActual: json["precioActual"]?.toDouble(),
        audUsuario: json["audUsuario"],
        audFecha: json["audFecha"] != null ? DateTime.parse(json["audFecha"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "codArticulo": codArticulo,
        "codLinea": codLinea,
        "linea": linea,
        "descripcion": descripcion,
        "descripcion2": descripcion2,
        "stockActual": stockActual,
        "precioActual": precioActual,
        "audUsuario": audUsuario,
        "audFecha": audFecha?.toIso8601String(),
    };

    Map<String, dynamic> toCreateJson() => {
        "codArticulo": codArticulo,
        "codLinea": codLinea,
        "descripcion": descripcion,
        "descripcion2": descripcion2,
        "audUsuario": audUsuario,
    };

}
