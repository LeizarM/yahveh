import '../../domain/entities/venta_reporte_entity.dart';

/// Modelo para el reporte de ventas
class VentaReporteModel extends VentaReporteEntity {
  const VentaReporteModel({
    super.fecha,
    super.codCliente,
    super.nombreCliente,
    super.direccion,
    super.ciudad,
    super.codArticulo,
    super.cantidad,
    super.lineaArticulo,
    super.productoCompleto,
    super.precioUnitario,
    super.descuento,
    super.totalBs,
    super.descBs,
    super.bsUnitario,
    super.totalBsDesc,
    super.totalGeneralBs,
    required super.tipoFila,
  });

  /// Crea una instancia desde JSON
  factory VentaReporteModel.fromJson(Map<String, dynamic> json) {
    return VentaReporteModel(
      fecha: json['fecha'] as String?,
      codCliente: json['codCliente'] as int?,
      nombreCliente: json['nombreCliente'] as String?,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      codArticulo: json['codArticulo'] as String?,
      cantidad: json['cantidad'] as int?,
      lineaArticulo: json['lineaArticulo'] as String?,
      productoCompleto: json['productoCompleto'] as String?,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble(),
      descuento: (json['descuento'] as num?)?.toDouble(),
      totalBs: (json['totalBs'] as num?)?.toDouble(),
      descBs: (json['descBs'] as num?)?.toDouble(),
      bsUnitario: (json['bsUnitario'] as num?)?.toDouble(),
      totalBsDesc: (json['totalBsDesc'] as num?)?.toDouble(),
      totalGeneralBs: (json['totalGeneralBs'] as num?)?.toDouble(),
      tipoFila: json['tipoFila'] as String? ?? 'DETALLE',
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'codCliente': codCliente,
      'nombreCliente': nombreCliente,
      'direccion': direccion,
      'ciudad': ciudad,
      'codArticulo': codArticulo,
      'cantidad': cantidad,
      'lineaArticulo': lineaArticulo,
      'productoCompleto': productoCompleto,
      'precioUnitario': precioUnitario,
      'descuento': descuento,
      'totalBs': totalBs,
      'descBs': descBs,
      'bsUnitario': bsUnitario,
      'totalBsDesc': totalBsDesc,
      'totalGeneralBs': totalGeneralBs,
      'tipoFila': tipoFila,
    };
  }

  /// Convierte el modelo a entidad
  VentaReporteEntity toEntity() {
    return VentaReporteEntity(
      fecha: fecha,
      codCliente: codCliente,
      nombreCliente: nombreCliente,
      direccion: direccion,
      ciudad: ciudad,
      codArticulo: codArticulo,
      cantidad: cantidad,
      lineaArticulo: lineaArticulo,
      productoCompleto: productoCompleto,
      precioUnitario: precioUnitario,
      descuento: descuento,
      totalBs: totalBs,
      descBs: descBs,
      bsUnitario: bsUnitario,
      totalBsDesc: totalBsDesc,
      totalGeneralBs: totalGeneralBs,
      tipoFila: tipoFila,
    );
  }
}
