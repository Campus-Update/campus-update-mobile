import 'package:dio/dio.dart';

class ErrorModel {
  final String message;

  ErrorModel(this.message);

  factory ErrorModel.fromDioError(DioException error) {
    return ErrorModel(
        error.response?.data['message'] ?? 'An unknown error occurred');
  }
}