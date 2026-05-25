import 'dart:convert';
import '../../domain/entities/nota_entrega_entity.dart';

NotaEntregaModel notaEntregaModelFromJson(String str) =>
    NotaEntregaModel.fromJson(json.decode(str));

String notaEntregaModelToJson(NotaEntregaModel data) =>
    json.encode(data.toJson());

class NotaEntregaModel extends NotaEntregaEntity {
  NotaEntregaModel({
    required super.codNotaEntrega,
    required super.codCliente,
    required super.nombreCliente,
    required super.fecha,
    required super.direccion,
    required super.zona,
    super.nit = '',
    super.codEmpleado,
    super.estado = 1,
    super.estadoTexto = 'Válido',
    required super.audUsuario,
    super.nombreEmpleado = '',
  });

  factory NotaEntregaModel.fromJson(Map<String, dynamic> json) => NotaEntregaModel(
        codNotaEntrega: json["codNotaEntrega"] ?? 0,
        codCliente: json["codCliente"] ?? 0,
        nombreCliente: json["nombreCliente"] ?? '',
        fecha: json["fecha"] != null
            ? DateTime.parse(json["fecha"])
            : DateTime.now(),
        direccion: json["direccion"] ?? '',
        zona: json["zona"] ?? '',
        nit: json["nit"] ?? '',
        codEmpleado: json["codEmpleado"],
        estado: json["estado"] ?? 1,
        estadoTexto: json["estadoTexto"] ?? 'Válido',
        audUsuario: json["audUsuario"] ?? 0,
        nombreEmpleado: json["nombreEmpleado"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "codNotaEntrega": codNotaEntrega,
        "codCliente": codCliente,
        "nombreCliente": nombreCliente,
        "fecha": "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}",
        "direccion": direccion,
        "zona": zona,
        "nit": nit,
        "codEmpleado": codEmpleado,
        "estado": estado,
        "estadoTexto": estadoTexto,
        "audUsuario": audUsuario,
        "nombreEmpleado": nombreEmpleado,
      };

  Map<String, dynamic> toCreateJson() => {
        "codCliente": codCliente,
        "direccion": direccion,
        "zona": zona,
        "nit": nit,
        if (codEmpleado != null) "codEmpleado": codEmpleado,
      };

  NotaEntregaEntity toEntity() => NotaEntregaEntity(
        codNotaEntrega: codNotaEntrega,
        codCliente: codCliente,
        nombreCliente: nombreCliente,
        fecha: fecha,
        direccion: direccion,
        zona: zona,
        nit: nit,
        codEmpleado: codEmpleado,
        estado: estado,
        estadoTexto: estadoTexto,
        audUsuario: audUsuario,
        nombreEmpleado: nombreEmpleado,
      );
}
