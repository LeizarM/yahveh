/// Entidad que representa un movimiento de inventario
class InventarioEntity {
  int codInventario;
  String codArticulo;
  String descripcionArticulo;
  String descripcion2Articulo;
  String lineaArticulo;
  String tipoMovimiento; // ENTRADA, SALIDA, AJUSTE, INVENTARIO_INICIAL
  int cantidad;
  int saldoAnterior;
  int saldoNuevo;
  double precioUnitario;
  double valorTotal;
  DateTime fecha;
  String? observacion;
  int audUsuario;

  InventarioEntity({
    required this.codInventario,
    required this.codArticulo,
    required this.descripcionArticulo,
    required this.descripcion2Articulo,
    required this.lineaArticulo,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.saldoAnterior,
    required this.saldoNuevo,
    required this.precioUnitario,
    required this.valorTotal,
    required this.fecha,
    this.observacion,
    required this.audUsuario,
  });

  /// Copia la entidad con campos opcionales modificados
  InventarioEntity copyWith({
    int? codInventario,
    String? codArticulo,
    String? descripcionArticulo,
    String? descripcion2Articulo,
    String? lineaArticulo,
    String? tipoMovimiento,
    int? cantidad,
    int? saldoAnterior,
    int? saldoNuevo,
    double? precioUnitario,
    double? valorTotal,
    DateTime? fecha,
    String? observacion,
    int? audUsuario,
  }) {
    return InventarioEntity(
      codInventario: codInventario ?? this.codInventario,
      codArticulo: codArticulo ?? this.codArticulo,
      descripcionArticulo: descripcionArticulo ?? this.descripcionArticulo,
      descripcion2Articulo: descripcion2Articulo ?? this.descripcion2Articulo,
      lineaArticulo: lineaArticulo ?? this.lineaArticulo,
      tipoMovimiento: tipoMovimiento ?? this.tipoMovimiento,
      cantidad: cantidad ?? this.cantidad,
      saldoAnterior: saldoAnterior ?? this.saldoAnterior,
      saldoNuevo: saldoNuevo ?? this.saldoNuevo,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      fecha: fecha ?? this.fecha,
      observacion: observacion ?? this.observacion,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
