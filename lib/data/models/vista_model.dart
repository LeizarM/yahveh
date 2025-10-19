import '../../domain/entities/vista_entity.dart';

class VistaModel extends VistaEntity {
  VistaModel({
    required super.codVista,
    required super.codVistaPadre,
    required super.direccion,
    required super.titulo,
    required super.audUsuario,
  });

  factory VistaModel.fromJson(Map<String, dynamic> json) => VistaModel(
    codVista: json["codVista"],
    codVistaPadre: json["codVistaPadre"],
    direccion: json["direccion"],
    titulo: json["titulo"],
    audUsuario: json["audUsuario"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "codVista": codVista,
    "codVistaPadre": codVistaPadre,
    "direccion": direccion,
    "titulo": titulo,
    "audUsuario": audUsuario,
  };
}
