import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/calendar/presentation/screens/calendar_detail_screen.dart';
import 'package:campus_update/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:campus_update/features/calendar/presentation/widgets/calendar_event_card.dart';
import 'package:campus_update/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:campus_update/shared/widgets/back_button_circle.dart';
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
    'navigating to calendar tab displays Calendar screen matching design',
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

      // Tap on Calendar tab in bottom navigation
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Verify CalendarScreen is displayed
      expect(find.byType(CalendarScreen), findsOneWidget);

      // Verify Header Elements
      expect(
        find.descendant(
          of: find.byType(CalendarScreen),
          matching: find.text('Calendar'),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // Verify Month Header & Navigation
      expect(find.text('July 2026'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsWidgets);

      // Verify Calendar Grid
      expect(find.byType(CalendarGrid), findsOneWidget);
      expect(find.text('Su'), findsOneWidget);
      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('Tu'), findsOneWidget);
      expect(find.text('We'), findsOneWidget);
      expect(find.text('Th'), findsOneWidget);
      expect(find.text('Fr'), findsOneWidget);
      expect(find.text('Sa'), findsOneWidget);

      // Verify "July 2026 Dates" section
      expect(find.text('July 2026 Dates'), findsOneWidget);
      expect(find.byType(CalendarEventCard), findsWidgets);

      // Verify specific academic dates from the design
      expect(find.text('Second semester lectures'), findsOneWidget);
      expect(find.text('Course registration opens'), findsOneWidget);
      expect(
        find.textContaining('Matriculation ceremony for the 2025/2026 session'),
        findsOneWidget,
      );
    },
  );

  testWidgets('tapping next and previous month navigates the calendar month', (
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

    // Navigate to Calendar
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('July 2026'), findsOneWidget);

    // Tap next month (the first chevron_right_rounded on the screen is in the month header)
    await tester.tap(find.byIcon(Icons.chevron_right_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('August 2026 Dates'), findsOneWidget);

    // Tap previous month twice (to June 2026)
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('July 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('June 2026'), findsOneWidget);
  });

  testWidgets(
    'tapping an event opens CalendarDetailScreen with details matching design and can pop back',
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

      // Navigate to Calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Tap on the Matriculation ceremony event
      final eventFinder = find.textContaining(
        'Matriculation ceremony for the 2025/2026 session',
      );
      await tester.ensureVisible(eventFinder);
      await tester.pumpAndSettle();
      await tester.tap(eventFinder);
      await tester.pumpAndSettle();

      // Verify CalendarDetailScreen is rendered
      expect(find.byType(CalendarDetailScreen), findsOneWidget);
      expect(find.byType(BackButtonCircle), findsOneWidget);

      // Verify event details matching the design
      expect(find.text('Academics'), findsOneWidget);
      expect(find.text('Official event'), findsOneWidget);
      expect(
        find.text('Matriculation ceremony for the 2025/2026 session'),
        findsOneWidget,
      );
      expect(find.text('Fri 25 September'), findsOneWidget);
      expect(find.text('9:00am — 12:00pm'), findsOneWidget);
      expect(find.text('University Sports Complex'), findsOneWidget);
      expect(
        find.text(
          'Attendance required for all fresh students. Academic gown compulsory.',
        ),
        findsOneWidget,
      );
      expect(find.text('Office of Student Affairs'), findsOneWidget);
      expect(find.text('Students'), findsOneWidget);
      expect(
        find.textContaining(
          'The matriculation ceremony for newly admitted students holds at the sports complex.',
        ),
        findsOneWidget,
      );
      expect(find.text('Save this events'), findsOneWidget);

      // Tap back button to return to calendar list
      await tester.tap(find.byType(BackButtonCircle));
      await tester.pumpAndSettle();

      // Verify back on CalendarScreen
      expect(find.byType(CalendarScreen), findsOneWidget);
    },
  );

  testWidgets(
    'tapping Save this events button toggles state on CalendarDetailScreen',
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

      // Navigate to Calendar
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // Open event detail
      final eventFinder = find.textContaining(
        'Matriculation ceremony for the 2025/2026 session',
      );
      await tester.ensureVisible(eventFinder);
      await tester.pumpAndSettle();
      await tester.tap(eventFinder);
      await tester.pumpAndSettle();

      // Verify Save button and tap it
      final saveButtonFinder = find.text('Save this events');
      await tester.ensureVisible(saveButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(saveButtonFinder);
      await tester.pumpAndSettle();

      // Verify toggled state
      expect(find.text('Saved to calendar'), findsOneWidget);
    },
  );
}
