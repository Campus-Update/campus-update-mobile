import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../../shared/domain/content_item.dart';
import '../../../shared/domain/content_source.dart';
import '../../../shared/utils/date_format.dart';
import '../domain/event_item.dart';

abstract class EventsRepository {
  Future<List<EventItem>> getEvents();
  Future<EventItem?> getEventById(String id);
}

/// Every event the API sends, soonest first and undated ones last.
///
/// Which events are still current is the API's call, so nothing is dropped
/// here. The API orders by urgency and then publish date, so this reads every
/// page before putting them in the order they happen. The Events tab and the
/// home section both read it, so they always agree.
Future<List<ContentItem>> upcomingEvents(FeedRepository feed) async {
  const pageSize = 100; // The API's largest page.
  const maxPages = 10; // A ceiling, should the API keep returning full pages.
  final items = <ContentItem>[];
  for (var page = 1; page <= maxPages; page++) {
    final batch = await feed.feed(
      type: ContentType.event,
      page: page,
      pageSize: pageSize,
    );
    items.addAll(batch);
    if (batch.length < pageSize) break;
  }

  final dated = items.where((e) => e.eventStartsAt != null).toList()
    ..sort((a, b) => a.eventStartsAt!.compareTo(b.eventStartsAt!));
  return [...dated, ...items.where((e) => e.eventStartsAt == null)];
}

/// Events from `GET /api/v1/feed?type=Event`, one from `/content/{id}`.
class ApiEventsRepository implements EventsRepository {
  const ApiEventsRepository(this._feed);

  final FeedRepository _feed;

  @override
  Future<List<EventItem>> getEvents() async =>
      (await upcomingEvents(_feed)).map(_toEventItem).toList();

  @override
  Future<EventItem?> getEventById(String id) async =>
      _toEventItem(await _feed.item(id));

  static EventItem _toEventItem(ContentItem item) {
    final startsAt = item.eventStartsAt;
    return EventItem(
      id: item.id,
      title: item.title,
      description: item.excerpt,
      // An event with no place given falls back to who published it.
      location: item.eventLocation ?? item.sourceName ?? '',
      dateFormatted: startsAt == null
          ? 'Date to be announced'
          : AppDateFormat.eventDate(startsAt),
      time: startsAt == null ? '' : _timeRange(startsAt, item.eventEndsAt),
      imageUrl: item.imageUrl,
      category: item.label,
      startsAt: startsAt,
      endsAt: item.eventEndsAt,
      registrationUrl: item.registrationUrl,
      sponsorName: item.sponsorName,
    );
  }

  /// '9:00 AM - 11:00 AM' on one day, '9:00 AM - OCT 14, 2026, 5:00 PM'
  /// across several, '9:00 AM' with no end.
  static String _timeRange(DateTime start, DateTime? end) {
    final from = AppDateFormat.time(start);
    if (end == null) return from;
    final s = start.toLocal();
    final e = end.toLocal();
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    final to = sameDay
        ? AppDateFormat.time(end)
        : '${AppDateFormat.eventDate(end)}, ${AppDateFormat.time(end)}';
    return '$from - $to';
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => ApiEventsRepository(ref.watch(feedRepositoryProvider)),
);

final eventsListProvider =
    NotifierProvider<EventsNotifier, AsyncValue<List<EventItem>>>(
      EventsNotifier.new,
    );

/// The card at the top of the screen: an event marked featured, or else the
/// first one.
final featuredEventProvider = Provider<EventItem?>((ref) {
  final events = ref.watch(eventsListProvider).value ?? const <EventItem>[];
  return events.where((e) => e.isFeatured).firstOrNull ?? events.firstOrNull;
});

/// Everything under 'More events': the events other than the featured one.
final monthlyEventsProvider = Provider<List<EventItem>>((ref) {
  final events = ref.watch(eventsListProvider).value ?? const <EventItem>[];
  final featured = ref.watch(featuredEventProvider);
  return events.where((e) => e.id != featured?.id).toList();
});

final eventByIdProvider = Provider.family<EventItem?, String>((ref, id) {
  final events = ref.watch(eventsListProvider).value ?? const <EventItem>[];
  return events.where((e) => e.id == id).firstOrNull;
});

/// One event for the detail screen, always fetched from `/content/{id}` so
/// the API counts the view. The copy in the list, when there is one, shows
/// while the fetch is in flight or if it fails.
final eventDetailProvider = Provider.family<AsyncValue<EventItem?>, String>((
  ref,
  id,
) {
  final fromList = ref.watch(eventByIdProvider(id));
  final fetched = ref.watch(eventFetchProvider(id));
  final event = fetched.value ?? fromList;
  return event != null ? AsyncValue.data(event) : fetched;
});

final eventFetchProvider = FutureProvider.autoDispose
    .family<EventItem?, String>(
      (ref, id) => ref.read(eventsRepositoryProvider).getEventById(id),
    );

/// The Events tab's list.
class EventsNotifier extends Notifier<AsyncValue<List<EventItem>>> {
  @override
  AsyncValue<List<EventItem>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    try {
      final events = await ref.read(eventsRepositoryProvider).getEvents();
      state = AsyncValue.data(events);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }
}
