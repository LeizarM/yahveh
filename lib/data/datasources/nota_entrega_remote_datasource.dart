import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../models/nota_entrega_model.dart';
import 'package:yahveh/core/utils/error_messages.dart';

class NotaEntregaRemoteDataSource {
  final DioClient _dioClient;

  NotaEntregaRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  /// GET /api/notas-entrega - Listar solo notas de entrega válidas
  Future<List<NotaEntregaModel>> listar() async {
    try {
      console('📤 Solicitando lista de notas de entrega válidas...');
      
      final response = await _dioClient.get('/notas-entrega');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final notas = dataList.map((json) => NotaEntregaModel.fromJson(json)).toList();
        console('✅ ${notas.length} notas de entrega válidas obtenidas');
        return notas;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar notas de entrega');
      }
    } catch (e) {
      console('❌ Error al listar notas de entrega: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/todas - Listar todas las notas (válidas y anuladas)
  Future<List<NotaEntregaModel>> listarTodas() async {
    try {
      console('📤 Solicitando lista de todas las notas de entrega...');
      
      final response = await _dioClient.get('/notas-entrega/todas');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final notas = dataList.map((json) => NotaEntregaModel.fromJson(json)).toList();
        console('✅ ${notas.length} notas de entrega (todas) obtenidas');
        return notas;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar todas las notas');
      }
    } catch (e) {
      console('❌ Error al listar todas las notas: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/anuladas - Listar solo notas anuladas
  Future<List<NotaEntregaModel>> listarAnuladas() async {
    try {
      console('📤 Solicitando lista de notas anuladas...');
      
      final response = await _dioClient.get('/notas-entrega/anuladas');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final notas = dataList.map((json) => NotaEntregaModel.fromJson(json)).toList();
        console('✅ ${notas.length} notas anuladas obtenidas');
        return notas;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar notas anuladas');
      }
    } catch (e) {
      console('❌ Error al listar notas anuladas: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/{id} - Buscar nota de entrega por código
  Future<NotaEntregaModel> buscarPorCodigo(int codNotaEntrega) async {
    try {
      console('📤 Buscando nota de entrega con código: $codNotaEntrega');
      
      final response = await _dioClient.get('/notas-entrega/$codNotaEntrega');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final nota = NotaEntregaModel.fromJson(response.data['data']);
        console('✅ Nota de entrega encontrada');
        return nota;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Nota de entrega no encontrada');
      }
    } catch (e) {
      console('❌ Error al buscar nota de entrega: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/cliente/{codCliente} - Listar notas por cliente
  Future<List<NotaEntregaModel>> listarPorCliente(int codCliente) async {
    try {
      console('📤 Listando notas de entrega del cliente: $codCliente');
      
      final response = await _dioClient.get('/notas-entrega/cliente/$codCliente');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final notas = dataList.map((json) => NotaEntregaModel.fromJson(json)).toList();
        console('✅ ${notas.length} notas del cliente obtenidas');
        return notas;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar notas del cliente');
      }
    } catch (e) {
      console('❌ Error al listar notas del cliente: $e');
      rethrow;
    }
  }

  /// GET /api/notas-entrega/fechas - Listar por rango de fechas
  Future<List<NotaEntregaModel>> listarPorFechas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      console('📤 Listando notas por fechas: $fechaInicio - $fechaFin');
      
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) {
        queryParams['desde'] = fechaInicio.toIso8601String().split('T')[0];
      }
      if (fechaFin != null) {
        queryParams['hasta'] = fechaFin.toIso8601String().split('T')[0];
      }
      
      final response = await _dioClient.get(
        '/notas-entrega/fechas',
        queryParameters: queryParams,
      );
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        final notas = dataList.map((json) => NotaEntregaModel.fromJson(json)).toList();
        console('✅ ${notas.length} notas encontradas');
        return notas;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al listar notas por fechas');
      }
    } catch (e) {
      console('❌ Error al listar notas por fechas: $e');
      rethrow;
    }
  }

  /// POST /api/notas-entrega - Crear nueva nota de entrega
  Future<NotaEntregaModel> crear(NotaEntregaModel notaEntrega) async {
    try {
      console('📤 Creando nueva nota de entrega...');
      console('📋 Datos: ${notaEntrega.toCreateJson()}');
      
      final response = await _dioClient.post(
        '/notas-entrega',
        data: notaEntrega.toCreateJson(),
      );
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final nota = NotaEntregaModel.fromJson(response.data['data']);
        console('✅ Nota de entrega creada: ${nota.codNotaEntrega}');
        return nota;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al crear nota de entrega');
      }
    } catch (e) {
      console('❌ Error al crear nota de entrega: $e');
      rethrow;
    }
  }

  /// PUT /api/notas-entrega/{id} - Actualizar nota de entrega
  Future<NotaEntregaModel> actualizar(int codNotaEntrega, NotaEntregaModel notaEntrega) async {
    try {
      console('📤 Actualizando nota de entrega: $codNotaEntrega');
      
      final response = await _dioClient.put(
        '/notas-entrega/$codNotaEntrega',
        data: notaEntrega.toCreateJson(),
      );
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final nota = NotaEntregaModel.fromJson(response.data['data']);
        console('✅ Nota de entrega actualizada');
        return nota;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al actualizar nota de entrega');
      }
    } catch (e) {
      console('❌ Error al actualizar nota de entrega: $e');
      rethrow;
    }
  }

  /// PUT /api/notas-entrega/{id}/anular - Anular nota de entrega (devuelve stock automáticamente)
  Future<NotaEntregaModel> anular(int codNotaEntrega) async {
    try {
      console('📤 Anulando nota de entrega: $codNotaEntrega');
      
      final response = await _dioClient.put('/notas-entrega/$codNotaEntrega/anular');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        final nota = NotaEntregaModel.fromJson(response.data['data']);
        console('✅ Nota de entrega anulada - Stock devuelto');
        return nota;
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al anular nota de entrega');
      }
    } catch (e) {
      console('❌ Error al anular nota de entrega: $e');
      rethrow;
    }
  }

  /// DELETE /api/notas-entrega/{id} - Eliminar nota de entrega
  Future<void> eliminar(int codNotaEntrega) async {
    try {
      console('📤 Eliminando nota de entrega: $codNotaEntrega');
      
      final response = await _dioClient.delete('/notas-entrega/$codNotaEntrega');
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.data['success'] == true) {
        console('✅ Nota de entrega eliminada');
      } else {
        throw ApiException(message: response.data['message'] ?? 'Error al eliminar nota de entrega');
      }
    } catch (e) {
      console('❌ Error al eliminar nota de entrega: $e');
      rethrow;
    }
  }

  /// GET /api/reportes/nota-entrega/{codNotaEntrega} - Generar PDF de nota de entrega
  Future<Uint8List> generarPDF(int codNotaEntrega) async {
    try {
      console('📤 Generando PDF de nota de entrega: $codNotaEntrega');
      
      final response = await _dioClient.get(
        '/reportes/nota-entrega/$codNotaEntrega',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'application/pdf',
          },
        ),
      );
      
      console('📥 Respuesta recibida: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data);
        console('✅ PDF generado: ${bytes.length} bytes');
        return bytes;
      } else {
        throw ApiException(message: 'Error al generar PDF de nota de entrega');
      }
    } catch (e) {
      console('❌ Error al generar PDF: $e');
      rethrow;
    }
  }
}
