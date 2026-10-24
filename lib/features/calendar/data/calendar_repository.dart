import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../events/data/events_repository.dart';
import '../../events/domain/event_item.dart';

/// Tracks the active month displayed on the calendar grid. Opens on the
/// current month.
final activeMonthProvider = NotifierProvider<ActiveMonthNotifier, DateTime>(
  ActiveMonthNotifier.new,
);

class ActiveMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }
}

/// The day picked on the grid, which narrows the list to that day. Null shows
/// the whole month.
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime?>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() {
    // A new month starts unfiltered.
    ref.watch(activeMonthProvider);
    return null;
  }

  /// Picks [date], or clears the pick when it is already the picked day.
  void selectDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    state = state == day ? null : day;
  }

  void clearSelection() {
    state = null;
  }
}

/// The API has no dated academic calendar entries, only events with a start
/// and an end, so the grid is drawn from the same events the Events tab
/// lists. Grouping them by month and day is only arranging what the API sent.
final monthEventsProvider = Provider<AsyncValue<List<EventItem>>>((ref) {
  final month = ref.watch(activeMonthProvider);
  final first = DateTime(month.year, month.month);
  final last = DateTime(month.year, month.month + 1, 0);
  return ref
      .watch(eventsListProvider)
      .whenData(
        (events) => events.where((e) => _overlaps(e, first, last)).toList(),
      );
});

/// What the list under the grid shows: the picked day's events, or the
/// month's when no day is picked.
final listedEventsProvider = Provider<AsyncValue<List<EventItem>>>((ref) {
  final day = ref.watch(selectedDateProvider);
  final month = ref.watch(monthEventsProvider);
  if (day == null) return month;
  return month.whenData(
    (events) => events.where((e) => _overlaps(e, day, day)).toList(),
  );
});

/// The days of the active month that have an event, for the grid's dots. An
/// event over several days marks each of them.
final eventDaysInActiveMonthProvider = Provider<Set<int>>((ref) {
  final month = ref.watch(activeMonthProvider);
  final events = ref.watch(monthEventsProvider).value ?? const <EventItem>[];
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  return {
    for (var d = 1; d <= daysInMonth; d++)
      if (events.any((e) {
        final day = DateTime(month.year, month.month, d);
        return _overlaps(e, day, day);
      }))
        d,
  };
});

/// Whether [event] falls on any day from [first] to [last], inclusive, in the
/// phone's time zone. An undated event falls on none.
bool _overlaps(EventItem event, DateTime first, DateTime last) {
  final start = event.startsAt?.toLocal();
  if (start == null) return false;
  final end = (event.endsAt ?? start).toLocal();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  return !startDay.isAfter(last) && !endDay.isBefore(first);
}
