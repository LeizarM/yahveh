import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/dio_client.dart';
import '../models/vista_model.dart';

/// Interface para la fuente de datos remota de vistas
abstract class VistaRemoteDataSource {
  Future<List<VistaModel>> getMenu();
}

/// Implementación de la fuente de datos remota de vistas
class VistaRemoteDataSourceImpl implements VistaRemoteDataSource {
  final DioClient client;

  VistaRemoteDataSourceImpl(this.client);

  @override
  Future<List<VistaModel>> getMenu() async {
    try {
      final response = await client.post(ApiConstants.menu);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => VistaModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener el menú'
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Error de servidor';
        throw ServerException(message);
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }
}
