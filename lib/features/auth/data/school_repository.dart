import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../domain/institution.dart';

/// Reads the school tree.
///
/// Unauthenticated: the questions are answered before an account exists, so
/// this must work without a token.
class SchoolRepository {
  const SchoolRepository(this._dio);

  final Dio _dio;

  Future<List<Institution>> fetchAll() async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/schools');
      return (res.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Institution.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }
}

final schoolRepositoryProvider = Provider<SchoolRepository>(
  (ref) => SchoolRepository(ref.watch(bareDioProvider)),
);

/// The schools, fetched once and reused across the questions.
final schoolsProvider = FutureProvider<List<Institution>>(
  (ref) => ref.watch(schoolRepositoryProvider).fetchAll(),
);
