import 'package:dio/dio.dart';

import '../constants/app_headers.dart';
import '../errors/failures.dart';
import '../storage/secure_storage.dart';

class AppConfig {
  final String baseUrl;
  final String appVersion;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const AppConfig({
    required this.baseUrl,
    required this.appVersion,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 60),
  });
}

class ApiClient {
  final Dio dio;
  final AppConfig config;
  final SecureStorage storage;

  ApiClient({
    required this.dio,
    required this.config,
    required this.storage,
  }) {
    _setupDio();
  }

  void _setupDio() {
    dio.options.baseUrl = config.baseUrl;
    dio.options.connectTimeout = config.connectTimeout;
    dio.options.receiveTimeout = config.receiveTimeout;
    dio.options.contentType = Headers.jsonContentType;

    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers[AppHeaders.acceptLanguage] = 'ar';
        options.headers[AppHeaders.xCurrency] = 'yer';

        final deviceId = await storage.readDeviceId();
        if (deviceId != null) {
          options.headers[AppHeaders.xDeviceId] = deviceId;
        }

        options.headers[AppHeaders.xAppVersion] = config.appVersion;
        options.headers[AppHeaders.xClientType] = 'flutter';

        final token = await storage.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers[AppHeaders.authorization] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode != null &&
            response.statusCode! >= 200 &&
            response.statusCode! < 300) {
          return handler.next(response);
        }
        if (response.statusCode == 401) {
          _handleLogout();
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: const UnauthorizedFailure(),
            ),
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkFailure(),
            ),
          );
        }

        if (statusCode == 422) {
          final Map<String, List<String>> errorsMap = {};
          if (data is Map<String, dynamic>) {
            final errors = data['errors'] as Map<String, dynamic>?;
            if (errors != null) {
              errors.forEach((key, value) {
                if (value is List) {
                  errorsMap[key] = value.map((e) => e.toString()).toList();
                }
              });
            }
          }
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: ValidationFailure(errors: errorsMap),
            ),
          );
        }

        if (statusCode == 401) {
          _handleLogout();
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const UnauthorizedFailure(),
            ),
          );
        }

        if (statusCode != null && statusCode >= 500) {
          final message = data is Map<String, dynamic>
              ? data['message']?.toString() ?? 'Server Error'
              : 'Server Error';
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: ServerFailure(code: statusCode, message: message),
            ),
          );
        }

        return handler.reject(error);
      },
    ));
  }

  Future<void> _handleLogout() async {
    await storage.deleteToken();
    await storage.deleteAll();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> multipartUpload(
    String path, {
    required List<MultipartFile> files,
    Map<String, dynamic>? fields,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) {
    final formData = FormData.fromMap({
      if (fields != null) ...fields,
      'files': files,
    });

    return dio.post(
      path,
      data: formData,
      options: options ?? Options(contentType: Headers.multipartFormDataContentType),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
