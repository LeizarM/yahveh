/// Entidad de Línea
class LineaEntity {
  final int? codLinea;
  final int codFamilia;
  final String linea;
  final int audUsuario;
  final DateTime? audFecha;
  final int? totalArticulos;
  final int? articulosActivos;

  const LineaEntity({
    this.codLinea,
    required this.codFamilia,
    required this.linea,
    required this.audUsuario,
    this.audFecha,
    this.totalArticulos,
    this.articulosActivos,
  });
}
