import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// Attaches the bearer token, and refreshes it once when the API returns 401.
///
/// Access tokens live 15 minutes, so several in-flight requests routinely expire
/// together. Each one must not fire its own refresh: the backend rotates the
/// refresh token on every call, so parallel refreshes would invalidate each
/// other and sign the user out. [_inFlight] makes concurrent 401s queue behind a
/// single refresh, the same way the RN app's `mutator.ts` does.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorage storage,
    required Dio refreshClient,
    required Future<void> Function() onSessionExpired,
  }) : _storage = storage,
       _refreshClient = refreshClient,
       _onSessionExpired = onSessionExpired;

  final SecureStorage _storage;

  /// A bare client with no interceptors, so refreshing cannot recurse.
  final Dio _refreshClient;
  final Future<void> Function() _onSessionExpired;

  Future<bool>? _inFlight;

  static const _retriedFlag = 'retried_after_refresh';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await _storage.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldRefresh =
        err.response?.statusCode == 401 &&
        request.extra[_retriedFlag] != true &&
        request.extra['skipAuth'] != true;

    if (!shouldRefresh) return handler.next(err);

    final refreshed = await (_inFlight ??= _refresh().whenComplete(
      () => _inFlight = null,
    ));
    if (!refreshed) return handler.next(err);

    try {
      request.extra[_retriedFlag] = true;
      final token = await _storage.readAccessToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      handler.resolve(await _refreshClient.fetch<dynamic>(request));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) {
      await _onSessionExpired();
      return false;
    }

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null) {
        await _onSessionExpired();
        return false;
      }

      // Both tokens are replaced: the backend rotates the refresh token too.
      await _storage.writeTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } on DioException {
      await _onSessionExpired();
      return false;
    }
  }
}
