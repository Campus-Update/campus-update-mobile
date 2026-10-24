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

FeedRepository _repo(_Adapter adapter) => FeedRepository(
  Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = adapter,
);

void main() {
  test('filters reach the API capitalised', () async {
    final adapter = _Adapter(const []);
    await _repo(adapter).feed(type: ContentType.news, urgency: Urgency.urgent);

    expect(adapter.paths.single, contains('/api/v1/feed?type=News'));
    expect(adapter.paths.single, contains('urgency=Urgent'));
  });

  test('items come back parsed', () async {
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
    final items = await _repo(adapter).feed();

    expect(items.map((i) => i.id), ['real-1']);
  });

  test('event fields come back parsed', () async {
    final adapter = _Adapter([
      {
        'id': 'ev-1',
        'title': 'Career fair',
        'body': 'Body',
        'type': 'Event',
        'urgency': 'Normal',
        'sourceType': 'Official',
        'eventStartsAt': '2026-11-02T09:00:00+00:00',
        'eventEndsAt': '2026-11-02T13:00:00+00:00',
        'eventLocation': 'Main hall',
        'registrationUrl': 'https://example.com/register',
        'sponsorName': 'Acme',
      },
    ]);
    final item = (await _repo(adapter).feed()).single;

    expect(item.eventStartsAt, DateTime.utc(2026, 11, 2, 9));
    expect(item.eventEndsAt, DateTime.utc(2026, 11, 2, 13));
    expect(item.eventLocation, 'Main hall');
    expect(item.registrationUrl, 'https://example.com/register');
    expect(item.sponsorName, 'Acme');
  });

  test('an empty feed stays empty', () async {
    final items = await _repo(_Adapter(const [])).feed();

    expect(items, isEmpty);
  });
}
