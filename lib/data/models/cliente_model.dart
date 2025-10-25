// To parse this JSON data, do
//
//     final clienteModel = clienteModelFromJson(jsonString);

import 'dart:convert';

ClienteModel clienteModelFromJson(String str) => ClienteModel.fromJson(json.decode(str));

String clienteModelToJson(ClienteModel data) => json.encode(data.toJson());

class ClienteModel {
    int codCliente;
    int codZona;
    String nit;
    String razonSocial;
    String nombreCliente;
    String direccion;
    String referencia;
    String obs;
    int audUsuario;

    ClienteModel({
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
    };
}
