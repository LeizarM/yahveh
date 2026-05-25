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
        super.precioSinFactura,
        required super.audUsuario,
        super.audFecha,
        super.rowNumber = 0,
    });

    factory ArticuloModel.fromJson(Map<String, dynamic> json) => ArticuloModel(
        codArticulo: json["codArticulo"],
        codLinea: json["codLinea"],
        linea: json["linea"],
        descripcion: json["descripcion"],
        descripcion2: json["descripcion2"],
        stockActual: json["stockActual"],
        precioActual: json["precioActual"]?.toDouble(),
        precioSinFactura: json["precioSinFactura"]?.toDouble(),
        audUsuario: json["audUsuario"],
        audFecha: json["audFecha"] != null ? DateTime.parse(json["audFecha"]) : null,
        rowNumber: (json["rowNumber"] ?? 0) is int
            ? (json["rowNumber"] ?? 0) as int
            : (json["rowNumber"] as num).toInt(),
    );

    Map<String, dynamic> toJson() => {
        "codArticulo": codArticulo,
        "codLinea": codLinea,
        "linea": linea,
        "descripcion": descripcion,
        "descripcion2": descripcion2,
        "stockActual": stockActual,
        "precioActual": precioActual,
        "precioSinFactura": precioSinFactura,
        "audUsuario": audUsuario,
        "audFecha": audFecha?.toIso8601String(),
        "rowNumber": rowNumber,
    };

    Map<String, dynamic> toCreateJson() => {
        "codArticulo": codArticulo,
        "codLinea": codLinea,
        "descripcion": descripcion,
        "descripcion2": descripcion2,
        "audUsuario": audUsuario,
    };

}

/// Modelo de página de artículos (server-side pagination).
class ArticuloPageModel extends ArticuloPage {
    ArticuloPageModel({
        required super.data,
        required super.total,
        required super.page,
        required super.pageSize,
        required super.totalPages,
    });

    factory ArticuloPageModel.fromJson(Map<String, dynamic> json) {
        final List<dynamic> raw = (json["data"] as List<dynamic>?) ?? [];
        return ArticuloPageModel(
            data: raw
                .map((e) => ArticuloModel.fromJson(e as Map<String, dynamic>))
                .toList(),
            total: (json["total"] ?? 0) is int
                ? (json["total"] ?? 0) as int
                : (json["total"] as num).toInt(),
            page: (json["page"] ?? 1) as int,
            pageSize: (json["pageSize"] ?? 20) as int,
            totalPages: (json["totalPages"] ?? 0) as int,
        );
    }
}
