/// Entidad de Nota de Entrega
class NotaEntregaEntity {
  final int codNotaEntrega;
  final int codCliente;
  final String nombreCliente;
  final DateTime fecha;
  final String direccion;
  final String zona;
  final int audUsuario;

  NotaEntregaEntity({
    required this.codNotaEntrega,
    required this.codCliente,
    required this.nombreCliente,
    required this.fecha,
    required this.direccion,
    required this.zona,
    required this.audUsuario,
  });

  NotaEntregaEntity copyWith({
    int? codNotaEntrega,
    int? codCliente,
    String? nombreCliente,
    DateTime? fecha,
    String? direccion,
    String? zona,
    int? audUsuario,
  }) {
    return NotaEntregaEntity(
      codNotaEntrega: codNotaEntrega ?? this.codNotaEntrega,
      codCliente: codCliente ?? this.codCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      fecha: fecha ?? this.fecha,
      direccion: direccion ?? this.direccion,
      zona: zona ?? this.zona,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
