import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/venta_reporte_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';

/// DataSource remoto para el reporte de ventas
class ReporteVentasRemoteDataSource {
  final DioClient _dioClient;

  ReporteVentasRemoteDataSource({required DioClient dioClient})
    : _dioClient = dioClient;

  /// GET /api/notas-entrega/reporte-ventas/{fechaDesde}/{fechaHasta}
  /// Obtiene los datos del reporte de ventas en formato JSON
  Future<List<VentaReporteModel>> obtenerReporteVentas({
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    try {
      console('📤 Solicitando reporte de ventas: $fechaDesde - $fechaHasta');

      final response = await _dioClient.get(
        '/notas-entrega/reporte-ventas/$fechaDesde/$fechaHasta',
      );

      console('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final ventas = dataList
            .map((json) => VentaReporteModel.fromJson(json))
            .toList();
        console('✅ ${ventas.length} registros de ventas obtenidos');
        return ventas;
      } else {
        throw ApiException(
          message:
              response.data['message'] ?? 'Error al obtener reporte de ventas',
        );
      }
    } on DioException catch (e) {
      console('❌ Error DioException: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw ApiException(message: e.response!.data['message']);
      }
      throw ApiException(message: 'Error de conexión al obtener reporte');
    } catch (e) {
      console('❌ Error al obtener reporte de ventas: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/reporte-ventas/pdf/{fechaDesde}/{fechaHasta}
  /// Descarga el reporte de ventas en formato PDF
  Future<Uint8List> descargarReportePdf({
    required String fechaDesde,
    required String fechaHasta,
  }) async {
    try {
      console('📤 Descargando PDF del reporte: $fechaDesde - $fechaHasta');

      final response = await _dioClient.get(
        '/notas-entrega/reporte-ventas/pdf/$fechaDesde/$fechaHasta',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      console('📥 PDF recibido: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        console('✅ PDF descargado: ${bytes.length} bytes');
        return bytes;
      } else {
        throw ApiException(message: 'Error al descargar el PDF del reporte');
      }
    } on DioException catch (e) {
      console('❌ Error DioException al descargar PDF: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'No se encontraron datos para generar el reporte',
        );
      }
      throw ApiException(message: 'Error de conexión al descargar PDF');
    } catch (e) {
      console('❌ Error al descargar PDF: $e');
      rethrow;
    }
  }
}
