import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';
import '../storage/storage_providers.dart';
import 'dio_client.dart';

/// A client with no interceptors, for calls made before a session exists —
/// the school list, registering, signing in.
final bareDioProvider = Provider<Dio>((ref) => DioClient.bare());

/// A client that carries the access token and refreshes it when the API says
/// it has lapsed. Everything behind a session goes through this one.
final dioProvider = Provider<Dio>(
  (ref) => DioClient.create(
    storage: ref.watch(secureStorageProvider),
    onSessionExpired: () => ref.read(authProvider.notifier).signOut(),
  ),
);
