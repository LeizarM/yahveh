import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/vista_remote_datasource.dart';
import '../../data/datasources/linea_remote_datasource.dart';
import '../../data/datasources/articulo_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/vista_repository_impl.dart';
import '../../data/repositories/linea_repository_impl.dart';
import '../../data/repositories/articulo_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/vista_repository.dart';
import '../../domain/repositories/linea_repository.dart';
import '../../domain/repositories/articulo_repository.dart';
import 'auth_provider.dart';

/// Provider para FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider para Logger
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// Provider para DioClient con callback de logout
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  
  return DioClient(
    storage: storage,
    logger: logger,
    // Cuando el token expira, refrescar el estado de autenticación
    onUnauthorized: () {
      // Usar Future.microtask para evitar modificar el estado durante build
      Future.microtask(() {
        ref.read(authProvider.notifier).refresh();
      });
    },
  );
});

/// Provider para AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(client);
});

/// Provider para AuthLocalDataSource
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(storage);
});

/// Provider para AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Provider para VistaRemoteDataSource
final vistaRemoteDataSourceProvider = Provider<VistaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return VistaRemoteDataSourceImpl(client);
});

/// Provider para VistaRepository
final vistaRepositoryProvider = Provider<VistaRepository>((ref) {
  final remoteDataSource = ref.watch(vistaRemoteDataSourceProvider);
  
  return VistaRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Provider para LineaRemoteDataSource
final lineaRemoteDataSourceProvider = Provider<LineaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return LineaRemoteDataSourceImpl(client);
});

/// Provider para LineaRepository
final lineaRepositoryProvider = Provider<LineaRepository>((ref) {
  final remoteDataSource = ref.watch(lineaRemoteDataSourceProvider);
  
  return LineaRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Provider para ArticuloRemoteDataSource
final articuloRemoteDataSourceProvider = Provider<ArticuloRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ArticuloRemoteDataSourceImpl(client);
});

/// Provider para ArticuloRepository
final articuloRepositoryProvider = Provider<ArticuloRepository>((ref) {
  final remoteDataSource = ref.watch(articuloRemoteDataSourceProvider);
  
  return ArticuloRepositoryImpl(remoteDataSource);
});
