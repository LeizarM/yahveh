/// Entidad para el reporte de ventas
class VentaReporteEntity {
  final String? fecha;
  final int? codCliente;
  final String? nombreCliente;
  final String? direccion;
  final String? ciudad;
  final String? codArticulo;
  final int? cantidad;
  final String? lineaArticulo;
  final String? productoCompleto;
  final double? precioUnitario;
  final double? descuento;
  final double? totalBs;
  final double? descBs;
  final double? bsUnitario;
  final double? totalBsDesc;
  final double? totalGeneralBs;
  final String tipoFila; // 'DETALLE' o 'TOTAL'

  const VentaReporteEntity({
    this.fecha,
    this.codCliente,
    this.nombreCliente,
    this.direccion,
    this.ciudad,
    this.codArticulo,
    this.cantidad,
    this.lineaArticulo,
    this.productoCompleto,
    this.precioUnitario,
    this.descuento,
    this.totalBs,
    this.descBs,
    this.bsUnitario,
    this.totalBsDesc,
    this.totalGeneralBs,
    required this.tipoFila,
  });

  /// Verifica si es una fila de total
  bool get isTotal => tipoFila == 'TOTAL';

  /// Verifica si es una fila de detalle
  bool get isDetalle => tipoFila == 'DETALLE';

  /// Formatea el descuento como porcentaje
  String get descuentoPorcentaje {
    if (descuento == null) return '-';
    return '${(descuento! * 100).toStringAsFixed(2)}%';
  }

  /// Formatea un valor monetario
  String formatMoney(double? value) {
    if (value == null) return '-';
    return 'Bs. ${value.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'VentaReporteEntity(fecha: $fecha, cliente: $nombreCliente, producto: $productoCompleto, total: $totalGeneralBs, tipo: $tipoFila)';
  }
}
