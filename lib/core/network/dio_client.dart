import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:todo/core/constants/api_constants.dart';

class DioClient {
  final dio.Dio _dio = dio.Dio();

  DioClient() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(dio.LogInterceptor(
      request: true,
      responseBody: true,
      requestBody: true,
      requestHeader: true,
    ));
  }

  Future<dio.Response> post(String url, {dynamic data, String? accessToken}) async {
    try {
      final headers = {
        ApiConstants.abpTenantIdHeader: ApiConstants.tenantId,
        if (accessToken != null)
          ApiConstants.authorizationHeader: 'Bearer $accessToken'
      };

      return await _dio.post(
        url,
        data: data,
        options: dio.Options(headers: headers),
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> get(String url, {String? accessToken}) async {
    try {
      final headers = {
        ApiConstants.abpTenantIdHeader: ApiConstants.tenantId,
        if (accessToken != null)
          ApiConstants.authorizationHeader: 'Bearer $accessToken'
      };

      return await _dio.get(
        url,
        options: dio.Options(headers: headers),
      );
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(dio.DioException e) {
    if (e.response != null) {
      Get.snackbar('Error', '${e.response?.data['error']['message']}');
    } else {
      Get.snackbar('Error', 'Network error: ${e.message}');
    }
  }
}