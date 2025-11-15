/// Entidad que representa un precio de artículo
class PrecioEntity {
  int listaPrecio;
  int codPrecio;
  String codArticulo;
  double precioBase;
  double precio;
  double precioSinFactura;
  int audUsuario;
  DateTime audFecha;

  PrecioEntity({
    required this.listaPrecio,
    required this.codPrecio,
    required this.codArticulo,
    required this.precioBase,
    required this.precio,
    required this.precioSinFactura,
    required this.audUsuario,
    required this.audFecha,
  });

  /// Copia la entidad con campos opcionales modificados
  PrecioEntity copyWith({
    int? listaPrecio,
    int? codPrecio,
    String? codArticulo,
    double? precioBase,
    double? precio,
    double? precioSinFactura,
    int? audUsuario,
    DateTime? audFecha,
  }) {
    return PrecioEntity(
      listaPrecio: listaPrecio ?? this.listaPrecio,
      codPrecio: codPrecio ?? this.codPrecio,
      codArticulo: codArticulo ?? this.codArticulo,
      precioBase: precioBase ?? this.precioBase,
      precio: precio ?? this.precio,
      precioSinFactura: precioSinFactura ?? this.precioSinFactura,
      audUsuario: audUsuario ?? this.audUsuario,
      audFecha: audFecha ?? this.audFecha,
    );
  }
}
