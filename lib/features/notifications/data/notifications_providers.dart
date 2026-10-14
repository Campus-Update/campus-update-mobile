import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../../shared/domain/content_item.dart';
import '../../../shared/domain/content_source.dart';

/// Active alerts feed — all announcement-type content, optionally narrowed by
/// urgency or a search term.
///
/// The screen rebuilds this provider whenever the user changes the urgency
/// filter or types a search query.
final alertsFeedProvider =
    FutureProvider.family<List<ContentItem>, AlertsFilter>(
      (ref, filter) => ref
          .watch(feedRepositoryProvider)
          .feed(
            type: ContentType.announcement,
            urgency: filter.urgency,
            search: filter.search,
          ),
    );

/// Parameters for [alertsFeedProvider].
class AlertsFilter {
  const AlertsFilter({this.urgency, this.search});

  final Urgency? urgency;
  final String? search;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsFilter &&
          other.urgency == urgency &&
          other.search == search;

  @override
  int get hashCode => Object.hash(urgency, search);
}
