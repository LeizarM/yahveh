import '../../domain/entities/familia_entity.dart';

/// Model de Familia que extiende la entidad
class FamiliaModel extends FamiliaEntity {
  FamiliaModel({
    required super.codFamilia,
    required super.familia,
    required super.audUsuario,
  });

  /// Crear FamiliaModel desde JSON
  factory FamiliaModel.fromJson(Map<String, dynamic> json) => FamiliaModel(
    codFamilia: json["codFamilia"] as int,
    familia: json["familia"] as String,
    audUsuario: json["audUsuario"] as int? ?? 0,
  );

  /// Convertir FamiliaModel a JSON completo
  Map<String, dynamic> toJson() => {
    "codFamilia": codFamilia,
    "familia": familia,
    "audUsuario": audUsuario,
  };

  /// Convertir a JSON para crear (sin codFamilia)
  Map<String, dynamic> toCreateJson() => {
    "familia": familia,
    "audUsuario": audUsuario,
  };

  /// Convertir a JSON para actualizar (con codFamilia)
  Map<String, dynamic> toUpdateJson() => {
    "codFamilia": codFamilia,
    "familia": familia,
    "audUsuario": audUsuario,
  };
}
