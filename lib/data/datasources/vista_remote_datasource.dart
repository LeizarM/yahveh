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
      print('🌐 [VistaDataSource] Solicitando menú desde: ${ApiConstants.menu}');
      final response = await client.post(ApiConstants.menu);

      print('📡 [VistaDataSource] Response status: ${response.statusCode}');
      print('📡 [VistaDataSource] Response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        print('✅ [VistaDataSource] Menú recibido: ${data.length} items');
        
        final menu = data.map((json) => VistaModel.fromJson(json)).toList();
        for (var vista in menu) {
          print('   - ${vista.titulo} (${vista.direccion})');
        }
        
        return menu;
      } else {
        print('❌ [VistaDataSource] Error en respuesta: ${response.data['message']}');
        throw ServerException(
          response.data['message'] ?? 'Error al obtener el menú'
        );
      }
    } on DioException catch (e) {
      print('❌ [VistaDataSource] DioException: ${e.message}');
      print('   Response: ${e.response?.data}');
      if (e.response != null && e.response!.data != null) {
        final message = e.response!.data['message'] ?? 'Error de servidor';
        throw ServerException(message);
      }
      throw ServerException('Error de conexión: ${e.message}');
    } catch (e) {
      print('❌ [VistaDataSource] Error inesperado: $e');
      throw ServerException('Error inesperado: $e');
    }
  }
}
