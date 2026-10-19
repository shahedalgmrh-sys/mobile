import 'package:dio/dio.dart';

import '../constants/app_headers.dart';
import '../errors/failures.dart';
import '../storage/secure_storage.dart';

/// Thin Dio wrapper that injects the platform header contract
/// (`Accept`, `Authorization`, `Accept-Language`, `X-Currency`, `X-Device-ID`,
/// `X-App-Version`, `X-Client-Type`) and normalizes every failed request into a
/// typed [Failure].
class ApiClient {
  final Dio dio;
  final String baseUrl;
  final String appVersion;
  final SecureStorage storage;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  /// Current locale/currency sent with every request (spec headers contract).
  String language;
  String currency;

  /// Invoked whenever the API rejects the current session (HTTP 401) so the app
  /// can reset authentication state and route back to the login screen.
  void Function()? onUnauthorized;

  ApiClient({
    required this.dio,
    required this.baseUrl,
    required this.appVersion,
    required this.storage,
    this.language = 'ar',
    this.currency = 'yer',
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 60),
    this.sendTimeout = const Duration(seconds: 60),
    this.onUnauthorized,
  }) {
    _setupDio();
  }

  void _setupDio() {
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout
      ..sendTimeout = sendTimeout
      ..contentType = Headers.jsonContentType
      // Laravel only renders JSON error payloads (401/403/404/422/429/500) when
      // the request explicitly negotiates JSON. Without this header every error
      // comes back as an HTML redirect and cannot be handled by the app.
      ..headers[AppHeaders.accept] = Headers.jsonContentType
      // Only 2xx is a success; everything else flows through [onError].
      ..validateStatus = (status) =>
          status != null && status >= 200 && status < 300;

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers[AppHeaders.acceptLanguage] = language;
          options.headers[AppHeaders.xCurrency] = currency;

          final deviceId = await storage.readDeviceId();
          if (deviceId != null && deviceId.isNotEmpty) {
            options.headers[AppHeaders.xDeviceId] = deviceId;
          }

          options.headers[AppHeaders.xAppVersion] = appVersion;
          options.headers[AppHeaders.xClientType] = 'flutter';

          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers[AppHeaders.authorization] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (_isConnectionError(error.type)) {
            return handler.reject(_wrap(error, const NetworkFailure()));
          }

          switch (statusCode) {
            case 401:
              await _handleUnauthorized();
              return handler.reject(_wrap(error, const UnauthorizedFailure()));
            case 403:
              return handler.reject(
                _wrap(
                  error,
                  ServerFailure(
                    code: 403,
                    message: _message(data, 'لا تملك صلاحية تنفيذ هذا الإجراء.'),
                  ),
                ),
              );
            case 404:
              return handler.reject(
                _wrap(
                  error,
                  ServerFailure(
                    code: 404,
                    message: _message(data, 'العنصر المطلوب غير موجود.'),
                  ),
                ),
              );
            case 422:
              return handler.reject(_wrap(error, _validationFailure(data)));
            case 429:
              return handler.reject(
                _wrap(
                  error,
                  ServerFailure(
                    code: 429,
                    message: _message(
                      data,
                      'تم تجاوز الحد المسموح من الطلبات. حاول بعد قليل.',
                    ),
                  ),
                ),
              );
          }

          if (statusCode != null) {
            return handler.reject(
              _wrap(
                error,
                ServerFailure(
                  code: statusCode,
                  message: _message(
                    data,
                    statusCode >= 500
                        ? 'حدث خطأ في الخادم. حاول لاحقاً.'
                        : 'تعذر إتمام الطلب.',
                  ),
                ),
              ),
            );
          }

          return handler.reject(error);
        },
      ),
    );
  }

  static bool _isConnectionError(DioExceptionType type) =>
      type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.receiveTimeout ||
      type == DioExceptionType.sendTimeout ||
      type == DioExceptionType.connectionError;

  static DioException _wrap(DioException error, Failure failure) => DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: failure,
      );

  static String _message(dynamic data, String fallback) {
    if (data is Map && data['message'] != null) {
      final message = data['message'].toString();
      if (message.isNotEmpty) return message;
    }
    return fallback;
  }

  static Failure _validationFailure(dynamic data) {
    final errorsMap = <String, List<String>>{};

    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List) {
            errorsMap[key.toString()] = value.map((e) => e.toString()).toList();
          } else if (value != null) {
            errorsMap[key.toString()] = [value.toString()];
          }
        });
      }
      if (errorsMap.isEmpty) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          errorsMap['error'] = [message];
        }
      }
    }

    if (errorsMap.isEmpty) {
      errorsMap['error'] = ['البيانات المُرسلة غير صحيحة.'];
    }
    return ValidationFailure(errors: errorsMap);
  }

  /// Clears the stored session (token + cached user) and notifies the app.
  /// The device id is intentionally preserved so headers stay stable.
  Future<void> _handleUnauthorized() async {
    await storage.deleteToken();
    await storage.deleteUser();
    onUnauthorized?.call();
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
      options: options ??
          Options(contentType: Headers.multipartFormDataContentType),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
