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

/// Events from `GET /api/v1/feed?type=Event`, one from `/content/{id}`.
///
/// The API has no registration or calendar endpoints, so those are kept by
/// [EventsNotifier] for the session.
class ApiEventsRepository implements EventsRepository {
  const ApiEventsRepository(this._feed);

  final FeedRepository _feed;

  @override
  Future<List<EventItem>> getEvents() async {
    final items = await _feed.feed(type: ContentType.event);
    return items.map(_toEventItem).toList();
  }

  @override
  Future<EventItem?> getEventById(String id) async =>
      _toEventItem(await _feed.item(id));

  static EventItem _toEventItem(ContentItem item) {
    final startsAt = item.eventStartsAt;
    return EventItem(
      id: item.id,
      title: item.title,
      description: item.excerpt,
      // The API does not return an event's place or date yet; until it does,
      // who published it stands in for the place.
      location: item.eventLocation ?? item.sourceName ?? '',
      dateFormatted: startsAt == null
          ? 'Date to be announced'
          : AppDateFormat.eventDate(startsAt),
      time: startsAt == null ? '' : AppDateFormat.time(startsAt),
      imageUrl: item.imageUrl,
      category: item.label,
    );
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

/// Everything under 'This month': the events other than the featured one.
final monthlyEventsProvider = Provider<List<EventItem>>((ref) {
  final events = ref.watch(eventsListProvider).value ?? const <EventItem>[];
  final featured = ref.watch(featuredEventProvider);
  return events.where((e) => e.id != featured?.id).toList();
});

final eventByIdProvider = Provider.family<EventItem?, String>((ref, id) {
  final events = ref.watch(eventsListProvider).value ?? const <EventItem>[];
  return events.where((e) => e.id == id).firstOrNull;
});

/// One event for the detail screen: from the list when it holds it, otherwise
/// fetched on its own — opened from home before the Events tab has loaded.
final eventDetailProvider = Provider.family<AsyncValue<EventItem?>, String>((
  ref,
  id,
) {
  final fromList = ref.watch(eventByIdProvider(id));
  if (fromList != null) return AsyncValue.data(fromList);
  final notifier = ref.watch(eventsListProvider.notifier);
  // Rebuild when registration or calendar flags change.
  ref.watch(eventsListProvider);
  return ref
      .watch(eventFetchProvider(id))
      .whenData((event) => event == null ? null : notifier.withFlags(event));
});

final eventFetchProvider = FutureProvider.autoDispose
    .family<EventItem?, String>(
      (ref, id) => ref.read(eventsRepositoryProvider).getEventById(id),
    );

/// The Events tab's list, plus the registration and calendar choices made
/// this session.
class EventsNotifier extends Notifier<AsyncValue<List<EventItem>>> {
  final _registered = <String>{};
  final _inCalendar = <String>{};

  @override
  AsyncValue<List<EventItem>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    try {
      final events = await ref.read(eventsRepositoryProvider).getEvents();
      state = AsyncValue.data(events.map(withFlags).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _load();
  }

  /// [event] with this session's registration and calendar choices applied.
  EventItem withFlags(EventItem event) => event.copyWith(
    isRegistered: event.isRegistered || _registered.contains(event.id),
    isAddedToCalendar:
        event.isAddedToCalendar || _inCalendar.contains(event.id),
  );

  void toggleRegistration(String id) => _toggle(_registered, id, (e) {
    return e.copyWith(isRegistered: !e.isRegistered);
  });

  void toggleCalendar(String id) => _toggle(_inCalendar, id, (e) {
    return e.copyWith(isAddedToCalendar: !e.isAddedToCalendar);
  });

  void _toggle(Set<String> set, String id, EventItem Function(EventItem) flip) {
    if (!set.remove(id)) set.add(id);
    final events = state.value;
    if (events == null) return;
    state = AsyncValue.data([for (final e in events) e.id == id ? flip(e) : e]);
  }
}
