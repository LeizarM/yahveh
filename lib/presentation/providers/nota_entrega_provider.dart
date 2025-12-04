import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/nota_entrega_entity.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import 'providers.dart';

/// Enum para los tipos de filtro de notas
enum NotaFiltroTipo {
  validas,
  anuladas,
  todas,
}

/// Notifier del proveedor de notas de entrega
class NotaEntregaNotifier extends Notifier<AsyncValue<List<NotaEntregaEntity>>> {
  /// Filtro actual aplicado
  NotaFiltroTipo _filtroActual = NotaFiltroTipo.validas;
  
  /// Obtener el filtro actual
  NotaFiltroTipo get filtroActual => _filtroActual;

  @override
  AsyncValue<List<NotaEntregaEntity>> build() {
    return const AsyncValue.data([]);
  }

  /// Cargar notas de entrega válidas (por defecto)
  Future<void> cargarNotas() async {
    _filtroActual = NotaFiltroTipo.validas;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listar();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas de entrega', st);
    }
  }

  /// Cargar todas las notas (válidas y anuladas)
  Future<void> cargarTodasLasNotas() async {
    _filtroActual = NotaFiltroTipo.todas;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarTodas();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar todas las notas', st);
    }
  }

  /// Cargar solo notas anuladas
  Future<void> cargarNotasAnuladas() async {
    _filtroActual = NotaFiltroTipo.anuladas;
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarAnuladas();
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas anuladas', st);
    }
  }

  /// Cargar notas por cliente
  Future<void> cargarNotasPorCliente(int codCliente) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarPorCliente(codCliente);
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas del cliente', st);
    }
  }

  /// Cargar notas por rango de fechas
  Future<void> cargarNotasPorFechas({DateTime? fechaInicio, DateTime? fechaFin}) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.listarPorFechas(
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
      state = AsyncValue.data(result.data);
    } on ApiException catch (e, st) {
      state = AsyncValue.error(e.message, st);
    } catch (e, st) {
      state = AsyncValue.error('Error inesperado al cargar notas por fechas', st);
    }
  }

  /// Buscar nota por código
  Future<NotaEntregaEntity?> buscarPorCodigo(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.buscarPorCodigo(codNotaEntrega);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al buscar nota', statusCode: 500);
    }
  }

  /// Crear nueva nota de entrega
  Future<OperationResult<NotaEntregaEntity>?> crear(NotaEntregaEntity notaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.crear(notaEntrega);
      
      // Recargar lista de notas según el filtro actual
      await _recargarSegunFiltro();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al crear nota de entrega', statusCode: 500);
    }
  }

  /// Actualizar nota de entrega existente
  Future<OperationResult<NotaEntregaEntity>?> actualizar(
    int codNotaEntrega,
    NotaEntregaEntity notaEntrega,
  ) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.actualizar(codNotaEntrega, notaEntrega);
      
      // Recargar lista de notas según el filtro actual
      await _recargarSegunFiltro();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al actualizar nota', statusCode: 500);
    }
  }

  /// Anular nota de entrega (devuelve stock automáticamente)
  Future<OperationResult<NotaEntregaEntity>?> anular(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.anular(codNotaEntrega);
      
      // Recargar lista de notas según el filtro actual
      await _recargarSegunFiltro();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al anular nota', statusCode: 500);
    }
  }

  /// Eliminar nota de entrega
  Future<OperationResult<void>?> eliminar(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.eliminar(codNotaEntrega);
      
      // Recargar lista de notas según el filtro actual
      await _recargarSegunFiltro();
      
      return result;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al eliminar nota', statusCode: 500);
    }
  }

  /// Generar PDF de una nota de entrega
  Future<Uint8List?> generarPDF(int codNotaEntrega) async {
    try {
      final repository = ref.read(notaEntregaRepositoryProvider);
      final result = await repository.generarPDF(codNotaEntrega);
      return result.data;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Error inesperado al generar PDF', statusCode: 500);
    }
  }

  /// Recargar notas según el filtro actual
  Future<void> _recargarSegunFiltro() async {
    switch (_filtroActual) {
      case NotaFiltroTipo.validas:
        await cargarNotas();
        break;
      case NotaFiltroTipo.anuladas:
        await cargarNotasAnuladas();
        break;
      case NotaFiltroTipo.todas:
        await cargarTodasLasNotas();
        break;
    }
  }
}
