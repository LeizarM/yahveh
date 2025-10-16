import '../../domain/entities/user_entity.dart';

/// Modelo de Usuario para la capa de datos
class UserModel extends UserEntity {
  const UserModel({
    required super.codUsuario,
    required super.nombreCompleto,
    required super.tipoUsuario,
    required super.token,
  });

  /// Crea un UserModel desde JSON de la API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      codUsuario: json['codUsuario'] as int,
      nombreCompleto: json['nombreCompleto'] as String,
      tipoUsuario: json['tipoUsuario'] as String,
      token: json['token'] as String,
    );
  }

  /// Convierte el UserModel a JSON para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'codUsuario': codUsuario,
      'nombreCompleto': nombreCompleto,
      'tipoUsuario': tipoUsuario,
      'token': token,
    };
  }

  /// Crea una copia con campos modificados
  UserModel copyWith({
    int? codUsuario,
    String? nombreCompleto,
    String? tipoUsuario,
    String? token,
  }) {
    return UserModel(
      codUsuario: codUsuario ?? this.codUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      token: token ?? this.token,
    );
  }
}
