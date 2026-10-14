import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/feed_repository.dart';
import '../../../shared/domain/content_item.dart';

/// One announcement, read from `GET /api/v1/content/{id}`.
///
/// autoDispose because the id is a family key: a user working through the
/// alerts list would otherwise leave one cached provider per announcement
/// opened.
final announcementProvider = FutureProvider.autoDispose
    .family<ContentItem, String>(
      (ref, id) => ref.watch(feedRepositoryProvider).item(id),
    );
