import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/features/calendar/data/official_calendar.dart';
import 'package:campus_update/features/calendar/presentation/widgets/official_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// How many times the calendar has been fetched.
int fetches = 0;

Future<void> pumpCard(WidgetTester t, OfficialCalendar? calendar) async {
  fetches = 0;
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        officialCalendarProvider.overrideWith((ref) async {
          fetches++;
          return calendar;
        }),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: OfficialCalendarCard()),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  test('reads the API response', () {
    final c = OfficialCalendar.fromJson({
      'id': 'c1',
      'institutionId': 'i1',
      'title': 'Academic Calendar',
      'academicSession': '2025/2026',
      'imageUrl': 'https://example.com/cal.png',
      'publishedAt': '2026-09-01T00:00:00Z',
    });
    expect(c.title, 'Academic Calendar');
    expect(c.academicSession, '2025/2026');
    expect(c.imageUrl, 'https://example.com/cal.png');
  });

  testWidgets('says so when the school has not published one', (t) async {
    await pumpCard(t, null);
    expect(find.text('Official academic calendar'), findsOneWidget);
    expect(find.text('Your school has not published it yet.'), findsOneWidget);
  });

  testWidgets('a published calendar shows its session and opens', (t) async {
    await pumpCard(
      t,
      const OfficialCalendar(
        title: 'Academic Calendar',
        academicSession: '2025/2026',
        imageUrl: 'https://example.com/cal.png',
      ),
    );
    expect(find.text('2025/2026 · Tap to view'), findsOneWidget);

    await t.tap(find.byType(OfficialCalendarCard));
    await t.pumpAndSettle();
    expect(find.text('Academic Calendar · 2025/2026'), findsOneWidget);
  });

  group('the session is named once', () {
    OfficialCalendar calendar(String title, String session) =>
        OfficialCalendar(title: title, academicSession: session, imageUrl: '');

    test('added when the title lacks it', () {
      expect(
        calendar('Academic Calendar', '2025/2026').heading,
        'Academic Calendar · 2025/2026',
      );
    });

    test('left off when the title already has it', () {
      expect(
        calendar('2026/2027 Academic Calendar -Test', '2026/2027').heading,
        '2026/2027 Academic Calendar -Test',
      );
    });

    test('left off when there is none', () {
      expect(calendar('Academic Calendar', '').heading, 'Academic Calendar');
    });
  });

  testWidgets('the card does not repeat a session the title names', (t) async {
    await pumpCard(
      t,
      const OfficialCalendar(
        title: '2026/2027 Academic Calendar',
        academicSession: '2026/2027',
        imageUrl: 'https://example.com/cal.png',
      ),
    );
    expect(find.text('Tap to view'), findsOneWidget);
  });

  testWidgets('a picture that will not load offers Try again', (t) async {
    // Tests have no network, so every picture fails to load, as the staging
    // calendar's placeholder link does on a phone.
    await pumpCard(
      t,
      const OfficialCalendar(
        title: 'Academic Calendar',
        academicSession: '2025/2026',
        imageUrl: 'https://campus-update.example/calendars/placeholder.png',
      ),
    );
    await t.tap(find.byType(OfficialCalendarCard));
    await t.pumpAndSettle();
    expect(find.text("Couldn't load the calendar."), findsOneWidget);
    final before = fetches;

    await t.tap(find.text('Try again'));
    await t.pumpAndSettle();

    // A fresh link was asked for, and the message and button are back.
    expect(fetches, before + 1);
    expect(find.text('Try again'), findsOneWidget);
  });
}
