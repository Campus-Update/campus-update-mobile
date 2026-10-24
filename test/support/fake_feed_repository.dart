import 'package:campus_update/shared/data/feed_repository.dart';
import 'package:campus_update/shared/domain/content_item.dart';
import 'package:campus_update/shared/domain/content_source.dart';

/// Stands in for `GET /api/v1/feed`, so screens that read the feed render
/// without a network. Three urgent items, three news and two events.
class FakeFeedRepository implements FeedRepository {
  /// How many times the feed has been asked for.
  int calls = 0;

  @override
  Future<List<ContentItem>> feed({
    ContentType? type,
    Urgency? urgency,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    calls++;
    if (urgency == Urgency.urgent) return _breaking;
    return switch (type) {
      ContentType.news => _news,
      ContentType.event => _events,
      _ => [..._breaking, ..._news, ..._events],
    };
  }

  @override
  Future<ContentItem> item(String id) async =>
      [..._breaking, ..._news, ..._events].firstWhere((i) => i.id == id);
}

final fakeFeedOverride = feedRepositoryProvider.overrideWithValue(
  FakeFeedRepository(),
);

ContentItem _item(
  String id,
  String title, {
  ContentType type = ContentType.news,
  Urgency urgency = Urgency.normal,
  String? category,
}) => ContentItem(
  id: id,
  title: title,
  body: '$title.',
  type: type,
  urgency: urgency,
  source: ContentSource.officialSchool,
  category: category,
);

final _breaking = [
  _item(
    'b1',
    'Major Infrastructure Overhaul Announced for North Campus',
    urgency: Urgency.urgent,
  ),
  _item(
    'b2',
    'Senate Approves Revised Academic Calendar for 2025/2026',
    urgency: Urgency.urgent,
  ),
  _item(
    'b3',
    'Campus Clinic Extends Opening Hours Through Exam Week',
    urgency: Urgency.urgent,
  ),
];

final _news = [
  _item(
    'n1',
    'FOCIT introduces machine learning elective for 400 level students',
    category: 'Campus',
  ),
  _item('n2', 'New Library Wing Opens Ahead of Schedule', category: 'General'),
  _item('n3', 'Hostel Wi-Fi Upgrade Completed', category: 'Technology'),
];

final _events = [
  _item(
    'e1',
    'New Library Wing Opens Ahead of Schedule',
    type: ContentType.event,
  ),
  _item(
    'e2',
    'Matriculation ceremony for the 2025/2026 session',
    type: ContentType.event,
  ),
];
