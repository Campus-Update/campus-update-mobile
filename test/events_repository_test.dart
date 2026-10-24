import 'package:campus_update/features/events/data/events_repository.dart';
import 'package:campus_update/features/home/data/home_feed_providers.dart';
import 'package:campus_update/shared/data/feed_repository.dart';
import 'package:campus_update/shared/domain/content_item.dart';
import 'package:campus_update/shared/domain/content_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves [items] a page at a time and remembers which pages were asked for.
class _PagedFeed implements FeedRepository {
  _PagedFeed(this.items);

  final List<ContentItem> items;
  final pages = <int>[];
  final opened = <String>[];
  final categories = <String?>[];

  @override
  Future<List<ContentItem>> feed({
    ContentType? type,
    Urgency? urgency,
    String? search,
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    pages.add(page);
    categories.add(category);
    return items.skip((page - 1) * pageSize).take(pageSize).toList();
  }

  @override
  Future<ContentItem> item(String id) async {
    opened.add(id);
    return items.firstWhere((i) => i.id == id);
  }
}

final _now = DateTime(2026, 10, 24, 12);

ContentItem _event(String id, {DateTime? startsAt, DateTime? endsAt}) =>
    ContentItem(
      id: id,
      title: id,
      body: '$id.',
      type: ContentType.event,
      urgency: Urgency.normal,
      source: ContentSource.officialSchool,
      eventStartsAt: startsAt,
      eventEndsAt: endsAt,
    );

void main() {
  test('reads every page until a short one', () async {
    final feed = _PagedFeed([
      for (var i = 0; i < 150; i++)
        _event('e$i', startsAt: _now.add(Duration(days: i + 1))),
    ]);

    final events = await ApiEventsRepository(feed).getEvents();

    expect(feed.pages, [1, 2]);
    expect(events, hasLength(150));
  });

  test('keeps every event the API sends, ordered by start', () async {
    final feed = _PagedFeed([
      _event('later', startsAt: _now.add(const Duration(days: 9))),
      _event('tba'),
      _event('yesterday', startsAt: _now.subtract(const Duration(days: 1))),
      _event(
        'finished',
        startsAt: _now.subtract(const Duration(hours: 3)),
        endsAt: _now.subtract(const Duration(hours: 1)),
      ),
      _event('this morning', startsAt: _now.subtract(const Duration(hours: 2))),
      _event('soon', startsAt: _now.add(const Duration(days: 1))),
    ]);

    final events = await ApiEventsRepository(feed).getEvents();

    expect(events.map((e) => e.id), [
      'yesterday',
      'finished',
      'this morning',
      'soon',
      'later',
      'tba',
    ]);
  });

  test('a same-day end shows as a time range', () async {
    final start = DateTime(2026, 11, 2, 9);
    final feed = _PagedFeed([
      _event('e', startsAt: start, endsAt: start.add(const Duration(hours: 2))),
    ]);

    final event = (await ApiEventsRepository(feed).getEvents()).single;

    expect(event.time, '9:00 AM - 11:00 AM');
    expect(event.endsAt, start.add(const Duration(hours: 2)));
  });

  test('the detail is fetched even when the list holds it', () async {
    final feed = _PagedFeed([
      _event('e', startsAt: _now.add(const Duration(days: 1))),
    ]);
    final container = ProviderContainer(
      overrides: [
        eventsRepositoryProvider.overrideWithValue(ApiEventsRepository(feed)),
      ],
    );
    addTearDown(container.dispose);
    final list = container.listen(eventsListProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    expect(list.read().value, hasLength(1));

    container.listen(eventDetailProvider('e'), (_, _) {});
    await Future<void>.delayed(Duration.zero);

    expect(feed.opened, ['e']);
  });

  test('home lists the same events as the Events tab', () async {
    final feed = _PagedFeed([
      _event('later', startsAt: _now.add(const Duration(days: 9))),
      _event('yesterday', startsAt: _now.subtract(const Duration(days: 1))),
      _event('soon', startsAt: _now.add(const Duration(days: 1))),
    ]);
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(feed)],
    );
    addTearDown(container.dispose);

    final events = await container.read(upcomingEventsProvider.future);

    expect(events.map((e) => e.id), ['yesterday', 'soon', 'later']);
  });

  test('a home tab sends its category to every home section', () async {
    final feed = _PagedFeed(const []);
    final container = ProviderContainer(
      overrides: [feedRepositoryProvider.overrideWithValue(feed)],
    );
    addTearDown(container.dispose);

    container.read(homeCategoryProvider.notifier).select('Campus');
    await container.read(breakingNewsProvider.future);
    await container.read(latestNewsProvider.future);
    await container.read(upcomingEventsProvider.future);

    expect(feed.categories, ['Campus', 'Campus', 'Campus']);
  });
}
