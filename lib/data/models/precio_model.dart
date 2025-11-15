import 'dart:convert';
import '../../domain/entities/precio_entity.dart';

PrecioModel precioModelFromJson(String str) => PrecioModel.fromJson(json.decode(str));

String precioModelToJson(PrecioModel data) => json.encode(data.toJson());

class PrecioModel extends PrecioEntity {
  PrecioModel({
    required super.listaPrecio,
    required super.codPrecio,
    required super.codArticulo,
    required super.precioBase,
    required super.precio,
    required super.precioSinFactura,
    required super.audUsuario,
    required super.audFecha,
  });

  factory PrecioModel.fromJson(Map<String, dynamic> json) => PrecioModel(
        listaPrecio: json["listaPrecio"] ?? 0,
        codPrecio: json["codPrecio"] ?? 0, // int desde el backend
        codArticulo: json["codArticulo"] ?? '',
        precioBase: json["precioBase"]?.toDouble() ?? 0.0,
        precio: json["precio"]?.toDouble() ?? 0.0,
        precioSinFactura: json["precioSinFactura"]?.toDouble() ?? 0.0,
        // audUsuario y audFecha pueden no venir en las respuestas GET
        audUsuario: json["audUsuario"] ?? 0,
        audFecha: json["audFecha"] != null 
            ? DateTime.parse(json["audFecha"]) 
            : DateTime.now(),
        // Nota: descripcionArticulo y linea vienen en el response pero no se usan en el modelo
      );

  Map<String, dynamic> toJson() => {
        "listaPrecio": listaPrecio,
        "codPrecio": codPrecio,
        "codArticulo": codArticulo,
        "precioBase": precioBase,
        "precio": precio,
        "precioSinFactura": precioSinFactura,
        "audUsuario": audUsuario,
        "audFecha": audFecha.toIso8601String(),
      };

  /// JSON para crear un nuevo precio (sin codPrecio ni listaPrecio porque son auto-increment)
  Map<String, dynamic> toCreateJson() => {
        "codArticulo": codArticulo,
        "precioBase": precioBase,
        "precio": precio,
        "precioSinFactura": precioSinFactura,
        "audUsuario": audUsuario,
      };

  /// Convierte el modelo a entidad
  PrecioEntity toEntity() => PrecioEntity(
        listaPrecio: listaPrecio,
        codPrecio: codPrecio,
        codArticulo: codArticulo,
        precioBase: precioBase,
        precio: precio,
        precioSinFactura: precioSinFactura,
        audUsuario: audUsuario,
        audFecha: audFecha,
      );
}
