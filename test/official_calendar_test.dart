import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/features/calendar/data/official_calendar.dart';
import 'package:campus_update/features/calendar/presentation/widgets/official_calendar_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpCard(WidgetTester t, OfficialCalendar? calendar) async {
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        officialCalendarProvider.overrideWith((ref) async => calendar),
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
}
