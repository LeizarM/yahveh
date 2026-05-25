/// Entidad de Nota de Entrega
class NotaEntregaEntity {
  final int codNotaEntrega;
  final int codCliente;
  final String nombreCliente;
  final DateTime fecha;
  final String direccion;
  final String zona;
  final String nit;
  final int? codEmpleado;
  final int estado;
  final String estadoTexto;
  final int audUsuario;
  final String nombreEmpleado;

  NotaEntregaEntity({
    required this.codNotaEntrega,
    required this.codCliente,
    required this.nombreCliente,
    required this.fecha,
    required this.direccion,
    required this.zona,
    this.nit = '',
    this.codEmpleado,
    this.estado = 1,
    this.estadoTexto = 'Válido',
    required this.audUsuario,
    this.nombreEmpleado = '',
  });

  bool get isAnulada => estado == 0;
  bool get isValida => estado == 1;

  NotaEntregaEntity copyWith({
    int? codNotaEntrega,
    int? codCliente,
    String? nombreCliente,
    DateTime? fecha,
    String? direccion,
    String? zona,
    String? nit,
    int? codEmpleado,
    int? estado,
    String? estadoTexto,
    int? audUsuario,
    String? nombreEmpleado,
  }) {
    return NotaEntregaEntity(
      codNotaEntrega: codNotaEntrega ?? this.codNotaEntrega,
      codCliente: codCliente ?? this.codCliente,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      fecha: fecha ?? this.fecha,
      direccion: direccion ?? this.direccion,
      zona: zona ?? this.zona,
      nit: nit ?? this.nit,
      codEmpleado: codEmpleado ?? this.codEmpleado,
      estado: estado ?? this.estado,
      estadoTexto: estadoTexto ?? this.estadoTexto,
      audUsuario: audUsuario ?? this.audUsuario,
      nombreEmpleado: nombreEmpleado ?? this.nombreEmpleado,
    );
  }
}
