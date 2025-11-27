/// Entidad de Teléfono de Cliente
class TelefonoClienteEntity {
  final int codTlfCliente;
  final int codCliente;
  final String telefono;
  final int audUsuario;

  TelefonoClienteEntity({
    required this.codTlfCliente,
    required this.codCliente,
    required this.telefono,
    required this.audUsuario,
  });

  TelefonoClienteEntity copyWith({
    int? codTlfCliente,
    int? codCliente,
    String? telefono,
    int? audUsuario,
  }) {
    return TelefonoClienteEntity(
      codTlfCliente: codTlfCliente ?? this.codTlfCliente,
      codCliente: codCliente ?? this.codCliente,
      telefono: telefono ?? this.telefono,
      audUsuario: audUsuario ?? this.audUsuario,
    );
  }
}
