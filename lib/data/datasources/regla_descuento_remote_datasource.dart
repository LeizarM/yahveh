import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/error/api_exception.dart';
import '../../core/utils/operation_result.dart';
import '../models/regla_descuento_model.dart';

abstract class ReglaDescuentoRemoteDataSource {
  Future<List<ReglaDescuentoModel>> listarTodas();
  Future<ReglaDescuentoModel?> buscarPorArticulo(String codArticulo);
  Future<OperationResult<ReglaDescuentoModel>> crear(ReglaDescuentoModel regla);
  Future<OperationResult<ReglaDescuentoModel>> actualizar(
      int codReglaDescuento, ReglaDescuentoModel regla);
  Future<OperationResult<void>> eliminar(int codReglaDescuento);
}

class ReglaDescuentoRemoteDataSourceImpl implements ReglaDescuentoRemoteDataSource {
  final DioClient _client;
  ReglaDescuentoRemoteDataSourceImpl(this._client);

  @override
  Future<List<ReglaDescuentoModel>> listarTodas() async {
    try {
      final response = await _client.get('/regla-descuento');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return [];
        if (data is List) return data.map((j) => ReglaDescuentoModel.fromJson(j)).toList();
      }
      throw ApiException(message: 'Formato de respuesta inválido', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al obtener reglas de descuento');
    }
  }

  @override
  Future<ReglaDescuentoModel?> buscarPorArticulo(String codArticulo) async {
    try {
      final response = await _client.get('/regla-descuento/articulo/$codArticulo');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data == null) return null;
        return ReglaDescuentoModel.fromJson(data);
      }
      return null;
    } on DioException catch (_) {
      return null;
    }
  }

  @override
  Future<OperationResult<ReglaDescuentoModel>> crear(ReglaDescuentoModel regla) async {
    try {
      final response = await _client.post('/regla-descuento', data: regla.toCreateJson());
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Regla creada';
        final data = response.data['data'];
        if (data != null) {
          return OperationResult(data: ReglaDescuentoModel.fromJson(data), message: message);
        }
      }
      throw ApiException(message: 'Error al crear regla', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al crear regla de descuento');
    }
  }

  @override
  Future<OperationResult<ReglaDescuentoModel>> actualizar(
      int codReglaDescuento, ReglaDescuentoModel regla) async {
    try {
      final response = await _client.put(
        '/regla-descuento/$codReglaDescuento',
        data: regla.toCreateJson(),
      );
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Regla actualizada';
        final data = response.data['data'];
        if (data != null) {
          return OperationResult(data: ReglaDescuentoModel.fromJson(data), message: message);
        }
      }
      throw ApiException(message: 'Error al actualizar regla', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al actualizar regla de descuento');
    }
  }

  @override
  Future<OperationResult<void>> eliminar(int codReglaDescuento) async {
    try {
      final response = await _client.delete('/regla-descuento/$codReglaDescuento');
      if (response.data != null && response.data['success'] == true) {
        final message = response.data['message'] as String? ?? 'Regla eliminada';
        return OperationResult(data: null, message: message);
      }
      throw ApiException(message: 'Error al eliminar regla', statusCode: 500);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData['message'] != null) {
        throw ApiException.fromResponse(errorData, e.response?.statusCode);
      }
      throw ApiException.fromError(e, 'Error al eliminar regla de descuento');
    }
  }
}
