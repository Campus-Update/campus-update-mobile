import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../API/dio/dio_client.dart';
import '../../API/dio/dio_factory.dart';
import '../secure_storage/secure_storage.dart';

final getIt = GetIt.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final providerContainer = ProviderContainer();

void setupLocator() {
  getIt.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());

  getIt<SecureStorageService>().initAuthTokenAndUserData();

  getIt.registerLazySingleton<DioFactory>(
    () => DioFactory(getIt<SecureStorageService>()),
  );
  getIt.registerSingleton<ProviderContainer>(providerContainer);

  getIt.registerSingletonAsync<DioClient>(() async {
    final dioFactory = getIt<DioFactory>();
    final dio = await dioFactory.getDio();
    return DioClient(
        dio, getIt<SecureStorageService>(), providerContainer, navigatorKey);
  });
}