import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/domain/content_item.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/announcement_providers.dart';

/// One announcement, opened from an Active Alerts card.
///
/// Laid out like the news article — round back button, meta row, title, body —
/// with the urgency badge in place of the category pill, since priority is
/// what an alert is read for. No Save or Share bar: the API has no bookmark
/// and announcements are not shareable links yet.
class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.id});

  final String id;

  static const _gutter = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementProvider(id));
    final announcement = state.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            Expanded(
              child: state.isLoading && announcement == null
                  ? const Loader()
                  : state.hasError && announcement == null
                  ? ErrorState(
                      message: "Couldn't load this announcement.",
                      onRetry: () => ref.invalidate(announcementProvider(id)),
                    )
                  : announcement == null
                  ? const EmptyState(
                      icon: Icons.campaign_outlined,
                      message: 'Announcement not found.',
                    )
                  : _Body(announcement: announcement),
            ),
          ],
        ),
      ),
    );
  }
}

/// The round back button, then the section name beside it — the news detail
/// header, so the two screens open the same way.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AnnouncementDetailScreen._gutter,
        AppSpacing.md,
        AnnouncementDetailScreen._gutter,
        10,
      ),
      child: Row(
        children: [
          BackButtonCircle(),
          SizedBox(width: 24),
          Text(
            'Announcement',
            style: TextStyle(
              fontSize: 22,
              fontWeight: AppFonts.medium,
              color: AppColors.graphite,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.announcement});

  final ContentItem announcement;

  @override
  Widget build(BuildContext context) {
    final publishedAt = announcement.publishedAt;
    final meta = [
      announcement.sourceName,
      if (publishedAt != null) AppDateFormat.relative(publishedAt),
    ].whereType<String>().join(' · ');
    final imageUrl = announcement.imageUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AnnouncementDetailScreen._gutter,
        0,
        AnnouncementDetailScreen._gutter,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most announcements carry no image; the block is skipped rather
          // than drawn as an empty placeholder.
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 350 / 184,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.indigoSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              UrgencyBadge(urgency: announcement.urgency),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: AppFonts.regular,
                    color: AppColors.graphite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            announcement.title,
            // The news article's title: Archivo Medium 18 on a 22 line.
            style: const TextStyle(
              fontSize: 18,
              height: 22 / 18,
              fontWeight: AppFonts.medium,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            announcement.body.isNotEmpty
                ? announcement.body
                : (announcement.summary ?? ''),
            style: const TextStyle(
              fontSize: 12,
              height: 15 / 12,
              fontWeight: AppFonts.regular,
              color: AppColors.articleBody,
            ),
          ),
        ],
      ),
    );
  }
}
