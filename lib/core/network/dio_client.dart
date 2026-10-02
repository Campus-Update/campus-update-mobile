import 'package:dio/dio.dart';

import '../env/env.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

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

  /// No auth interceptor: used for refresh, for retrying after one, and for
  /// the calls made before a session exists. It still logs in development —
  /// signing in and registering happen here, and they are the calls most
  /// worth seeing.
  static Dio bare() {
    final dio = Dio(_options());
    if (Env.isDev) dio.interceptors.add(const LoggingInterceptor());
    return dio;
  }

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
    if (Env.isDev) dio.interceptors.add(const LoggingInterceptor());
    return dio;
  }
}
