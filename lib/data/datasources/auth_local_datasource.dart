import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Interface para la fuente de datos local de autenticación
abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel> getUser();
  Future<void> deleteUser();
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

/// Implementación de la fuente de datos local de autenticación
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await storage.write(key: AppConfig.userKey, value: userJson);
    } catch (e) {
      throw CacheException('Error al guardar usuario: $e');
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final userJson = await storage.read(key: AppConfig.userKey);
      if (userJson == null) {
        throw CacheException('No hay usuario guardado');
      }
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException('Error al obtener usuario: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await storage.delete(key: AppConfig.userKey);
    } catch (e) {
      throw CacheException('Error al eliminar usuario: $e');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await storage.write(key: AppConfig.tokenKey, value: token);
    } catch (e) {
      throw CacheException('Error al guardar token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await storage.read(key: AppConfig.tokenKey);
    } catch (e) {
      throw CacheException('Error al obtener token: $e');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await storage.delete(key: AppConfig.tokenKey);
    } catch (e) {
      throw CacheException('Error al eliminar token: $e');
    }
  }
}
