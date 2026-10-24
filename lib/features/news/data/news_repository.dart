import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../../shared/domain/content_item.dart';
import '../../../shared/domain/content_source.dart';
import '../../../shared/utils/date_format.dart';
import '../domain/news_item.dart';

abstract class NewsRepository {
  /// Pages hold [newsPageSize] items; a shorter page is the last one.
  Future<List<NewsItem>> getNews({
    String? category,
    String? query,
    int page = 1,
  });
  Future<NewsItem?> getNewsById(String id);
  Future<void> toggleBookmark(String id);
}

/// News from `GET /api/v1/feed?type=News`.
///
/// The API has no bookmark endpoint, so bookmarks live in memory for the
/// session and are lost on restart.
class ApiNewsRepository implements NewsRepository {
  ApiNewsRepository(this._feed);

  final FeedRepository _feed;
  final _bookmarked = <String>{};

  /// [category] is ignored: the API has no category to filter on yet, and the
  /// list screen filters what comes back.
  @override
  Future<List<NewsItem>> getNews({
    String? category,
    String? query,
    int page = 1,
  }) async {
    final items = await _feed.feed(
      type: ContentType.news,
      search: query,
      page: page,
      pageSize: newsPageSize,
    );
    return items.map(_toNewsItem).toList();
  }

  @override
  Future<NewsItem?> getNewsById(String id) async =>
      _toNewsItem(await _feed.item(id));

  @override
  Future<void> toggleBookmark(String id) async {
    if (!_bookmarked.remove(id)) _bookmarked.add(id);
  }

  NewsItem _toNewsItem(ContentItem item) {
    final publishedAt = item.publishedAt;
    return NewsItem(
      id: item.id,
      title: item.title,
      category: item.label,
      summary: item.excerpt,
      body: item.body,
      imageUrl: item.imageUrl,
      timeAgo: publishedAt == null
          ? 'Recent update'
          : AppDateFormat.relative(publishedAt),
      publishedAt: publishedAt,
      isBookmarked: _bookmarked.contains(item.id),
      author: item.sourceName ?? 'Campus Update Staff',
      source: item.source,
    );
  }
}

/// Provider for the [NewsRepository].
///
/// How many news items one request asks for.
const newsPageSize = 20;

/// Tests override this with [MockNewsRepository].
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return ApiNewsRepository(ref.watch(feedRepositoryProvider));
});

/// State notifier managing selected news category filter.
class SelectedNewsCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All';

  void select(String category) => state = category;
}

final selectedNewsCategoryProvider =
    NotifierProvider<SelectedNewsCategoryNotifier, String>(
      SelectedNewsCategoryNotifier.new,
    );

/// State notifier managing news search query filter.
class NewsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final newsSearchQueryProvider =
    NotifierProvider<NewsSearchQueryNotifier, String>(
      NewsSearchQueryNotifier.new,
    );

/// The News tab's list, loaded a page at a time.
class NewsListNotifier extends Notifier<AsyncValue<List<NewsItem>>> {
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  /// Whether another page may exist. A page shorter than [newsPageSize] was
  /// the last one.
  bool get hasMore => _hasMore;

  @override
  AsyncValue<List<NewsItem>> build() {
    _loadFirstPage();
    return const AsyncValue.loading();
  }

  Future<void> _loadFirstPage() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await ref.read(newsRepositoryProvider).getNews();
      _hasMore = items.length >= newsPageSize;
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadFirstPage();
  }

  /// Appends the next page. Does nothing while a page is already loading or
  /// once the last page is in. A failure stops paging rather than replacing
  /// the list with an error, so what is already on screen stays.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !_hasMore || _loadingMore) return;
    _loadingMore = true;
    try {
      final next = await ref
          .read(newsRepositoryProvider)
          .getNews(page: _page + 1);
      _page++;
      _hasMore = next.length >= newsPageSize;
      state = AsyncValue.data([...current, ...next]);
    } catch (_) {
      _hasMore = false;
      state = AsyncValue.data([...current]);
    } finally {
      _loadingMore = false;
    }
  }

  void toggleBookmark(String id) {
    // The repository keeps bookmarks even for items outside this list, such as
    // a search result further down than the pages loaded here.
    ref.read(newsRepositoryProvider).toggleBookmark(id);
    // An article fetched on its own reads its bookmark back from the
    // repository.
    ref.invalidate(newsByIdProvider(id));
    state.whenData((items) {
      state = AsyncValue.data([
        for (final item in items)
          item.id == id
              ? item.copyWith(isBookmarked: !item.isBookmarked)
              : item,
      ]);
    });
  }
}

final newsListProvider =
    NotifierProvider<NewsListNotifier, AsyncValue<List<NewsItem>>>(
      NewsListNotifier.new,
    );

/// The loaded list narrowed to the selected category chip.
///
/// The API has no category filter yet, so this happens on the phone.
final filteredNewsListProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final category = ref.watch(selectedNewsCategoryProvider);
  return ref
      .watch(newsListProvider)
      .whenData((items) => _inCategory(items, category));
});

/// What the search screen lists: the API's matches for the query, narrowed to
/// the selected chip. With no query, it is the loaded list.
final newsSearchResultsProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final query = ref.watch(newsSearchQueryProvider).trim();
  if (query.isEmpty) return ref.watch(filteredNewsListProvider);

  final category = ref.watch(selectedNewsCategoryProvider);
  // Bookmarks toggled on this screen land in the list, so read them back from
  // there for the results it also holds.
  final loaded = {
    for (final item in ref.watch(newsListProvider).value ?? const <NewsItem>[])
      item.id: item,
  };
  return ref
      .watch(_newsSearchProvider(query))
      .whenData(
        (items) => _inCategory([
          for (final item in items)
            item.copyWith(
              isBookmarked: loaded[item.id]?.isBookmarked ?? item.isBookmarked,
            ),
        ], category),
      );
});

/// One search request per query. Waits for typing to pause first, so a query
/// typed letter by letter makes one call rather than one per letter.
final _newsSearchProvider = FutureProvider.autoDispose
    .family<List<NewsItem>, String>((ref, query) async {
      var superseded = false;
      ref.onDispose(() => superseded = true);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (superseded) return const [];
      return ref.read(newsRepositoryProvider).getNews(query: query);
    });

List<NewsItem> _inCategory(List<NewsItem> items, String category) {
  if (category.toLowerCase() == 'all') return items;
  final filter = category.toLowerCase();
  return items.where((item) => item.category.toLowerCase() == filter).toList();
}

/// One article for the detail screen.
///
/// Read from the News list when it holds the article, which keeps bookmarks in
/// step with it. Otherwise — opened from home before the News tab has loaded,
/// say — fetched on its own with `GET /content/{id}`.
final newsArticleProvider = Provider.family<AsyncValue<NewsItem?>, String>((
  ref,
  id,
) {
  final fromList = ref.watch(newsItemByIdProvider(id));
  if (fromList != null) return AsyncValue.data(fromList);
  return ref.watch(newsByIdProvider(id));
});

/// A single article straight from the repository.
final newsByIdProvider = FutureProvider.autoDispose.family<NewsItem?, String>(
  (ref, id) => ref.read(newsRepositoryProvider).getNewsById(id),
);

/// Family provider to fetch a single news item by id.
final newsItemByIdProvider = Provider.family<NewsItem?, String>((ref, id) {
  final newsState = ref.watch(newsListProvider);
  return newsState.value?.cast<NewsItem?>().firstWhere(
    (item) => item?.id == id,
    orElse: () => null,
  );
});
