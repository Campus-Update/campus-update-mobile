import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/news/presentation/screens/news_detail_screen.dart';
import 'package:campus_update/features/news/presentation/screens/news_list_screen.dart';
import 'package:campus_update/features/news/presentation/screens/news_search_screen.dart';
import 'package:campus_update/features/news/presentation/widgets/category_chips.dart';
import 'package:campus_update/features/news/presentation/widgets/news_card.dart';
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

  testWidgets('navigating to news section displays the News screen matching design', (
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

    // Tap on the News tab in the bottom bar
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Verify NewsListScreen is displayed
    expect(find.byType(NewsListScreen), findsOneWidget);

    // Verify Header elements
    expect(find.text('News'), findsWidgets); // header title and bottom nav tab
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Verify Category chips
    expect(find.byType(CategoryChips), findsOneWidget);
    for (final cat in ['All', 'General', 'Campus', 'Weather', 'Tech', 'Technology']) {
      expect(
        find.descendant(
          of: find.byType(CategoryChips),
          matching: find.text(cat),
        ),
        findsOneWidget,
      );
    }

    // Verify News cards
    expect(find.byType(NewsCard), findsWidgets);
    expect(find.textContaining('New Library Wing Opens'), findsOneWidget);
    expect(find.textContaining('City Council Approves'), findsOneWidget);
  });

  testWidgets('filtering news by category updates news list', (tester) async {
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

    // Navigate to News
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Tap 'Weather' filter chip
    await tester.tap(find.text('Weather'));
    await tester.pumpAndSettle();

    // Verify weather news is shown and other categories are filtered out
    expect(find.textContaining('Thunderstorm'), findsOneWidget);
    expect(find.textContaining('New Library Wing Opens'), findsNothing);
  });

  testWidgets('tapping bookmark icon toggles bookmark state', (tester) async {
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

    // Navigate to News
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Initial state: outline bookmark icons
    expect(find.byIcon(Icons.bookmark_border_rounded), findsWidgets);

    // Tap the bookmark icon on the first card
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pumpAndSettle();

    // Now at least one filled bookmark icon should exist
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });

  testWidgets('tapping news card opens NewsDetailScreen and can pop back', (
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

    // Navigate to News
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Tap the first news card
    await tester.tap(find.textContaining('New Library Wing Opens'));
    await tester.pumpAndSettle();

    // Verify NewsDetailScreen is opened
    expect(find.byType(NewsDetailScreen), findsOneWidget);
    expect(find.textContaining('New Library Wing Opens'), findsOneWidget);

    // Pop back to News list
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify returned to News list
    expect(find.byType(NewsListScreen), findsOneWidget);
  });

  testWidgets(
      'toggling search, typing unmatched query shows empty state, and clear restores list',
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

    // Navigate to News
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    // Tap search icon in header to navigate to NewsSearchScreen
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify NewsSearchScreen is opened with search text field
    expect(find.byType(NewsSearchScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);

    // Enter query 'nsn' matching the design screenshot
    await tester.enterText(find.byType(TextField), 'nsn');
    await tester.pumpAndSettle();

    // Verify exact empty state from design
    expect(find.text('No news articles found'), findsOneWidget);
    expect(
      find.text('Try adjusting your search query or selected category.'),
      findsOneWidget,
    );
    expect(find.byType(NewsCard), findsNothing);

    // Tap 'Clear' button to clear text
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Verify articles are restored on NewsSearchScreen
    expect(find.byType(NewsCard), findsWidgets);
    expect(find.text('No news articles found'), findsNothing);

    // Tap 'Clear' again (when empty) to pop back to NewsListScreen
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    // Verify returned to NewsListScreen
    expect(find.byType(NewsListScreen), findsOneWidget);
    expect(find.byType(NewsSearchScreen), findsNothing);
  });
}
