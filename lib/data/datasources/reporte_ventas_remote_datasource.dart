import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/venta_reporte_model.dart';

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
      print('📤 Solicitando reporte de ventas: $fechaDesde - $fechaHasta');

      final response = await _dioClient.get(
        '/notas-entrega/reporte-ventas/$fechaDesde/$fechaHasta',
      );

      print('📥 Respuesta recibida: ${response.statusCode}');

      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final ventas = dataList
            .map((json) => VentaReporteModel.fromJson(json))
            .toList();
        print('✅ ${ventas.length} registros de ventas obtenidos');
        return ventas;
      } else {
        throw ApiException(
          message:
              response.data['message'] ?? 'Error al obtener reporte de ventas',
        );
      }
    } on DioException catch (e) {
      print('❌ Error DioException: ${e.message}');
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw ApiException(message: e.response!.data['message']);
      }
      throw ApiException(message: 'Error de conexión al obtener reporte');
    } catch (e) {
      print('❌ Error al obtener reporte de ventas: $e');
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
      print('📤 Descargando PDF del reporte: $fechaDesde - $fechaHasta');

      final response = await _dioClient.get(
        '/notas-entrega/reporte-ventas/pdf/$fechaDesde/$fechaHasta',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );

      print('📥 PDF recibido: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data);
        print('✅ PDF descargado: ${bytes.length} bytes');
        return bytes;
      } else {
        throw ApiException(message: 'Error al descargar el PDF del reporte');
      }
    } on DioException catch (e) {
      print('❌ Error DioException al descargar PDF: ${e.message}');
      if (e.response?.statusCode == 404) {
        throw ApiException(
          message: 'No se encontraron datos para generar el reporte',
        );
      }
      throw ApiException(message: 'Error de conexión al descargar PDF');
    } catch (e) {
      print('❌ Error al descargar PDF: $e');
      rethrow;
    }
  }
}
