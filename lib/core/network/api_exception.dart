import 'package:dio/dio.dart';

/// Normalised API failure.
///
/// The spec documents only `200` responses, so error shapes come from the
/// backend's written contract rather than from generated code: RFC 7807
/// `ProblemDetails` with `title` and `status`.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.isNetworkError = false,
  });

  final int? statusCode;
  final String message;
  final bool isNetworkError;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400;

  factory ApiException.from(DioException e) {
    final isNetwork = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };

    if (isNetwork) {
      return const ApiException(
        statusCode: null,
        message: 'No connection. Check your network and try again.',
        isNetworkError: true,
      );
    }

    final status = e.response?.statusCode;
    final data = e.response?.data;
    final title = data is Map && data['title'] is String
        ? data['title'] as String
        : null;

    return ApiException(
      statusCode: status,
      message: title ?? _defaultMessage(status),
    );
  }

  static String _defaultMessage(int? status) => switch (status) {
    400 => 'Please check the details you entered.',
    401 => 'Your session has expired. Please sign in again.',
    403 => 'You do not have access to this.',
    404 => 'Not found.',
    409 => 'That email is already registered.',
    _ => 'Something went wrong. Please try again.',
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}
