import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:campus_update/core/API/lis_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../services/secure_storage/constant.dart';
import '../../services/secure_storage/secure_storage.dart';

const String APPLICATION_JSON = "application/json";
const String CONTENT_TYPE = "content-type";
const String ACCEPT = "accept";
const String DEFAULT_LANGUAGE = "en";
const String BASE_URL = ListApi.baseUrl;

class DioFactory {
  final SecureStorageService secureStorageService;

  DioFactory(
    this.secureStorageService,
  );

  Future<Dio> getDio() async {
    Dio dio = Dio();

    dio.options = BaseOptions(
      baseUrl: BASE_URL,
      headers: {
        CONTENT_TYPE: APPLICATION_JSON,
        ACCEPT: APPLICATION_JSON,
        DEFAULT_LANGUAGE: DEFAULT_LANGUAGE,
      },
      receiveTimeout: const Duration(minutes: 1),
      sendTimeout: const Duration(minutes: 1),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token =
            await secureStorageService.read(secure_storage_key.authToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    if (!kReleaseMode) {
      dio.interceptors.add(AwesomeDioInterceptor());
    }

    return dio;
  }
}