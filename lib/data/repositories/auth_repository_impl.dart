import 'package:flutter/foundation.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/jwt_utils.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(username, password);
      await localDataSource.saveUser(user);
      return user;
    } on ServerException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      try {
        await remoteDataSource.logout();
      } catch (e) {
        // Ignorar errores del servidor en logout
      }
      await localDataSource.deleteUser();
      await localDataSource.deleteToken();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await localDataSource.getUser();
    } on CacheException {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await localDataSource.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('🔐 No hay token almacenado');
        return false;
      }

      // Verificar si el token ha expirado
      if (JwtUtils.isTokenExpired(token)) {
        debugPrint('⏰ Token expirado - limpiando sesión');
        // Limpiar datos de sesión si el token expiró
        await localDataSource.deleteUser();
        await localDataSource.deleteToken();
        return false;
      }

      // Log del tiempo restante (solo en debug)
      final timeLeft = JwtUtils.getTimeUntilExpiration(token);
      if (timeLeft != null) {
        debugPrint('Token válido - expira en ${timeLeft.inMinutes} minutos');
      }

      return true;
    } catch (e) {
      debugPrint('Error verificando autenticación: $e');
      return false;
    }
  }
}
