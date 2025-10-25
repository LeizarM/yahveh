class ClienteEntity {
    int codCliente;
    int codZona;
    String nit;
    String razonSocial;
    String nombreCliente;
    String direccion;
    String referencia;
    String obs;
    int audUsuario;

    ClienteEntity({
        required this.codCliente,
        required this.codZona,
        required this.nit,
        required this.razonSocial,
        required this.nombreCliente,
        required this.direccion,
        required this.referencia,
        required this.obs,
        required this.audUsuario,
    });

}
