import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/events/presentation/screens/event_detail_screen.dart';
import 'package:campus_update/features/events/presentation/screens/events_list_screen.dart';
import 'package:campus_update/features/events/presentation/widgets/event_card.dart';
import 'package:campus_update/features/events/presentation/widgets/featured_event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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

      // Verify "This month" section and list items
      expect(find.text('This month'), findsOneWidget);
      expect(find.byType(EventCard), findsWidgets);
      expect(
        find.textContaining('New Library Wing Opens Ahead of Schedule'),
        findsWidgets,
      );
      expect(find.text('Add to calendar'), findsWidgets);
    },
  );

  testWidgets('tapping Register Now toggles registration state', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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

    // Tap Register Now
    await tester.tap(find.text('Register Now'));
    await tester.pumpAndSettle();

    // Should now show "Registered"
    expect(find.text('Registered'), findsOneWidget);
    expect(
      find.textContaining('Successfully registered for Global Economic Summit'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Add to calendar toggles calendar state', (tester) async {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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

    // Scroll down to make monthly events visible
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    // Tap the first "Add to calendar" button
    await tester.tap(find.text('Add to calendar').first);
    await tester.pumpAndSettle();

    // Should now show "In calendar"
    expect(find.text('In calendar'), findsOneWidget);
    expect(find.text('Event added to your calendar!'), findsOneWidget);
  });

  testWidgets(
    'tapping event card navigates to EventDetailScreen and can pop back',
    (tester) async {
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
