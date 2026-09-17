import 'package:campus_update/core/services/riverpod/setttings_provider.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../services/riverpod/state_resetter.dart';
import '../../services/secure_storage/secure_storage.dart';
import '../models/failure.dart';
import 'dio_factory.dart';
import 'isolate_parser.dart';

typedef ResponseConverter<T> = T Function(dynamic response);

class DioClient {
  final Dio dio;
  final SecureStorageService secureStorageService;
  final ProviderContainer providerContainer;
  final GlobalKey<NavigatorState> navigatorKey;

  DioClient(
    this.dio,
    this.secureStorageService,
    this.providerContainer,
    this.navigatorKey,
  );

  Future<Either<Failure, T>> _makeRequest<T>(
    Future<Response> Function() request, {
    required ResponseConverter<T> converter,
    bool isIsolate = true,
  }) async {
    try {
      final response = await request();
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! > 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }

      if (!isIsolate) {
        return Right(converter(response.data));
      }

      final isolateParse = IsolateParser<T>(
        response.data as Map<String, dynamic>,
        converter,
      );
      final result = await isolateParse.parseInBackground();
      return Right(result);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      // if (statusCode == 401 && !_alreadyNavigatedToSplash) {
      //   _alreadyNavigatedToSplash = true;
      //   // resetAllStates(providerContainer, type: ResetType.all);
      //   navigateWithoutAnimation(screen: SplashScreen());
      //   // await secureStorageService.deleteUserCachedData();
      //   EasyLoading.showError(translate("apiErrorUserTokenExpired"));
      // }
      final errorMessage =
          e.response?.data['message'] ?? 'Something went wrong';
      return Left(Failure(
        message: errorMessage.toString(),
        code: statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: e.toString(), code: 500));
    }
  }

  Future<Either<Failure, T>> getRequest<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    required ResponseConverter<T> converter,
    bool isIsolate = true,
  }) async {
    return _makeRequest(
      () => dio.get(url, queryParameters: queryParameters),
      converter: converter,
      isIsolate: isIsolate,
    );
  }

  Future<Either<Failure, T>> postRequest<T>(
    String url, {
    dynamic data,
    required ResponseConverter<T> converter,
    bool isIsolate = true,
    Map<String, String>? customHeaders,
  }) async {
    final headers = customHeaders ?? await dio.options.headers;
    return _makeRequest(
      () => dio.post(url, data: data, options: Options(headers: headers)),
      converter: converter,
      isIsolate: isIsolate,
    );
  }

  Future<Either<Failure, T>> putRequest<T>(String url,
      {Map<String, dynamic>? data,
      required ResponseConverter<T> converter,
      bool isIsolate = true,
      Options? options}) async {
    return _makeRequest(
      () => dio.put(url, data: data, options: options),
      converter: converter,
      isIsolate: isIsolate,
    );
  }

  Future<Either<Failure, T>> deleteRequest<T>(
    String url, {
    Map<String, dynamic>? data,
    required ResponseConverter<T> converter,
    bool isIsolate = true,
  }) async {
    return _makeRequest(
      () => dio.delete(url, data: data),
      converter: converter,
      isIsolate: isIsolate,
    );
  }
}

final dioClientProvider = FutureProvider<DioClient>((ref) async {
  final secureStorageService = ref.read(secureStorageServiceProvider);
  final providerContainer = ref.read(providerContainerProvider);

  final dioFactory = DioFactory(
    secureStorageService,
  );
  final dio = await dioFactory.getDio();
  final navigatorKey = GlobalKey<NavigatorState>();
  return DioClient(dio, secureStorageService, providerContainer, navigatorKey);
});