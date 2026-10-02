import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Prints each call and what came back, for development only.
///
/// Dio's own LogInterceptor would print the body verbatim, which on these
/// endpoints means passwords going to the console and tokens coming back.
/// Those are replaced here, so a shared screen or a pasted log does not hand
/// anyone a live session.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  static const _secretKeys = {
    'password',
    'accessToken',
    'refreshToken',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method} ${options.uri}', options.data);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final code = response.statusCode;
    final path = response.requestOptions.uri.path;
    _log('← $code ${response.requestOptions.method} $path', response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode;
    final path = err.requestOptions.uri.path;
    _log(
      '✗ ${code ?? err.type.name} ${err.requestOptions.method} $path',
      err.response?.data ?? err.message,
    );
    handler.next(err);
  }

  /// debugPrint, not dart:developer's log: the latter goes to DevTools and
  /// does not reliably reach the console `flutter run` is printing to, which
  /// is where anyone debugging is actually looking.
  void _log(String headline, Object? body) {
    debugPrint('[api] $headline');
    if (body != null) debugPrint(_render(body));
  }

  String _render(Object? body) {
    try {
      return const JsonEncoder.withIndent('  ').convert(redact(body));
    } catch (_) {
      // Not JSON — a form body, or bytes.
      return body.toString();
    }
  }

  /// Replaces secrets anywhere in the structure, however deeply nested.
  /// Public so it can be tested: a leak here is silent and permanent.
  static Object? redact(Object? value) => switch (value) {
    Map() => {
      for (final e in value.entries)
        e.key: _secretKeys.contains(e.key) ? '<redacted>' : redact(e.value),
    },
    List() => value.map(redact).toList(),
    _ => value,
  };
}
