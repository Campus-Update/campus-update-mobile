import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../domain/user_profile.dart';

/// Reads the signed-in user from the API.
///
/// Login and register hand back tokens and nothing else, so this is the only
/// way to learn who the session belongs to — which matters on a device the
/// user did not register on, where nothing was ever stored locally.
class ProfileRepository {
  const ProfileRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> fetch() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/auth/profile');
      return UserProfile.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);
