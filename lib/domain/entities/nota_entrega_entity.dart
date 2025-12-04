/// Entidad de Nota de Entrega
class NotaEntregaEntity {
  final int codNotaEntrega;
  final int codCliente;
  final String nombreCliente;
  final DateTime fecha;
  final String direccion;
  final String zona;
  final int estado;
  final String estadoTexto;
  final int audUsuario;

  NotaEntregaEntity({
    required this.codNotaEntrega,
    required this.codCliente,
    required this.nombreCliente,
    required this.fecha,
    required this.direccion,
    required this.zona,
    this.estado = 1,
    this.estadoTexto = 'Válido',
    required this.audUsuario,
  });

  /// Verifica si la nota está anulada
  bool get isAnulada => estado == 0;

  /// Verifica si la nota está válida
  bool get isValida => estado == 1;

  NotaEntregaEntity copyWith({
    int? codNotaEntrega,
    int? codCliente,
    String? nombreCliente,
    DateTime? fecha,
    String? direccion,
    String? zona,
    int? estado,
    String? estadoTexto,
    int? audUsuario,
  }) {
    return NotaEntregaEntity(
      codNotaEntrega: codNotaEntrega ?? this.codNotaEntrega,
      codCliente: codCliente ?? this.codCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      fecha: fecha ?? this.fecha,
      direccion: direccion ?? this.direccion,
      zona: zona ?? this.zona,
      estado: estado ?? this.estado,
      estadoTexto: estadoTexto ?? this.estadoTexto,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
