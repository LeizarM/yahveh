import '../../domain/entities/regla_descuento_entity.dart';

class ReglaDescuentoModel extends ReglaDescuentoEntity {
  ReglaDescuentoModel({
    required super.codReglaDescuento,
    required super.codArticulo,
    required super.descripcionArticulo,
    required super.cantidadMinima,
    required super.descuento,
    required super.audUsuario,
  });

  factory ReglaDescuentoModel.fromJson(Map<String, dynamic> json) =>
      ReglaDescuentoModel(
        codReglaDescuento: json['codReglaDescuento'] ?? 0,
        codArticulo: json['codArticulo'] ?? '',
        descripcionArticulo: json['descripcionArticulo'] ?? '',
        cantidadMinima: json['cantidadMinima'] ?? 0,
        descuento: json['descuento']?.toDouble() ?? 0.0,
        audUsuario: json['audUsuario'] ?? 0,
      );

  Map<String, dynamic> toCreateJson() => {
        'codArticulo': codArticulo,
        'cantidadMinima': cantidadMinima,
        'descuento': descuento,
      };

  ReglaDescuentoEntity toEntity() => ReglaDescuentoEntity(
        codReglaDescuento: codReglaDescuento,
        codArticulo: codArticulo,
        descripcionArticulo: descripcionArticulo,
        cantidadMinima: cantidadMinima,
        descuento: descuento,
        audUsuario: audUsuario,
      );
}
