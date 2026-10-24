import 'package:campus_update/core/storage/prefs_storage.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/news/data/news_repository.dart';
import 'package:campus_update/features/profile/presentation/screens/saved_articles_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_feed_repository.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'current_user_email': 'ada@school.edu',
    });
    prefs = await SharedPreferences.getInstance();
  });

  ApiNewsRepository repo() =>
      ApiNewsRepository(FakeFeedRepository(), PrefsStorage(prefs));

  test('a saved article survives a restart, newest first', () async {
    await repo().toggleBookmark('n1');
    await repo().toggleBookmark('n2');

    // A fresh repository stands in for the app starting again.
    expect(repo().savedIds(), ['n2', 'n1']);
    expect((await repo().getNewsById('n1'))!.isBookmarked, isTrue);

    await repo().toggleBookmark('n1');
    expect(repo().savedIds(), ['n2']);
  });

  test('each account keeps its own saved articles', () async {
    await repo().toggleBookmark('n1');
    await PrefsStorage(prefs).setCurrentUserEmail('bo@school.edu');

    expect(repo().savedIds(), isEmpty);
  });

  Widget screen() => ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      fakeFeedOverride,
    ],
    child: const MaterialApp(home: SavedArticlesScreen()),
  );

  testWidgets('lists the saved articles, read from the API', (tester) async {
    await repo().toggleBookmark('n3');

    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    expect(find.text('Hostel Wi-Fi Upgrade Completed'), findsOneWidget);
  });

  testWidgets('unsaving takes an article off the list', (tester) async {
    await repo().toggleBookmark('n3');
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();

    expect(find.text('Hostel Wi-Fi Upgrade Completed'), findsNothing);
    expect(find.text('No saved articles yet'), findsOneWidget);
  });

  testWidgets('an article the API no longer returns is left out', (
    tester,
  ) async {
    await repo().toggleBookmark('gone');
    await repo().toggleBookmark('n3');

    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();

    expect(find.text('Hostel Wi-Fi Upgrade Completed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
