import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';

/// Cliente HTTP basado en Dio con interceptores para autenticación y manejo de token
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  final Logger _logger;
  final Function()? onUnauthorized;

  DioClient({
    FlutterSecureStorage? storage,
    Logger? logger,
    this.onUnauthorized,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _logger = logger ?? Logger() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
          ApiConstants.accept: ApiConstants.applicationJson,
        },
      ),
    );

    // Interceptor para agregar token y manejar respuestas
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token a todas las peticiones excepto login
          if (!options.path.contains('/login')) {
            final token = await _storage.read(key: AppConfig.tokenKey);
            if (token != null) {
              options.headers[ApiConstants.authorization] = 
                  '${ApiConstants.bearer} $token';
            }
          }
          _logger.d('🚀 Request: ${options.method} ${options.path}');
          _logger.d('📦 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          _logger.d('✅ Response: ${response.statusCode} ${response.requestOptions.path}');
          
          // Si la respuesta contiene token, guardarlo automáticamente
          if (response.data != null && response.data is Map) {
            final data = response.data as Map<String, dynamic>;
            if (data['success'] == true && data['data'] != null) {
              final responseData = data['data'] as Map<String, dynamic>;
              if (responseData.containsKey('token')) {
                final token = responseData['token'] as String;
                await _storage.write(key: AppConfig.tokenKey, value: token);
                _logger.d('🔑 Token guardado automáticamente');
              }
            }
          }
          
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('❌ Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('📝 Message: ${error.message}');
          
          // Si el token expiró (401), eliminar token y redirigir al login
          if (error.response?.statusCode == 401) {
            _logger.w('⚠️ Token expirado o inválido. Cerrando sesión...');
            await _storage.delete(key: AppConfig.tokenKey);
            await _storage.delete(key: AppConfig.userKey);
            
            // Llamar callback para redirigir al login
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
