class ReglaDescuentoEntity {
  final int codReglaDescuento;
  final String codArticulo;
  final String descripcionArticulo;
  final int cantidadMinima;
  final double descuento;
  final int audUsuario;

  ReglaDescuentoEntity({
    required this.codReglaDescuento,
    required this.codArticulo,
    required this.descripcionArticulo,
    required this.cantidadMinima,
    required this.descuento,
    required this.audUsuario,
  });
}
