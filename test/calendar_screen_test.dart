import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/calendar/data/calendar_repository.dart';
import 'package:campus_update/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:campus_update/features/calendar/presentation/widgets/calendar_event_card.dart';
import 'package:campus_update/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:campus_update/features/events/data/events_repository.dart';
import 'package:campus_update/features/events/domain/event_item.dart';
import 'package:campus_update/features/events/presentation/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_calendar.dart';
import 'support/fake_feed_repository.dart';
import 'support/fake_schools.dart';

/// The calendar opens on the current month; these tests start on July 2026,
/// where [_Events] has its dates.
class _July2026 extends ActiveMonthNotifier {
  @override
  DateTime build() => DateTime(2026, 7);
}

/// Events as the API would send them: one over two days, one on a single
/// day, one in August and one with no date yet.
class _Events implements EventsRepository {
  static final events = [
    EventItem(
      id: 'fair',
      title: 'Career fair',
      description: 'Meet employers.',
      location: 'Main hall',
      dateFormatted: 'JUL 15, 2026',
      time: '9:00 AM - 4:00 PM',
      startsAt: DateTime(2026, 7, 15, 9),
      endsAt: DateTime(2026, 7, 16, 16),
    ),
    EventItem(
      id: 'debate',
      title: 'Inter-faculty debate',
      description: 'The final round.',
      location: 'Senate building',
      dateFormatted: 'JUL 20, 2026',
      time: '2:00 PM',
      startsAt: DateTime(2026, 7, 20, 14),
    ),
    EventItem(
      id: 'games',
      title: 'Sports week',
      description: 'Inter-hall games.',
      location: 'Sports complex',
      dateFormatted: 'AUG 3, 2026',
      startsAt: DateTime(2026, 8, 3, 8),
    ),
    const EventItem(
      id: 'tba',
      title: 'Alumni dinner',
      description: 'Date to come.',
      location: 'Registry',
      dateFormatted: 'Date to be announced',
      time: '',
    ),
  ];

  @override
  Future<List<EventItem>> getEvents() async => events;

  @override
  Future<EventItem?> getEventById(String id) async =>
      events.where((e) => e.id == id).firstOrNull;
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> openCalendar(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        fakeFeedOverride,
        fakeSchoolsOverride,
        fakeCalendarOverride,
        eventsRepositoryProvider.overrideWithValue(_Events()),
        activeMonthProvider.overrideWith(_July2026.new),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();
  }

  testWidgets('the month lists its events from the API', (tester) async {
    await openCalendar(tester);

    expect(find.byType(CalendarScreen), findsOneWidget);
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.byType(CalendarGrid), findsOneWidget);
    expect(find.text('July 2026 events'), findsOneWidget);

    // July's two dated events; August's and the undated one stay out.
    expect(find.byType(CalendarEventCard), findsNWidgets(2));
    expect(find.text('Career fair'), findsOneWidget);
    expect(find.text('Inter-faculty debate'), findsOneWidget);
    expect(find.text('Sports week'), findsNothing);
    expect(find.text('Alumni dinner'), findsNothing);
    expect(find.text('9:00 AM - 4:00 PM · Main hall'), findsOneWidget);
  });

  testWidgets('every day of an event gets a dot', (tester) async {
    final container = ProviderContainer(
      overrides: [
        eventsRepositoryProvider.overrideWithValue(_Events()),
        activeMonthProvider.overrideWith(_July2026.new),
      ],
    );
    addTearDown(container.dispose);
    container.listen(eventsListProvider, (_, _) {});
    await tester.pump();

    expect(container.read(eventDaysInActiveMonthProvider), {15, 16, 20});
  });

  testWidgets('picking a day narrows the list, and Whole month undoes it', (
    tester,
  ) async {
    await openCalendar(tester);

    // The 16th is the career fair's second day.
    await tester.tap(
      find.descendant(of: find.byType(CalendarGrid), matching: find.text('16')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Events on Thu 16 July'), findsOneWidget);
    expect(find.text('Career fair'), findsOneWidget);
    expect(find.text('Inter-faculty debate'), findsNothing);

    await tester.tap(find.text('Whole month'));
    await tester.pumpAndSettle();

    expect(find.text('July 2026 events'), findsOneWidget);
    expect(find.text('Inter-faculty debate'), findsOneWidget);
  });

  testWidgets('a day with nothing on says so', (tester) async {
    await openCalendar(tester);

    await tester.tap(
      find.descendant(of: find.byType(CalendarGrid), matching: find.text('2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('No events on this day.'), findsOneWidget);
  });

  testWidgets('next and previous change the month and its events', (
    tester,
  ) async {
    await openCalendar(tester);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Sports week'), findsOneWidget);
    expect(find.text('Career fair'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(find.text('June 2026'), findsOneWidget);
    expect(find.text('No events this month.'), findsOneWidget);
  });

  testWidgets('an event opens the event detail', (tester) async {
    await openCalendar(tester);

    final fair = find.text('Career fair');
    await tester.ensureVisible(fair);
    await tester.pumpAndSettle();
    await tester.tap(fair);
    await tester.pumpAndSettle();

    expect(find.byType(EventDetailScreen), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);
  });
}
