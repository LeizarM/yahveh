class ArticuloEntity {
    String? codArticulo;
    int codLinea;
    String? linea;
    String descripcion;
    String descripcion2;
    int? stockActual;
    double? precioActual;
    double? precioSinFactura;
    int audUsuario;
    DateTime? audFecha;
    /// Numero global del artículo (1..N) calculado en BD. Se mantiene aun
    /// paginando, así #1234 sigue siendo #1234 aunque cambiemos de página.
    int rowNumber;

    ArticuloEntity({
        this.codArticulo,
        required this.codLinea,
        this.linea,
        required this.descripcion,
        required this.descripcion2,
        this.stockActual,
        this.precioActual,
        this.precioSinFactura,
        required this.audUsuario,
        this.audFecha,
        this.rowNumber = 0,
    });

}

/// Página de artículos con metadata para paginación server-side.
class ArticuloPage {
    final List<ArticuloEntity> data;
    final int total;
    final int page;
    final int pageSize;
    final int totalPages;

    ArticuloPage({
        required this.data,
        required this.total,
        required this.page,
        required this.pageSize,
        required this.totalPages,
    });

    bool get hasNext => page < totalPages;
    bool get hasPrev => page > 1;
}
