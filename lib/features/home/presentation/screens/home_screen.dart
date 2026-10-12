import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/domain/content_item.dart';
import '../../../../shared/utils/date_format.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/home_feed_providers.dart';

/// The central landing screen matching the UI design specification.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.hasPendingProfile, this.userName});

  /// Explicit override for whether the user has a pending profile to complete.
  /// If null, reads from [pendingProfileProvider].
  final bool? hasPendingProfile;

  /// Optional explicit override for the displayed user name.
  /// If null, reads from [userProfileProvider].
  final String? userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showProfileCard =
        (hasPendingProfile ?? ref.watch(pendingProfileProvider)) == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.indigo,
          onRefresh: () => _refresh(ref),
          child: SingleChildScrollView(
            // Pullable even when the feed is too short to scroll.
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.gutter,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(userName: userName),
                // Measured ~13pt from the greeting to the tab labels and ~11pt
                // from the underline to the card; the tabs carry 6pt of tap
                // padding either side, so these are the remainder.
                const SizedBox(height: AppSpacing.sm),
                const _CategoryTabs(),
                const SizedBox(height: AppSpacing.xs),
                if (showProfileCard) ...[
                  const _ProfileCompletionCard(),
                  const SizedBox(height: AppSpacing.lg),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
                ],
                // Carries its own gap below, so nothing is left behind when
                // there is no breaking news.
                const _BreakingNewsSection(),
                const _LatestNewsSection(),
                const SizedBox(height: AppSpacing.xl),
                const _UpcomingEventsSection(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetches every feed section again. A section that fails shows its own
  /// error state, so a failure here only needs to end the spinner.
  Future<void> _refresh(WidgetRef ref) async {
    try {
      await Future.wait([
        ref.refresh(breakingNewsProvider.future),
        ref.refresh(latestNewsProvider.future),
        ref.refresh(upcomingEventsProvider.future),
      ]);
    } catch (_) {}
  }
}

/// Top header containing the Campus Update badge, greeting, and action buttons.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final name = userName ?? profile?.displayName;
    final greeting = (name != null && name.trim().isNotEmpty)
        ? 'Welcome, ${name.trim()}!'
        : 'Welcome!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campus Update pill tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            'Campus Update',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366F1),
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Feed refresh
                  },
                  icon: const Icon(
                    Icons.sync_rounded,
                    size: 24,
                    color: Color(0xFF374151),
                  ),
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                const SizedBox(width: 8),
                const NotificationButton(color: Color(0xFF374151)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Profile setup card encouraging the user to tailor their university feed.
class _ProfileCompletionCard extends ConsumerWidget {
  const _ProfileCompletionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Gradient icon container with sparkle symbol
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B4DFF), Color(0xFF362FA3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(child: _SparkleFeedIcon()),
          ),
          const SizedBox(height: 18),
          const Text(
            'Complete your profile to sharpen your feed',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are seeing everything from Lead City University. Tell us your faculty, department and level and we can put what matters to you first.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          // The design draws the shared button here: the same top-to-bottom
          // gradient (sampled #5913E5 down to #391394) at the same 50pt
          // height, with its quieter white twin beside it.
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Add details',
                  onPressed: () => context.push(Routes.editProfile),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Not now',
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      ref.read(pendingProfileProvider.notifier).dismiss(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom icon painter depicting the sparkle card / feed symbol.
class _SparkleFeedIcon extends StatelessWidget {
  const _SparkleFeedIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(painter: _FeedIconPainter()),
    );
  }
}

class _FeedIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // Line 1 (top)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 6, 18, 3.2),
        const Radius.circular(2),
      ),
      linePaint,
    );

    // Line 2 (middle)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 13.5, 23, 3.2),
        const Radius.circular(2),
      ),
      linePaint,
    );

    // Line 3 (bottom)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 21, 14, 3.2),
        const Radius.circular(2),
      ),
      linePaint,
    );

    // Sparkle 4-pointed star on the right
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const cx = 24.5;
    const cy = 20.5;
    const outerR = 4.5;

    final cleanStar = Path()
      ..moveTo(cx, cy - outerR)
      ..quadraticBezierTo(cx, cy, cx + outerR, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + outerR)
      ..quadraticBezierTo(cx, cy, cx - outerR, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - outerR)
      ..close();

    canvas.drawPath(cleanStar, starPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category filter strip under the greeting.
///
/// Measured off the home design export: all six labels share one light grey
/// (sampled #80-#95, against #101010 for the greeting on the same frame, so
/// none of them is near-black), and the selected one is marked by an
/// underline rather than a pill, a fill or a colour change.
class _CategoryTabs extends StatefulWidget {
  const _CategoryTabs();

  @override
  State<_CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<_CategoryTabs> {
  static const _categories = [
    'All',
    'For You',
    'General',
    'Campus',
    'Technology',
    'Health',
  ];

  /// The design underlines 'For You', not 'All'.
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    // Scrolls horizontally, since at 13pt the six labels can run past the
    // edge of a narrow phone.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _categories.length; i++)
            _CategoryTab(
              // 'General', 'Campus' and 'Technology' are also category labels
              // on the Latest News items below, so the tabs carry keys to stay
              // unambiguous.
              key: ValueKey('category-tab-${_categories[i]}'),
              label: _categories[i],
              selected: i == _selected,
              isLast: i == _categories.length - 1,
              onTap: () => setState(() => _selected = i),
            ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    super.key,
    required this.label,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  // The same size as the News tab's category chips, so the two filter strips
  // read alike. The home export measures nearer 10pt.
  static const _fontSize = 13.0;

  /// How far the underline runs past the label on each side. The design's
  /// underline is 38.5pt under a 32.7pt label, so just under 3pt a side.
  static const _overhang = 3.0;

  /// Gap between two labels. The design leaves ~23pt between glyph boxes,
  /// which is this plus the two side bearings.
  static const _gap = 22.0;

  static const _underlineGap = 6.0;
  static const _underlineWidth = 2.0;

  /// Padding that only grows the tap target. It sits outside the underlined
  /// box, so it does not move the underline relative to the label.
  static const _tapPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          top: _tapPadding,
          bottom: _tapPadding,
          // The two overhangs already account for part of the measured gap.
          right: isLast ? 0 : _gap - _overhang * 2,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                // Transparent rather than absent so every label keeps the
                // same height and the row does not jump on selection.
                color: selected ? AppColors.textMuted : Colors.transparent,
                width: _underlineWidth,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _overhang,
              0,
              _overhang,
              _underlineGap,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: _fontSize,
                fontWeight: AppFonts.regular,
                color: AppColors.textMuted,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The live marker above the hero card.
///
/// The design draws a square-cornered block, not the rounded pill used
/// elsewhere on this screen, and fills it with [AppColors.liveBadge]. The
/// measured box is about 88x21.
class _LiveUpdatesBadge extends StatelessWidget {
  const _LiveUpdatesBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.liveBadge,
        borderRadius: BorderRadius.zero,
      ),
      child: const Text(
        'LIVE UPDATES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: AppFonts.medium,
          letterSpacing: 0.2,
          height: 1.2,
        ),
      ),
    );
  }
}

/// A single breaking-news item.
///
/// [image] is nullable because only one hero export exists so far. That export
/// is a flat composite with its headline already drawn into the picture, so
/// the card suppresses its own caption for it; once the feed API supplies bare
/// photographs every card will draw [title] and [excerpt] over the image.

/// Breaking news banner: the urgent items from the feed.
///
/// The design shows a swipeable stack — a 'Swipe' hint sits in the top-right
/// of the hero — so this is a [PageView]. With nothing urgent, or while the
/// feed loads or fails, the whole section stays out of the way rather than
/// showing an empty hero.
class _BreakingNewsSection extends ConsumerStatefulWidget {
  const _BreakingNewsSection();

  @override
  ConsumerState<_BreakingNewsSection> createState() =>
      _BreakingNewsSectionState();
}

class _BreakingNewsSectionState extends ConsumerState<_BreakingNewsSection> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(breakingNewsProvider).value ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiveUpdatesBadge(),
        // Measured ~10pt between the badge and the top of the hero.
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 350 / 184,
          child: PageView(
            controller: _controller,
            children: [
              for (var i = 0; i < items.length; i++)
                _BreakingNewsCard(
                  item: items[i],
                  // Nothing left to swipe to on the last card.
                  showSwipeHint: i < items.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _BreakingNewsCard extends StatelessWidget {
  const _BreakingNewsCard({required this.item, required this.showSwipeHint});

  final ContentItem item;
  final bool showSwipeHint;

  /// Inset of the swipe hint from the top-right corner, measured ~28pt.
  static const _swipeInset = 28.0;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.network(image, fit: BoxFit.cover, errorBuilder: _fallback)
          else
            _fallback(context, null, null),
          if (image == null) _Caption(item: item),
          if (showSwipeHint)
            const Positioned(
              top: _swipeInset,
              right: _swipeInset,
              child: _SwipeHint(),
            ),
        ],
      ),
    );
  }

  static Widget _fallback(
    BuildContext context,
    Object? error,
    StackTrace? stack,
  ) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

/// Headline and excerpt drawn over the hero picture.
class _Caption extends StatelessWidget {
  const _Caption({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.5,
              fontWeight: AppFonts.medium,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.excerpt,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              fontWeight: AppFonts.regular,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// The 'Swipe' affordance in the top-right of the hero.
///
/// The design pairs the word with a gesture glyph. We have no export of it, so
/// this uses the Material swipe icon until design supplies one.
class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Swipe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: AppFonts.regular,
            height: 1,
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.swipe_outlined, size: 16, color: Colors.white),
      ],
    );
  }
}

/// Latest News section: the newest news items from the feed.
class _LatestNewsSection extends ConsumerWidget {
  const _LatestNewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Latest News',
          onAction: () => context.push(Routes.news),
        ),
        const SizedBox(height: 14),
        _SectionFeed(
          items: ref.watch(latestNewsProvider),
          emptyMessage: 'No news yet.',
          onRetry: () => ref.invalidate(latestNewsProvider),
          itemBuilder: (item) => ContentCard(
            label: item.label,
            title: item.title,
            imageUrl: item.imageUrl,
            footer: const ContentCardAction('READ MORE'),
          ),
        ),
      ],
    );
  }
}

/// Upcoming Events section: the next events from the feed.
class _UpcomingEventsSection extends ConsumerWidget {
  const _UpcomingEventsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Events',
          onAction: () => context.push(Routes.events),
        ),
        const SizedBox(height: 14),
        _SectionFeed(
          items: ref.watch(upcomingEventsProvider),
          emptyMessage: 'No upcoming events.',
          onRetry: () => ref.invalidate(upcomingEventsProvider),
          itemBuilder: (item) => ContentCard(
            label: item.label,
            title: item.title,
            imageUrl: item.imageUrl,
            // Shipped with 4 here and 6 on Latest News; kept so the
            // extraction is pixel-for-pixel.
            footerGap: 4,
            footer: ContentCardMeta(_eventMeta(item)),
          ),
        ),
      ],
    );
  }

  /// 'Mon 21 September · Main Auditorium'.
  ///
  /// The API does not return an event's date or place yet, so until it does
  /// this falls back to who published it.
  static String _eventMeta(ContentItem item) {
    final startsAt = item.eventStartsAt;
    final parts = [
      if (startsAt != null) AppDateFormat.weekdayDay(startsAt),
      if (item.eventLocation != null) item.eventLocation!,
    ];
    return parts.isEmpty ? (item.sourceName ?? '') : parts.join(' · ');
  }
}

/// A home section's list, with its loading, failed and empty states.
class _SectionFeed extends StatelessWidget {
  const _SectionFeed({
    required this.items,
    required this.emptyMessage,
    required this.onRetry,
    required this.itemBuilder,
  });

  final AsyncValue<List<ContentItem>> items;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget Function(ContentItem item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return items.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Loader(),
      ),
      error: (error, _) => ErrorState(
        message: error is ApiException
            ? error.message
            : 'Something went wrong. Please try again.',
        onRetry: onRetry,
      ),
      data: (list) => list.isEmpty
          ? EmptyState(message: emptyMessage)
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => itemBuilder(list[index]),
            ),
    );
  }
}
