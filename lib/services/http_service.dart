import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:http_parser/http_parser.dart';

abstract class HttpService {
  static const int TIMEOUT = Config.REQUEST_TIMEOUT;
  static final Dio _dio = Dio();

  static void setTimeouts() {
    _dio.options.connectTimeout = TIMEOUT;
    _dio.options.receiveTimeout = TIMEOUT;
    _dio.options.sendTimeout = TIMEOUT;
  }

  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void unsetToken() {
    _dio.options.headers.remove('Authorization');
  }

  static Future<Response> get<T>(String url, {Map<String, dynamic> queryParameters}) {
    return _dio.get<T>(url, queryParameters: queryParameters);
  }

  static Future<Response> post<T>(String url, {Map data}) {
    return _dio.post<T>(url, data: data);
  }

  static Future<Response> put<T>(String url, {Map data}) {
    return _dio.put<T>(url, data: data);
  }

  static Future<Response> patch<T>(String url, {Map data}) {
    return _dio.patch<T>(url, data: data);
  }

  static Future<Response> delete<T>(String url, {Map data}) {
    return _dio.delete<T>(url, data: data);
  }

  static Future<Response> upload<T>(
    String url,
    File file,
    String fileName,
    {
      String imageType = 'jpeg',
      Map data = const {},
      void Function(int, int) onSendProgress,
    }
  ) async {
    var formData = FormData.fromMap({
      ...data,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType('image', imageType)
      ),
    });

    var options = Options(
      headers: {
        Headers.contentLengthHeader: formData.length,
      }
    );

    return _dio.post<T>(
      url,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}
