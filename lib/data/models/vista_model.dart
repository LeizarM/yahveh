import 'dart:convert';

VistaModel vistaModelFromJson(String str) => VistaModel.fromJson(json.decode(str));

String vistaModelToJson(VistaModel data) => json.encode(data.toJson());

class VistaModel {
    int codVista;
    int codVistaPadre;
    String direccion;
    String titulo;
    int audUsuario;

    VistaModel({
        required this.codVista,
        required this.codVistaPadre,
        required this.direccion,
        required this.titulo,
        required this.audUsuario,
    });

    factory VistaModel.fromJson(Map<String, dynamic> json) => VistaModel(
        codVista: json["codVista"],
        codVistaPadre: json["codVistaPadre"],
        direccion: json["direccion"],
        titulo: json["titulo"],
        audUsuario: json["audUsuario"],
    );

    Map<String, dynamic> toJson() => {
        "codVista": codVista,
        "codVistaPadre": codVistaPadre,
        "direccion": direccion,
        "titulo": titulo,
        "audUsuario": audUsuario,
    };
}
