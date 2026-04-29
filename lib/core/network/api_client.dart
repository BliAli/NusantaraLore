import 'package:dio/dio.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Dio get instance => _dio;

  static Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(url, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  static Future<Response> post(
    String url, {
    dynamic data,
  }) async {
    try {
      return await _dio.post(url, data: data);
    } on DioException {
      rethrow;
    }
  }
}
