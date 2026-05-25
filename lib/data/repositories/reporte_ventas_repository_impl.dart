import 'dart:typed_data';
import '../../domain/entities/venta_reporte_entity.dart';
import '../../domain/repositories/reporte_ventas_repository.dart';
import '../datasources/reporte_ventas_remote_datasource.dart';

/// Implementación del repository para el reporte de ventas
class ReporteVentasRepositoryImpl implements ReporteVentasRepository {
  final ReporteVentasRemoteDataSource _remoteDataSource;

  ReporteVentasRepositoryImpl({
    required ReporteVentasRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<VentaReporteEntity>> obtenerReporteVentas({
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    final models = await _remoteDataSource.obtenerReporteVentas(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Uint8List> descargarReportePdf({
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    return await _remoteDataSource.descargarReportePdf(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  @override
  Future<Uint8List> descargarVendedoresPdf({
    required String fechaDesde,
    required String fechaHasta,
    int? codEmpleado,
  }) async {
    return await _remoteDataSource.descargarVendedoresPdf(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      codEmpleado: codEmpleado,
    );
  }

  @override
  Future<Uint8List> descargarInventarioPdf({
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    return await _remoteDataSource.descargarInventarioPdf(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );
  }

  @override
  Future<Uint8List> descargarMovimientosInventarioPdf({
    required String fechaDesde,
    required String fechaHasta,
    String? codArticulo,
  }) async {
    return await _remoteDataSource.descargarMovimientosInventarioPdf(
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      codArticulo: codArticulo,
    );
  }
}
