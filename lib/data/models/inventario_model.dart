import 'dart:convert';
import '../../domain/entities/inventario_entity.dart';

InventarioModel inventarioModelFromJson(String str) => InventarioModel.fromJson(json.decode(str));

String inventarioModelToJson(InventarioModel data) => json.encode(data.toJson());

class InventarioModel extends InventarioEntity {
  InventarioModel({
    required super.codInventario,
    required super.codArticulo,
    required super.descripcionArticulo,
    required super.descripcion2Articulo,
    required super.lineaArticulo,
    required super.tipoMovimiento,
    required super.cantidad,
    required super.saldoAnterior,
    required super.saldoNuevo,
    required super.precioUnitario,
    required super.valorTotal,
    required super.fecha,
    super.observacion,
    super.codImportacion,
    required super.audUsuario,
  });

  factory InventarioModel.fromJson(Map<String, dynamic> json) => InventarioModel(
        codInventario: json["codInventario"] ?? 0,
        codArticulo: json["codArticulo"] ?? '',
        descripcionArticulo: json["descripcionArticulo"] ?? '',
        descripcion2Articulo: json["descripcion2Articulo"] ?? '',
        lineaArticulo: json["lineaArticulo"] ?? '',
        tipoMovimiento: json["tipoMovimiento"] ?? '',
        cantidad: json["cantidad"] ?? 0,
        saldoAnterior: json["saldoAnterior"] ?? 0,
        saldoNuevo: json["saldoNuevo"] ?? 0,
        precioUnitario: json["precioUnitario"]?.toDouble() ?? 0.0,
        valorTotal: json["valorTotal"]?.toDouble() ?? 0.0,
        fecha: json["fecha"] != null ? DateTime.parse(json["fecha"]) : DateTime.now(),
        observacion: json["observacion"],
        codImportacion: json["codImportacion"],
        audUsuario: json["audUsuario"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "codInventario": codInventario,
        "codArticulo": codArticulo,
        "descripcionArticulo": descripcionArticulo,
        "descripcion2Articulo": descripcion2Articulo,
        "lineaArticulo": lineaArticulo,
        "tipoMovimiento": tipoMovimiento,
        "cantidad": cantidad,
        "saldoAnterior": saldoAnterior,
        "saldoNuevo": saldoNuevo,
        "precioUnitario": precioUnitario,
        "valorTotal": valorTotal,
        "fecha": "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "observacion": observacion,
        "codImportacion": codImportacion,
        "audUsuario": audUsuario,
      };

  /// JSON para crear un nuevo movimiento de inventario
  Map<String, dynamic> toCreateJson() => {
        "codArticulo": codArticulo,
        "tipoMovimiento": tipoMovimiento,
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "observacion": observacion,
        if (codImportacion != null && codImportacion!.isNotEmpty) "codImportacion": codImportacion,
        // audUsuario se obtiene del JWT en el backend
      };

  /// Convierte el modelo a entidad
  InventarioEntity toEntity() => InventarioEntity(
        codInventario: codInventario,
        codArticulo: codArticulo,
        descripcionArticulo: descripcionArticulo,
        descripcion2Articulo: descripcion2Articulo,
        lineaArticulo: lineaArticulo,
        tipoMovimiento: tipoMovimiento,
        cantidad: cantidad,
        saldoAnterior: saldoAnterior,
        saldoNuevo: saldoNuevo,
        precioUnitario: precioUnitario,
        valorTotal: valorTotal,
        fecha: fecha,
        observacion: observacion,
        codImportacion: codImportacion,
        audUsuario: audUsuario,
      );
}
