class ArticuloEntity {
    String? codArticulo;
    int codLinea;
    String? linea;
    String descripcion;
    String descripcion2;
    int? stockActual;
    double? precioActual;
    int audUsuario;
    DateTime? audFecha;

    ArticuloEntity({
        this.codArticulo,
        required this.codLinea,
        this.linea,
        required this.descripcion,
        required this.descripcion2,
        this.stockActual,
        this.precioActual,
        required this.audUsuario,
        this.audFecha,
    });

}
