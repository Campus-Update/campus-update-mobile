import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/events/data/event_actions.dart';
import 'package:campus_update/features/events/data/events_repository.dart';
import 'package:campus_update/features/events/domain/event_item.dart';
import 'package:campus_update/features/events/presentation/screens/event_detail_screen.dart';
import 'package:campus_update/features/events/presentation/screens/events_list_screen.dart';
import 'package:campus_update/features/events/presentation/widgets/event_card.dart';
import 'package:campus_update/features/events/presentation/widgets/featured_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/mock_events_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_feed_repository.dart';
import 'support/fake_schools.dart';

/// Records what the buttons asked for instead of leaving the app.
class _FakeEventActions implements EventActions {
  final registered = <String>[];
  final calendared = <String>[];
  bool opens = true;

  @override
  Future<bool> openRegistration(EventItem event) async {
    registered.add(event.id);
    return opens;
  }

  @override
  bool addToCalendar(EventItem event) {
    calendared.add(event.id);
    return true;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'navigating to events tab displays Upcoming Events matching design',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          fakeFeedOverride,
          fakeSchoolsOverride,
          eventsRepositoryProvider.overrideWithValue(
            const MockEventsRepository(),
          ),
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

      // Tap on the Events tab in bottom navigation
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Verify EventsListScreen is displayed
      expect(find.byType(EventsListScreen), findsOneWidget);

      // Verify Header elements matching design
      expect(find.text('Upcoming Events'), findsOneWidget);
      expect(
        find.text('Discover summits, panels, and town halls.'),
        findsOneWidget,
      );

      // Verify Featured Hero Event Card
      expect(find.byType(FeaturedEventCard), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);
      expect(find.text('Global Economic Summit 2024'), findsOneWidget);
      expect(find.text('Register Now'), findsOneWidget);

      // Verify "More events" section and list items
      expect(find.text('More events'), findsOneWidget);
      expect(find.byType(EventCard), findsWidgets);
      expect(
        find.textContaining('New Library Wing Opens Ahead of Schedule'),
        findsWidgets,
      );
      expect(find.text('Add to calendar'), findsWidgets);
    },
  );

  Future<_FakeEventActions> openEvents(WidgetTester tester) async {
    final actions = _FakeEventActions();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        fakeFeedOverride,
        fakeSchoolsOverride,
        eventsRepositoryProvider.overrideWithValue(
          const MockEventsRepository(),
        ),
        eventActionsProvider.overrideWithValue(actions),
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
    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();
    return actions;
  }

  testWidgets('Register Now opens the registration page', (tester) async {
    final actions = await openEvents(tester);

    await tester.tap(find.text('Register Now'));
    await tester.pumpAndSettle();

    expect(actions.registered, ['featured-1']);
  });

  testWidgets('a page that will not open says so', (tester) async {
    (await openEvents(tester)).opens = false;

    await tester.tap(find.text('Register Now'));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't open the registration page."), findsOneWidget);
  });

  testWidgets('Register Now with no sign-up page adds to the calendar', (
    tester,
  ) async {
    final actions = await openEvents(tester);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('New Library Wing Opens Ahead of Schedule').first,
    );
    await tester.pumpAndSettle();

    final register = find.descendant(
      of: find.byType(EventDetailScreen),
      matching: find.text('Register Now'),
    );
    await tester.ensureVisible(register);
    await tester.pumpAndSettle();
    await tester.tap(register);
    await tester.pumpAndSettle();

    expect(actions.registered, isEmpty);
    expect(actions.calendared, ['event-1']);
  });

  testWidgets('Add to calendar hands the event to the calendar', (
    tester,
  ) async {
    final actions = await openEvents(tester);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to calendar').first);
    await tester.pumpAndSettle();

    expect(actions.calendared, ['event-1']);
  });

  testWidgets(
    'tapping event card navigates to EventDetailScreen and can pop back',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          fakeFeedOverride,
          fakeSchoolsOverride,
          eventsRepositoryProvider.overrideWithValue(
            const MockEventsRepository(),
          ),
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

      // Navigate to Events
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Tap the featured event
      await tester.tap(find.text('Global Economic Summit 2024'));
      await tester.pumpAndSettle();

      // Verify EventDetailScreen is displayed
      expect(find.byType(EventDetailScreen), findsOneWidget);
      expect(find.text('About this Event'), findsOneWidget);

      // Pop back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back on EventsListScreen
      expect(find.byType(EventsListScreen), findsOneWidget);
    },
  );
}
