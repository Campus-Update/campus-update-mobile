import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../../shared/domain/content_item.dart';
import '../../../shared/domain/content_source.dart';

/// How many items each home section shows before 'See all'.
const _sectionSize = 3;

/// The breaking-news hero: urgent items, newest first.
final breakingNewsProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref
      .watch(feedRepositoryProvider)
      .feed(urgency: Urgency.urgent, pageSize: _sectionSize),
);

final latestNewsProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref
      .watch(feedRepositoryProvider)
      .feed(type: ContentType.news, pageSize: _sectionSize),
);

final upcomingEventsProvider = FutureProvider<List<ContentItem>>(
  (ref) => ref
      .watch(feedRepositoryProvider)
      .feed(type: ContentType.event, pageSize: _sectionSize),
);
