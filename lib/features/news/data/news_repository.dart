import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/prefs_storage.dart';
import '../../../core/storage/storage_providers.dart';
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

  /// Ids of the saved articles, most recently saved first.
  List<String> savedIds();
}

/// News from `GET /api/v1/feed?type=News`.
///
/// The API has no bookmark endpoint yet, so saved articles are kept on the
/// phone: their ids only, per account, in [PrefsStorage]. They survive a
/// restart but not a reinstall, and do not follow the user to another phone.
class ApiNewsRepository implements NewsRepository {
  ApiNewsRepository(this._feed, this._storage);

  final FeedRepository _feed;
  final PrefsStorage _storage;

  /// [category] is sent to the API as is; null lists every category.
  @override
  Future<List<NewsItem>> getNews({
    String? category,
    String? query,
    int page = 1,
  }) async {
    final items = await _feed.feed(
      type: ContentType.news,
      search: query,
      category: category,
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
    final ids = savedIds();
    await _storage.setSavedArticleIds(
      ids.contains(id) ? [...ids.where((i) => i != id)] : [id, ...ids],
    );
  }

  @override
  List<String> savedIds() => _storage.savedArticleIds;

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
      isBookmarked: savedIds().contains(item.id),
      author: item.sourceName ?? 'Campus Update Staff',
      source: item.source,
    );
  }
}

/// Provider for the [NewsRepository].
///
/// How many news items one request asks for.
const newsPageSize = 20;

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return ApiNewsRepository(
    ref.watch(feedRepositoryProvider),
    ref.watch(prefsStorageProvider),
  );
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

/// The selected chip as the API's category filter: null for 'All'.
String? _apiCategory(String chip) => chip.toLowerCase() == 'all' ? null : chip;

/// The News tab's list for the selected category, loaded a page at a time.
/// Picking another chip starts again from the first page.
class NewsListNotifier extends Notifier<AsyncValue<List<NewsItem>>> {
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;
  String? _category;

  /// Bumped on every first-page load, so an answer for a chip the user has
  /// already moved on from is dropped.
  int _generation = 0;

  /// Whether another page may exist. A page shorter than [newsPageSize] was
  /// the last one.
  bool get hasMore => _hasMore;

  @override
  AsyncValue<List<NewsItem>> build() {
    _category = _apiCategory(ref.watch(selectedNewsCategoryProvider));
    _loadFirstPage();
    return const AsyncValue.loading();
  }

  Future<void> _loadFirstPage() async {
    final generation = ++_generation;
    _page = 1;
    _hasMore = true;
    try {
      final items = await ref
          .read(newsRepositoryProvider)
          .getNews(category: _category);
      if (generation != _generation) return;
      _hasMore = items.length >= newsPageSize;
      state = AsyncValue.data(items);
    } catch (e, st) {
      if (generation != _generation) return;
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
    final generation = _generation;
    try {
      final next = await ref
          .read(newsRepositoryProvider)
          .getNews(category: _category, page: _page + 1);
      if (generation != _generation) return;
      _page++;
      _hasMore = next.length >= newsPageSize;
      state = AsyncValue.data([...current, ...next]);
    } catch (_) {
      if (generation != _generation) return;
      _hasMore = false;
      state = AsyncValue.data([...current]);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> toggleBookmark(String id) async {
    // The repository keeps bookmarks even for items outside this list, such as
    // a search result further down than the pages loaded here.
    await ref.read(newsRepositoryProvider).toggleBookmark(id);
    // An article fetched on its own reads its bookmark back from the
    // repository, and the Saved articles screen lists what it holds.
    ref.invalidate(newsByIdProvider(id));
    ref.invalidate(savedArticlesProvider);
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

/// What the search screen lists: the API's matches for the query in the
/// selected category. With no query, it is the News tab's list.
final newsSearchResultsProvider = Provider<AsyncValue<List<NewsItem>>>((ref) {
  final query = ref.watch(newsSearchQueryProvider).trim();
  if (query.isEmpty) return ref.watch(newsListProvider);

  final category = _apiCategory(ref.watch(selectedNewsCategoryProvider));
  // Bookmarks toggled on this screen land in the list, so read them back from
  // there for the results it also holds.
  final loaded = {
    for (final item in ref.watch(newsListProvider).value ?? const <NewsItem>[])
      item.id: item,
  };
  return ref
      .watch(_newsSearchProvider((query: query, category: category)))
      .whenData(
        (items) => [
          for (final item in items)
            item.copyWith(
              isBookmarked: loaded[item.id]?.isBookmarked ?? item.isBookmarked,
            ),
        ],
      );
});

/// One search request per query and category. Waits for typing to pause
/// first, so a query typed letter by letter makes one call rather than one per
/// letter.
final _newsSearchProvider = FutureProvider.autoDispose
    .family<List<NewsItem>, ({String query, String? category})>((
      ref,
      search,
    ) async {
      var superseded = false;
      ref.onDispose(() => superseded = true);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (superseded) return const [];
      return ref
          .read(newsRepositoryProvider)
          .getNews(query: search.query, category: search.category);
    });

/// One article for the detail screen, always fetched from `/content/{id}` so
/// the API counts the view and the image link is fresh. The copy in the list,
/// when there is one, shows while the fetch is in flight or if it fails, and
/// its bookmark is the one shown, since the list is where it is toggled.
final newsArticleProvider = Provider.family<AsyncValue<NewsItem?>, String>((
  ref,
  id,
) {
  final fromList = ref.watch(newsItemByIdProvider(id));
  final fetched = ref.watch(newsByIdProvider(id));
  final article = fetched.value;
  if (article != null) {
    return AsyncValue.data(
      fromList == null
          ? article
          : article.copyWith(isBookmarked: fromList.isBookmarked),
    );
  }
  if (fromList != null) return AsyncValue.data(fromList);
  return fetched;
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

/// The Saved articles screen: each saved id read from `/content/{id}`, most
/// recently saved first. An article the API no longer returns — archived, or
/// out of the user's audience — is left out.
final savedArticlesProvider = FutureProvider.autoDispose<List<NewsItem>>((
  ref,
) async {
  final repo = ref.watch(newsRepositoryProvider);
  final articles = await Future.wait(
    repo.savedIds().map((id) async {
      try {
        return await repo.getNewsById(id);
      } catch (_) {
        return null;
      }
    }),
  );
  return articles.nonNulls.toList();
});
