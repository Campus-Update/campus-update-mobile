import 'package:dio/dio.dart';

import '../env/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Builds the app's HTTP clients.
///
/// The OpenAPI document declares no security scheme, so authentication is not
/// handled by generated code — [AuthInterceptor] owns it.
abstract final class DioClient {
  static BaseOptions _options() => BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    contentType: 'application/json',
    // 401 is handled by the interceptor rather than thrown past it.
    validateStatus: (status) => status != null && status < 400,
  );

  /// No interceptors: used for refresh and for retrying a request after one.
  static Dio bare() => Dio(_options());

  static Dio create({
    required SecureStorage storage,
    required Future<void> Function() onSessionExpired,
  }) {
    final dio = Dio(_options());
    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        refreshClient: bare(),
        onSessionExpired: onSessionExpired,
      ),
    );
    if (Env.isDev) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return dio;
  }
}
