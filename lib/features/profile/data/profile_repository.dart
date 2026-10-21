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

  /// `PUT /auth/profile`: name and matriculation or staff number.
  Future<UserProfile> updateDetails({
    required String firstName,
    required String lastName,
    String? matriculationOrStaffNumber,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/api/v1/auth/profile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'matriculationOrStaffNumber': matriculationOrStaffNumber,
        },
      );
      return UserProfile.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// `POST /auth/change-password`. Signs out every other device.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<void>(
        '/api/v1/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// `PUT /auth/academic-settings`: the academic IDs and feed settings,
  /// replaced as one set. See [UserProfile.toAcademicSettingsJson].
  Future<UserProfile> updateAcademicSettings(UserProfile profile) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(
        '/api/v1/auth/academic-settings',
        data: profile.toAcademicSettingsJson(),
      );
      return UserProfile.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(dioProvider)),
);
