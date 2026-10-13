import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:campus_update/features/notifications/presentation/widgets/alert_card.dart';
import 'package:campus_update/features/notifications/presentation/widgets/alert_filter_chips.dart';
import 'package:campus_update/features/notifications/presentation/widgets/alerts_empty_state.dart';
import 'package:campus_update/features/notifications/presentation/widgets/alerts_search_bar.dart';
import 'package:campus_update/shared/data/feed_repository.dart';
import 'package:campus_update/shared/domain/content_item.dart';
import 'package:campus_update/shared/domain/content_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_feed_repository.dart';

class _FakeAnnouncementsFeedRepository extends FakeFeedRepository {
  @override
  Future<List<ContentItem>> feed({
    ContentType? type,
    Urgency? urgency,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    calls++;
    var list = [
      ContentItem(
        id: 'a1',
        title: 'CSC 304 exam venue moved to Auditorium B',
        body: 'The exam venue has moved.',
        type: ContentType.announcement,
        urgency: Urgency.urgent,
        source: ContentSource.officialSchool,
        publishedAt: DateTime.now().subtract(const Duration(minutes: 32)),
      ),
      ContentItem(
        id: 'a2',
        title: 'Second semester course registration closes 26 September',
        body: 'Course registration deadline approaching.',
        type: ContentType.announcement,
        urgency: Urgency.important,
        source: ContentSource.officialSchool,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ContentItem(
        id: 'a3',
        title: 'Library extends weekend opening hours',
        body: 'Opening hours extended for all students.',
        type: ContentType.announcement,
        urgency: Urgency.normal,
        source: ContentSource.officialSchool,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ContentItem(
        id: 'a4',
        title: 'CSC 304 lab submission deadline extended to Friday',
        body: 'Deadline pushed for CSC 304 students.',
        type: ContentType.announcement,
        urgency: Urgency.normal,
        source: ContentSource.officialSchool,
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    if (urgency != null) {
      list = list.where((i) => i.urgency == urgency).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list
          .where(
            (i) =>
                i.title.toLowerCase().contains(q) ||
                i.body.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets(
    'displays Active Alerts screen with header, filter chips and alert cards',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          feedRepositoryProvider.overrideWithValue(
            _FakeAnnouncementsFeedRepository(),
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

      // Open Notifications
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('Active Alerts'), findsOneWidget);
      expect(
        find.text('Real-time emergency and advisory updates for your area.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify category filter chips
      expect(
        find.descendant(
          of: find.byType(AlertFilterChips),
          matching: find.text('All'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertFilterChips),
          matching: find.text('Normal'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertFilterChips),
          matching: find.text('Important'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertFilterChips),
          matching: find.text('Urgent'),
        ),
        findsOneWidget,
      );

      // Verify alert cards
      expect(find.byType(AlertCard), findsNWidgets(4));
      expect(
        find.text('CSC 304 exam venue moved to Auditorium B'),
        findsOneWidget,
      );
      expect(
        find.text('Second semester course registration closes 26 September'),
        findsOneWidget,
      );
      expect(
        find.text('Library extends weekend opening hours'),
        findsOneWidget,
      );
    },
  );

  testWidgets('filtering by urgency updates displayed alert cards', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        feedRepositoryProvider.overrideWithValue(
          _FakeAnnouncementsFeedRepository(),
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

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    // Tap Urgent chip
    await tester.tap(
      find.descendant(
        of: find.byType(AlertFilterChips),
        matching: find.text('Urgent'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertCard), findsOneWidget);
    expect(
      find.text('CSC 304 exam venue moved to Auditorium B'),
      findsOneWidget,
    );

    // Tap Important chip
    await tester.tap(
      find.descendant(
        of: find.byType(AlertFilterChips),
        matching: find.text('Important'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertCard), findsOneWidget);
    expect(
      find.text('Second semester course registration closes 26 September'),
      findsOneWidget,
    );

    // Tap Normal chip
    await tester.tap(
      find.descendant(
        of: find.byType(AlertFilterChips),
        matching: find.text('Normal'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertCard), findsNWidgets(2));

    // Tap All to restore
    await tester.tap(
      find.descendant(
        of: find.byType(AlertFilterChips),
        matching: find.text('All'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertCard), findsNWidgets(4));
  });

  testWidgets('search filters alerts and shows result counter banner and footer', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        feedRepositoryProvider.overrideWithValue(
          _FakeAnnouncementsFeedRepository(),
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

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.byType(AlertsSearchBar), findsOneWidget);
    expect(find.text('Search by title, or keywords'), findsWidgets);

    // Enter query
    await tester.enterText(find.byType(TextField), 'CSC 304');
    await tester.pumpAndSettle();

    // Result counter banner
    expect(find.text('2 results for "CSC 304"'), findsOneWidget);
    expect(find.byType(AlertCard), findsNWidgets(2));

    // Clear search and cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertsSearchBar), findsNothing);
    expect(find.byType(AlertCard), findsNWidgets(4));
  });

  testWidgets('unmatched search query displays empty state', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        feedRepositoryProvider.overrideWithValue(
          _FakeAnnouncementsFeedRepository(),
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

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Nonexistent query 999');
    await tester.pumpAndSettle();

    expect(find.byType(AlertsEmptyState), findsOneWidget);
    expect(find.text('No results found'), findsOneWidget);
    expect(
      find.text('Try a different search term or filter.'),
      findsOneWidget,
    );
  });
}
