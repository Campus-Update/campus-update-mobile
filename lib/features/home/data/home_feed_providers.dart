import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../events/data/events_repository.dart';
import '../../../shared/domain/content_item.dart';
import '../../../shared/domain/content_source.dart';

/// How many items each home section shows before 'See all'.
const _sectionSize = 3;

/// The home tab picked under the greeting, as the API's category: null for
/// 'For You', which is the feed as the API narrows it for the user.
class HomeCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

final homeCategoryProvider = NotifierProvider<HomeCategoryNotifier, String?>(
  HomeCategoryNotifier.new,
);

/// The breaking-news hero: urgent items, newest first.
final breakingNewsProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref
      .watch(feedRepositoryProvider)
      .feed(
        urgency: Urgency.urgent,
        category: ref.watch(homeCategoryProvider),
        pageSize: _sectionSize,
      ),
);

final latestNewsProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref
      .watch(feedRepositoryProvider)
      .feed(
        type: ContentType.news,
        category: ref.watch(homeCategoryProvider),
        pageSize: _sectionSize,
      ),
);

/// The next events, the same list the Events tab starts with.
final upcomingEventsProvider = FutureProvider<List<ContentItem>>(
  (ref) async => (await upcomingEvents(
    ref.watch(feedRepositoryProvider),
    category: ref.watch(homeCategoryProvider),
  )).take(_sectionSize).toList(),
);
