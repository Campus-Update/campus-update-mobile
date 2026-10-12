import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_update/shared/data/feed_repository.dart';
import 'package:campus_update/shared/domain/content_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with [body] and remembers the paths it was asked for.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.body);

  final Object body;
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.toString());
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

FeedRepository _repo(_Adapter adapter, {required bool mockWhenEmpty}) =>
    FeedRepository(
      Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter,
      mockWhenEmpty: mockWhenEmpty,
    );

void main() {
  test('an empty feed still calls the API, then falls back to mock', () async {
    final adapter = _Adapter(const []);
    final items = await _repo(
      adapter,
      mockWhenEmpty: true,
    ).feed(type: ContentType.news);

    expect(adapter.paths.single, contains('/api/v1/feed?type=News'));
    expect(items, isNotEmpty);
    expect(items.every((i) => i.type == ContentType.news), isTrue);
    expect(items.every((i) => i.imageUrl != null), isTrue);
  });

  test('real content wins over the mock', () async {
    final adapter = _Adapter([
      {
        'id': 'real-1',
        'title': 'From the API',
        'body': 'Body',
        'type': 'News',
        'urgency': 'Normal',
        'sourceType': 'Official',
      },
    ]);
    final items = await _repo(adapter, mockWhenEmpty: true).feed();

    expect(items.map((i) => i.id), ['real-1']);
  });

  test('with the mock off, an empty feed stays empty', () async {
    final items = await _repo(_Adapter(const []), mockWhenEmpty: false).feed();

    expect(items, isEmpty);
  });

  test('urgent mock items fill the hero', () async {
    final items = await _repo(
      _Adapter(const []),
      mockWhenEmpty: true,
    ).feed(urgency: Urgency.urgent, pageSize: 3);

    expect(items, hasLength(3));
    expect(items.every((i) => i.urgency == Urgency.urgent), isTrue);
  });
}
