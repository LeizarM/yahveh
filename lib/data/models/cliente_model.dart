import 'dart:convert';
import '../../domain/entities/cliente_entity.dart';

ClienteModel clienteModelFromJson(String str) => ClienteModel.fromJson(json.decode(str));

String clienteModelToJson(ClienteModel data) => json.encode(data.toJson());

class ClienteModel extends ClienteEntity {
  final String? zonaNombre; // Para mostrar en el UI
  final String? ciudadNombre; // Para mostrar en el UI
  final String? paisNombre; // Para mostrar en el UI

  ClienteModel({
    required super.codCliente,
    required super.codZona,
    required super.nit,
    required super.razonSocial,
    required super.nombreCliente,
    required super.direccion,
    required super.referencia,
    required super.obs,
    required super.audUsuario,
    this.zonaNombre,
    this.ciudadNombre,
    this.paisNombre,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        codCliente: json["codCliente"],
        codZona: json["codZona"],
        nit: json["nit"],
        razonSocial: json["razonSocial"],
        nombreCliente: json["nombreCliente"],
        direccion: json["direccion"],
        referencia: json["referencia"],
        obs: json["obs"],
        audUsuario: json["audUsuario"],
        zonaNombre: json["zonaNombre"] ?? json["zona"],
        ciudadNombre: json["ciudadNombre"] ?? json["ciudad"],
        paisNombre: json["paisNombre"] ?? json["pais"],
      );

  Map<String, dynamic> toJson() => {
        "codCliente": codCliente,
        "codZona": codZona,
        "nit": nit,
        "razonSocial": razonSocial,
        "nombreCliente": nombreCliente,
        "direccion": direccion,
        "referencia": referencia,
        "obs": obs,
        "audUsuario": audUsuario,
        if (zonaNombre != null) "zonaNombre": zonaNombre,
        if (ciudadNombre != null) "ciudadNombre": ciudadNombre,
        if (paisNombre != null) "paisNombre": paisNombre,
      };

  Map<String, dynamic> toCreateJson() => {
        "codZona": codZona,
        "nit": nit,
        "razonSocial": razonSocial,
        "nombreCliente": nombreCliente,
        "direccion": direccion,
        "referencia": referencia,
        "obs": obs,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toUpdateJson() => {
        "codCliente": codCliente,
        "codZona": codZona,
        "nit": nit,
        "razonSocial": razonSocial,
        "nombreCliente": nombreCliente,
        "direccion": direccion,
        "referencia": referencia,
        "obs": obs,
        "audUsuario": audUsuario,
      };
}
