import 'package:campus_update/features/news/data/news_repository.dart';
import 'package:campus_update/features/news/domain/news_item.dart';
import 'package:campus_update/features/news/presentation/screens/news_list_screen.dart';
import 'package:campus_update/features/news/presentation/screens/news_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 25 articles, served a page at a time. Remembers what it was asked for.
class _RecordingNewsRepository implements NewsRepository {
  final pages = <int>[];
  final queries = <String>[];

  final _all = [
    for (var i = 1; i <= 25; i++)
      NewsItem(
        id: 'n$i',
        title: 'Article $i',
        category: 'General',
        summary: 'Summary $i',
      ),
  ];

  @override
  Future<List<NewsItem>> getNews({
    String? category,
    String? query,
    int page = 1,
  }) async {
    if (query != null) {
      queries.add(query);
      return _all.where((n) => n.title.contains(query)).toList();
    }
    pages.add(page);
    return _all.skip((page - 1) * newsPageSize).take(newsPageSize).toList();
  }

  @override
  Future<NewsItem?> getNewsById(String id) async => null;

  @override
  Future<void> toggleBookmark(String id) async {}
}

Widget _under(Widget screen, NewsRepository repo) => ProviderScope(
  overrides: [newsRepositoryProvider.overrideWithValue(repo)],
  child: MaterialApp(home: screen),
);

void main() {
  testWidgets('scrolling to the end of the list loads the next page', (
    tester,
  ) async {
    final repo = _RecordingNewsRepository();
    await tester.pumpWidget(_under(const NewsListScreen(), repo));
    await tester.pumpAndSettle();
    expect(repo.pages, [1]);

    await tester.scrollUntilVisible(
      find.text('Article 25'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    // Page 2 had 5 items, fewer than a full page, so paging stops there.
    expect(repo.pages, [1, 2]);
    expect(find.text('Article 25'), findsOneWidget);
  });

  testWidgets('search asks the API once typing pauses', (tester) async {
    final repo = _RecordingNewsRepository();
    await tester.pumpWidget(_under(const NewsSearchScreen(), repo));
    await tester.pumpAndSettle();

    // Typed a letter at a time, faster than the pause.
    for (final text in ['A', 'Ar', 'Article 2']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(repo.queries, ['Article 2']);
    expect(find.text('Article 21'), findsOneWidget);
    expect(find.text('Article 1'), findsNothing);
  });
}
