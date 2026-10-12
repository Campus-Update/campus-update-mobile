import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/network_providers.dart';
import '../domain/content_item.dart';
import '../domain/content_source.dart';

/// Reads published content: `GET /api/v1/feed` for lists, `/content/{id}` for
/// one item.
///
/// `/feed` is narrowed to the signed-in user's audience, so it is what every
/// screen reads. Home, News and Events differ only in the filters they pass.
class FeedRepository {
  const FeedRepository(this._dio);

  final Dio _dio;

  Future<List<ContentItem>> feed({
    ContentType? type,
    Urgency? urgency,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/api/v1/feed',
        queryParameters: {
          if (type != null) 'type': _apiName(type.name),
          if (urgency != null) 'urgency': _apiName(urgency.name),
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          'page': page,
          'pageSize': pageSize,
        },
      );
      return (res.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ContentItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<ContentItem> item(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/content/$id');
      return ContentItem.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  /// The API spells its enums capitalised — `News`, `Urgent`.
  static String _apiName(String name) =>
      name[0].toUpperCase() + name.substring(1);
}

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(ref.watch(dioProvider)),
);
