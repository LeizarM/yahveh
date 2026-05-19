import 'dart:typed_data';
import '../entities/venta_reporte_entity.dart';

/// Repository abstracto para el reporte de ventas
abstract class ReporteVentasRepository {
  /// Obtiene los datos del reporte de ventas entre fechas
  Future<List<VentaReporteEntity>> obtenerReporteVentas({
    required String fechaDesde,
    required String fechaHasta,
  });

  /// Descarga el reporte de ventas en formato PDF
  Future<Uint8List> descargarReportePdf({
    required String fechaDesde,
    required String fechaHasta,
  });

  Future<Uint8List> descargarVendedoresPdf({
    required String fechaDesde,
    required String fechaHasta,
  });

  Future<Uint8List> descargarInventarioPdf({
    required String fechaDesde,
    required String fechaHasta,
  });
}
