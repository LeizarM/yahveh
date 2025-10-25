import 'dart:convert';
import '../../domain/entities/pais_entity.dart';

PaisModel paisModelFromJson(String str) => PaisModel.fromJson(json.decode(str));

String paisModelToJson(PaisModel data) => json.encode(data.toJson());

class PaisModel extends PaisEntity {
  PaisModel({
    required super.codPais,
    required super.pais,
    required super.audUsuario,
  });

  factory PaisModel.fromJson(Map<String, dynamic> json) => PaisModel(
        codPais: json["codPais"],
        pais: json["pais"],
        audUsuario: json["audUsuario"],
      );

  Map<String, dynamic> toJson() => {
        "codPais": codPais,
        "pais": pais,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toCreateJson() => {
        "pais": pais,
        "audUsuario": audUsuario,
      };

  Map<String, dynamic> toUpdateJson() => {
        "codPais": codPais,
        "pais": pais,
        "audUsuario": audUsuario,
      };
}
