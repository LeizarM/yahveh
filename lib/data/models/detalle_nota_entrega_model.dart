import 'dart:convert';
import '../../domain/entities/detalle_nota_entrega_entity.dart';

DetalleNotaEntregaModel detalleNotaEntregaModelFromJson(String str) => 
    DetalleNotaEntregaModel.fromJson(json.decode(str));

String detalleNotaEntregaModelToJson(DetalleNotaEntregaModel data) => 
    json.encode(data.toJson());

class DetalleNotaEntregaModel extends DetalleNotaEntregaEntity {
  DetalleNotaEntregaModel({
    required super.codDetalle,
    required super.codNotaEntrega,
    required super.codArticulo,
    required super.descripcionArticulo,
    required super.descripcion2Articulo,
    required super.lineaArticulo,
    required super.codLinea,
    required super.cantidad,
    required super.precioUnitario,
    required super.precioTotal,
    required super.precioSinFactura,
    super.descuento = 0,
    required super.audUsuario,
  });

  factory DetalleNotaEntregaModel.fromJson(Map<String, dynamic> json) =>
      DetalleNotaEntregaModel(
        codDetalle: json["codDetalle"] ?? 0,
        codNotaEntrega: json["codNotaEntrega"] ?? 0,
        codArticulo: json["codArticulo"] ?? '',
        descripcionArticulo: json["descripcionArticulo"] ?? '',
        descripcion2Articulo: json["descripcion2Articulo"] ?? '',
        lineaArticulo: json["lineaArticulo"] ?? '',
        codLinea: json["codLinea"] ?? 0,
        cantidad: json["cantidad"] ?? 0,
        precioUnitario: json["precioUnitario"]?.toDouble() ?? 0.0,
        precioTotal: json["precioTotal"]?.toDouble() ?? 0.0,
        precioSinFactura: json["precioSinFactura"]?.toDouble() ?? 0.0,
        descuento: json["descuento"]?.toDouble() ?? 0.0,
        audUsuario: json["audUsuario"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "codDetalle": codDetalle,
        "codNotaEntrega": codNotaEntrega,
        "codArticulo": codArticulo,
        "descripcionArticulo": descripcionArticulo,
        "descripcion2Articulo": descripcion2Articulo,
        "lineaArticulo": lineaArticulo,
        "codLinea": codLinea,
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "precioTotal": precioTotal,
        "precioSinFactura": precioSinFactura,
        "descuento": descuento,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toCreateJson() => {
        "codArticulo": codArticulo,
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "precioSinFactura": precioSinFactura,
        "descuento": descuento,
      };

  DetalleNotaEntregaEntity toEntity() => DetalleNotaEntregaEntity(
        codDetalle: codDetalle,
        codNotaEntrega: codNotaEntrega,
        codArticulo: codArticulo,
        descripcionArticulo: descripcionArticulo,
        descripcion2Articulo: descripcion2Articulo,
        lineaArticulo: lineaArticulo,
        codLinea: codLinea,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        precioTotal: precioTotal,
        precioSinFactura: precioSinFactura,
        descuento: descuento,
        audUsuario: audUsuario,
      );
}
