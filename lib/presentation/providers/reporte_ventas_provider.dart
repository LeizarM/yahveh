
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/venta_reporte_entity.dart';
import 'providers.dart';

/// Estado del reporte de ventas
class ReporteVentasState {
  final List<VentaReporteEntity> ventas;
  final bool isLoading;
  final String? error;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  const ReporteVentasState({
    this.ventas = const [],
    this.isLoading = false,
    this.error,
    this.fechaDesde,
    this.fechaHasta,
  });

  /// Obtiene solo las filas de detalle
  List<VentaReporteEntity> get detalles =>
      ventas.where((v) => v.isDetalle).toList();

  /// Obtiene la fila de total si existe
  VentaReporteEntity? get total => ventas.where((v) => v.isTotal).firstOrNull;

  /// Verifica si hay datos
  bool get hasData => ventas.isNotEmpty;

  ReporteVentasState copyWith({
    List<VentaReporteEntity>? ventas,
    bool? isLoading,
    String? error,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) {
    return ReporteVentasState(
      ventas: ventas ?? this.ventas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      fechaDesde: fechaDesde ?? this.fechaDesde,
      fechaHasta: fechaHasta ?? this.fechaHasta,
    );
  }
}

/// Notifier para el reporte de ventas
class ReporteVentasNotifier extends Notifier<ReporteVentasState> {
  @override
  ReporteVentasState build() {
    return const ReporteVentasState();
  }

  /// Obtiene el reporte de ventas entre fechas
  Future<void> obtenerReporte({
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
    );

    try {
      final repository = ref.read(reporteVentasRepositoryProvider);

      final fechaDesdeStr = _formatDate(fechaDesde);
      final fechaHastaStr = _formatDate(fechaHasta);

      debugPrint('📊 Obteniendo reporte: $fechaDesdeStr - $fechaHastaStr');

      final ventas = await repository.obtenerReporteVentas(
        fechaDesde: fechaDesdeStr,
        fechaHasta: fechaHastaStr,
      );

      debugPrint('✅ Reporte obtenido: ${ventas.length} registros');

      state = state.copyWith(ventas: ventas, isLoading: false);
    } catch (e) {
      debugPrint('❌ Error al obtener reporte: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Descarga el reporte en PDF
  Future<Uint8List?> descargarPdf() async {
    if (state.fechaDesde == null || state.fechaHasta == null) {
      debugPrint('❌ No hay fechas seleccionadas para descargar PDF');
      return null;
    }

    try {
      final repository = ref.read(reporteVentasRepositoryProvider);

      final fechaDesdeStr = _formatDate(state.fechaDesde!);
      final fechaHastaStr = _formatDate(state.fechaHasta!);

      debugPrint('📥 Descargando PDF: $fechaDesdeStr - $fechaHastaStr');

      final pdfBytes = await repository.descargarReportePdf(
        fechaDesde: fechaDesdeStr,
        fechaHasta: fechaHastaStr,
      );

      debugPrint('✅ PDF descargado: ${pdfBytes.length} bytes');
      return pdfBytes;
    } catch (e) {
      debugPrint('❌ Error al descargar PDF: $e');
      state = state.copyWith(error: 'Error al descargar PDF: $e');
      return null;
    }
  }

  /// Limpia el reporte
  void limpiar() {
    state = const ReporteVentasState();
  }

  /// Formatea una fecha a string YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Provider para el reporte de ventas
final reporteVentasProvider =
    NotifierProvider<ReporteVentasNotifier, ReporteVentasState>(() {
      return ReporteVentasNotifier();
    });
