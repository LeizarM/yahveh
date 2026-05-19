import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/vista_remote_datasource.dart';
import '../../data/datasources/linea_remote_datasource.dart';
import '../../data/datasources/articulo_remote_datasource.dart';
import '../../data/datasources/pais_remote_datasource.dart';
import '../../data/datasources/ciudad_remote_datasource.dart';
import '../../data/datasources/zona_remote_datasource.dart';
import '../../data/datasources/cliente_remote_datasource.dart';
import '../../data/datasources/familia_remote_datasource.dart';
import '../../data/datasources/precio_remote_datasource.dart';
import '../../data/datasources/inventario_remote_datasource.dart';
import '../../data/datasources/nota_entrega_remote_datasource.dart';
import '../../data/datasources/detalle_nota_entrega_remote_datasource.dart';
import '../../data/datasources/usuario_remote_datasource.dart';
import '../../data/datasources/persona_remote_datasource.dart';
import '../../data/datasources/empleado_remote_datasource.dart';
import '../../data/datasources/telefono_cliente_remote_datasource.dart';
import '../../data/datasources/reporte_ventas_remote_datasource.dart';
import '../../data/datasources/regla_descuento_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/vista_repository_impl.dart';
import '../../data/repositories/linea_repository_impl.dart';
import '../../data/repositories/articulo_repository_impl.dart';
import '../../data/repositories/pais_repository_impl.dart';
import '../../data/repositories/ciudad_repository_impl.dart';
import '../../data/repositories/zona_repository_impl.dart';
import '../../data/repositories/cliente_repository_impl.dart';
import '../../data/repositories/familia_repository_impl.dart';
import '../../data/repositories/precio_repository_impl.dart';
import '../../data/repositories/inventario_repository_impl.dart';
import '../../data/repositories/nota_entrega_repository_impl.dart';
import '../../data/repositories/detalle_nota_entrega_repository_impl.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../data/repositories/persona_repository_impl.dart';
import '../../data/repositories/empleado_repository_impl.dart';
import '../../data/repositories/telefono_cliente_repository_impl.dart';
import '../../data/repositories/reporte_ventas_repository_impl.dart';
import '../../data/repositories/regla_descuento_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/vista_repository.dart';
import '../../domain/repositories/linea_repository.dart';
import '../../domain/repositories/articulo_repository.dart';
import '../../domain/repositories/pais_repository.dart';
import '../../domain/repositories/ciudad_repository.dart';
import '../../domain/repositories/zona_repository.dart';
import '../../domain/repositories/cliente_repository.dart';
import '../../domain/repositories/familia_repository.dart';
import '../../domain/repositories/precio_repository.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../../domain/repositories/nota_entrega_repository.dart';
import '../../domain/repositories/detalle_nota_entrega_repository.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../domain/repositories/persona_repository.dart';
import '../../domain/repositories/empleado_repository.dart';
import '../../domain/repositories/telefono_cliente_repository.dart';
import '../../domain/repositories/reporte_ventas_repository.dart';
import '../../domain/repositories/regla_descuento_repository.dart';
import '../../domain/entities/inventario_entity.dart';
import '../../domain/entities/regla_descuento_entity.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/entities/persona_entity.dart';
import '../../domain/entities/empleado_entity.dart';
import '../../domain/entities/telefono_cliente_entity.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../domain/entities/detalle_nota_entrega_entity.dart';
import 'auth_provider.dart';
import 'permisos_provider.dart';
import 'inventario_provider.dart';
import 'nota_entrega_provider.dart';
import 'detalle_nota_entrega_provider.dart';
import 'usuario_provider.dart';
import 'persona_provider.dart';
import 'empleado_provider.dart';
import 'telefono_cliente_provider.dart';
import 'regla_descuento_provider.dart';

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
    // Cuando el token expira, hacer logout completo
    onUnauthorized: () {
      // Usar Future.microtask para evitar modificar el estado durante build
      Future.microtask(() async {
        // Hacer logout para limpiar estado y redirigir automáticamente
        await ref.read(authProvider.notifier).logout();
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

  return VistaRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para LineaRemoteDataSource
final lineaRemoteDataSourceProvider = Provider<LineaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return LineaRemoteDataSourceImpl(client);
});

/// Provider para LineaRepository
final lineaRepositoryProvider = Provider<LineaRepository>((ref) {
  final remoteDataSource = ref.watch(lineaRemoteDataSourceProvider);

  return LineaRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para ArticuloRemoteDataSource
final articuloRemoteDataSourceProvider = Provider<ArticuloRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return ArticuloRemoteDataSourceImpl(client);
});

/// Provider para ArticuloRepository
final articuloRepositoryProvider = Provider<ArticuloRepository>((ref) {
  final remoteDataSource = ref.watch(articuloRemoteDataSourceProvider);

  return ArticuloRepositoryImpl(remoteDataSource);
});

// ============================================================================
// PAÍS
// ============================================================================

/// Provider para PaisRemoteDataSource
final paisRemoteDataSourceProvider = Provider<PaisRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return PaisRemoteDataSourceImpl(client);
});

/// Provider para PaisRepository
final paisRepositoryProvider = Provider<PaisRepository>((ref) {
  final remoteDataSource = ref.watch(paisRemoteDataSourceProvider);

  return PaisRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// CIUDAD
// ============================================================================

/// Provider para CiudadRemoteDataSource
final ciudadRemoteDataSourceProvider = Provider<CiudadRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return CiudadRemoteDataSourceImpl(client);
});

/// Provider para CiudadRepository
final ciudadRepositoryProvider = Provider<CiudadRepository>((ref) {
  final remoteDataSource = ref.watch(ciudadRemoteDataSourceProvider);

  return CiudadRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// ZONA
// ============================================================================

/// Provider para ZonaRemoteDataSource
final zonaRemoteDataSourceProvider = Provider<ZonaRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ZonaRemoteDataSourceImpl(client);
});

/// Provider para ZonaRepository
final zonaRepositoryProvider = Provider<ZonaRepository>((ref) {
  final remoteDataSource = ref.watch(zonaRemoteDataSourceProvider);

  return ZonaRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// CLIENTE
// ============================================================================

/// Provider para ClienteRemoteDataSource
final clienteRemoteDataSourceProvider = Provider<ClienteRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return ClienteRemoteDataSourceImpl(client);
});

/// Provider para ClienteRepository
final clienteRepositoryProvider = Provider<ClienteRepository>((ref) {
  final remoteDataSource = ref.watch(clienteRemoteDataSourceProvider);

  return ClienteRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// FAMILIA
// ============================================================================

/// Provider para FamiliaRemoteDataSource
final familiaRemoteDataSourceProvider = Provider<FamiliaRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return FamiliaRemoteDataSourceImpl(client);
});

/// Provider para FamiliaRepository
final familiaRepositoryProvider = Provider<FamiliaRepository>((ref) {
  final remoteDataSource = ref.watch(familiaRemoteDataSourceProvider);

  return FamiliaRepositoryImpl(remoteDataSource);
});

// ============================================================================
// PRECIO
// ============================================================================

/// Provider para PrecioRemoteDataSource
final precioRemoteDataSourceProvider = Provider<PrecioRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return PrecioRemoteDataSourceImpl(client);
});

/// Provider para PrecioRepository
final precioRepositoryProvider = Provider<PrecioRepository>((ref) {
  final remoteDataSource = ref.watch(precioRemoteDataSourceProvider);

  return PrecioRepositoryImpl(remoteDataSource);
});

// ============================================================================
// INVENTARIO
// ============================================================================

/// Provider para InventarioRemoteDataSource
final inventarioRemoteDataSourceProvider = Provider<InventarioRemoteDataSource>(
  (ref) {
    final client = ref.watch(dioClientProvider);
    return InventarioRemoteDataSourceImpl(client);
  },
);

/// Provider para InventarioRepository
final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  final remoteDataSource = ref.watch(inventarioRemoteDataSourceProvider);

  return InventarioRepositoryImpl(remoteDataSource);
});

/// Provider para InventarioNotifier
final inventarioProvider =
    NotifierProvider<InventarioNotifier, AsyncValue<List<InventarioEntity>>>(
      () {
        return InventarioNotifier();
      },
    );

// ============================================================================
// NOTA ENTREGA
// ============================================================================

/// Provider para NotaEntregaRemoteDataSource
final notaEntregaRemoteDataSourceProvider =
    Provider<NotaEntregaRemoteDataSource>((ref) {
      final client = ref.watch(dioClientProvider);
      return NotaEntregaRemoteDataSource(dioClient: client);
    });

/// Provider para NotaEntregaRepository
final notaEntregaRepositoryProvider = Provider<NotaEntregaRepository>((ref) {
  final remoteDataSource = ref.watch(notaEntregaRemoteDataSourceProvider);

  return NotaEntregaRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para NotaEntregaNotifier
final notaEntregaProvider =
    NotifierProvider<NotaEntregaNotifier, AsyncValue<List<NotaEntregaEntity>>>(
      () {
        return NotaEntregaNotifier();
      },
    );

// ============================================================================
// DETALLE NOTA ENTREGA
// ============================================================================

/// Provider para DetalleNotaEntregaRemoteDataSource
final detalleNotaEntregaRemoteDataSourceProvider =
    Provider<DetalleNotaEntregaRemoteDataSource>((ref) {
      final client = ref.watch(dioClientProvider);
      return DetalleNotaEntregaRemoteDataSource(dioClient: client);
    });

/// Provider para DetalleNotaEntregaRepository
final detalleNotaEntregaRepositoryProvider =
    Provider<DetalleNotaEntregaRepository>((ref) {
      final remoteDataSource = ref.watch(
        detalleNotaEntregaRemoteDataSourceProvider,
      );

      return DetalleNotaEntregaRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

/// Provider para DetalleNotaEntregaNotifier
final detalleNotaEntregaProvider =
    NotifierProvider<
      DetalleNotaEntregaNotifier,
      AsyncValue<List<DetalleNotaEntregaEntity>>
    >(() {
      return DetalleNotaEntregaNotifier();
    });

// ============================================================================
// USUARIO
// ============================================================================

/// Provider para UsuarioRemoteDataSource
final usuarioRemoteDataSourceProvider = Provider<UsuarioRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return UsuarioRemoteDataSource(dioClient: client);
});

/// Provider para UsuarioRepository
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  final remoteDataSource = ref.watch(usuarioRemoteDataSourceProvider);

  return UsuarioRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para UsuarioNotifier
final usuarioProvider =
    NotifierProvider<UsuarioNotifier, AsyncValue<List<UsuarioEntity>>>(() {
      return UsuarioNotifier();
    });

// ============================================================================
// PERSONA
// ============================================================================

/// Provider para PersonaRemoteDataSource
final personaRemoteDataSourceProvider = Provider<PersonaRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return PersonaRemoteDataSource(dioClient: client);
});

/// Provider para PersonaRepository
final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  final remoteDataSource = ref.watch(personaRemoteDataSourceProvider);

  return PersonaRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para PersonaNotifier
final personaProvider =
    NotifierProvider<PersonaNotifier, AsyncValue<List<PersonaEntity>>>(() {
      return PersonaNotifier();
    });

// ============================================================================
// EMPLEADO
// ============================================================================

/// Provider para EmpleadoRemoteDataSource
final empleadoRemoteDataSourceProvider = Provider<EmpleadoRemoteDataSource>((
  ref,
) {
  final client = ref.watch(dioClientProvider);
  return EmpleadoRemoteDataSource(dioClient: client);
});

/// Provider para EmpleadoRepository
final empleadoRepositoryProvider = Provider<EmpleadoRepository>((ref) {
  final remoteDataSource = ref.watch(empleadoRemoteDataSourceProvider);

  return EmpleadoRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para EmpleadoNotifier
final empleadoProvider =
    NotifierProvider<EmpleadoNotifier, AsyncValue<List<EmpleadoEntity>>>(() {
      return EmpleadoNotifier();
    });

// ============================================================================
// TELÉFONO CLIENTE
// ============================================================================

/// Provider para TelefonoClienteRemoteDataSource
final telefonoClienteRemoteDataSourceProvider =
    Provider<TelefonoClienteRemoteDataSource>((ref) {
      final client = ref.watch(dioClientProvider);
      return TelefonoClienteRemoteDataSource(dioClient: client);
    });

/// Provider para TelefonoClienteRepository
final telefonoClienteRepositoryProvider = Provider<TelefonoClienteRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(telefonoClienteRemoteDataSourceProvider);

  return TelefonoClienteRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider para TelefonoClienteNotifier
final telefonoClienteProvider =
    NotifierProvider<
      TelefonoClienteNotifier,
      AsyncValue<List<TelefonoClienteEntity>>
    >(() {
      return TelefonoClienteNotifier();
    });

// ============================================================================
// REPORTE DE VENTAS
// ============================================================================

/// Provider para ReporteVentasRemoteDataSource
final reporteVentasRemoteDataSourceProvider =
    Provider<ReporteVentasRemoteDataSource>((ref) {
      final client = ref.watch(dioClientProvider);
      return ReporteVentasRemoteDataSource(dioClient: client);
    });

/// Provider para ReporteVentasRepository
final reporteVentasRepositoryProvider = Provider<ReporteVentasRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(reporteVentasRemoteDataSourceProvider);

  return ReporteVentasRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ============================================================================
// REGLA DESCUENTO
// ============================================================================

final reglaDescuentoRemoteDataSourceProvider =
    Provider<ReglaDescuentoRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ReglaDescuentoRemoteDataSourceImpl(client);
});

final reglaDescuentoRepositoryProvider = Provider<ReglaDescuentoRepository>((ref) {
  final remote = ref.watch(reglaDescuentoRemoteDataSourceProvider);
  return ReglaDescuentoRepositoryImpl(remote);
});

final reglaDescuentoProvider =
    NotifierProvider<ReglaDescuentoNotifier, AsyncValue<List<ReglaDescuentoEntity>>>(
  () => ReglaDescuentoNotifier(),
);

/// FutureProvider.family para obtener la regla de un artículo puntual
final reglaDescuentoPorArticuloProvider =
    FutureProvider.family<ReglaDescuentoEntity?, String>((ref, codArticulo) async {
  final repo = ref.read(reglaDescuentoRepositoryProvider);
  return await repo.buscarPorArticulo(codArticulo);
});
