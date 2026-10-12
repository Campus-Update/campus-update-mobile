import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/env/env.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/network_providers.dart';
import '../domain/content_item.dart';
import '../domain/content_source.dart';
import 'mock_feed.dart';

/// Reads published content: `GET /api/v1/feed` for lists, `/content/{id}` for
/// one item.
///
/// `/feed` is narrowed to the signed-in user's audience, so it is what every
/// screen reads. Home, News and Events differ only in the filters they pass.
///
/// While [mockWhenEmpty] is on, an empty answer is replaced with [MockFeed]
/// content. The request is made either way.
class FeedRepository {
  const FeedRepository(this._dio, {this.mockWhenEmpty = Env.mockEmptyFeed});

  final Dio _dio;
  final bool mockWhenEmpty;

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
      final items = (res.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ContentItem.fromJson)
          .toList();
      if (items.isEmpty && mockWhenEmpty) {
        return MockFeed.feed(
          type: type,
          urgency: urgency,
          search: search,
          page: page,
          pageSize: pageSize,
        );
      }
      return items;
    } on DioException catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<ContentItem> item(String id) async {
    // A mock id would only 404 on the API.
    final mock = MockFeed.isMock(id) ? MockFeed.item(id) : null;
    if (mock != null) return mock;
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
