import '../../domain/entities/linea_entity.dart';

/// Model de Línea que extiende la entidad
class LineaModel extends LineaEntity {
  const LineaModel({
    super.codLinea,
    required super.linea,
    required super.audUsuario,
    super.audFecha,
    super.totalArticulos,
    super.articulosActivos,
  });

  /// Crear LineaModel desde JSON
  factory LineaModel.fromJson(Map<String, dynamic> json) {
    return LineaModel(
      codLinea: json['codLinea'] as int?,
      linea: json['linea'] as String,
      audUsuario: json['audUsuario'] as int? ?? 0,
      audFecha: json['audFecha'] != null 
          ? DateTime.parse(json['audFecha'] as String)
          : null,
      totalArticulos: json['totalArticulos'] as int?,
      articulosActivos: json['articulos_activos'] as int?,
    );
  }

  /// Convertir LineaModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'codLinea': codLinea,
      'linea': linea,
      'audUsuario': audUsuario,
      'audFecha': audFecha?.toIso8601String(),
      'totalArticulos': totalArticulos,
      'articulos_activos': articulosActivos,
    };
  }

  /// Convertir a JSON para crear (sin codLinea y audFecha)
  Map<String, dynamic> toCreateJson() {
    return {
      'linea': linea,
      'audUsuario': audUsuario,
    };
  }
}
