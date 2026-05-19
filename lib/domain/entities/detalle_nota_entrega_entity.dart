/// Entidad de Detalle de Nota de Entrega
class DetalleNotaEntregaEntity {
  final int codDetalle;
  final int codNotaEntrega;
  final String codArticulo;
  final String descripcionArticulo;
  final String descripcion2Articulo;
  final String lineaArticulo;
  final int codLinea;
  final int cantidad;
  final double precioUnitario;
  final double precioTotal;
  final double precioSinFactura;
  final double descuento;
  final int audUsuario;

  DetalleNotaEntregaEntity({
    required this.codDetalle,
    required this.codNotaEntrega,
    required this.codArticulo,
    required this.descripcionArticulo,
    required this.descripcion2Articulo,
    required this.lineaArticulo,
    required this.codLinea,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioTotal,
    required this.precioSinFactura,
    this.descuento = 0,
    required this.audUsuario,
  });

  DetalleNotaEntregaEntity copyWith({
    int? codDetalle,
    int? codNotaEntrega,
    String? codArticulo,
    String? descripcionArticulo,
    String? descripcion2Articulo,
    String? lineaArticulo,
    int? codLinea,
    int? cantidad,
    double? precioUnitario,
    double? precioTotal,
    double? precioSinFactura,
    double? descuento,
    int? audUsuario,
  }) {
    return DetalleNotaEntregaEntity(
      codDetalle: codDetalle ?? this.codDetalle,
      codNotaEntrega: codNotaEntrega ?? this.codNotaEntrega,
      codArticulo: codArticulo ?? this.codArticulo,
      descripcionArticulo: descripcionArticulo ?? this.descripcionArticulo,
      descripcion2Articulo: descripcion2Articulo ?? this.descripcion2Articulo,
      lineaArticulo: lineaArticulo ?? this.lineaArticulo,
      codLinea: codLinea ?? this.codLinea,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioTotal: precioTotal ?? this.precioTotal,
      precioSinFactura: precioSinFactura ?? this.precioSinFactura,
      descuento: descuento ?? this.descuento,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
