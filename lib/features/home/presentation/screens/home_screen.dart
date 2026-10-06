import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile/data/profile_providers.dart';

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
        child: SingleChildScrollView(
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
              const _BreakingNewsSection(),
              const SizedBox(height: AppSpacing.xl),
              const _LatestNewsSection(),
              const SizedBox(height: AppSpacing.xl),
              const _UpcomingEventsSection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
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
                IconButton(
                  onPressed: () => context.push(Routes.notifications),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        size: 25,
                        color: Color(0xFF374151),
                      ),
                      Positioned(
                        top: 0,
                        right: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
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
    // Scrolls horizontally so the strip survives a narrow phone; on a 390pt
    // screen all six fit without scrolling, as they do in the design.
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

  // Measured off the design export, then checked by rendering this screen and
  // measuring the render back. The export is only 216px wide, so it was the
  // label widths — a long baseline — that fixed the type size, not the glyph
  // heights: 'For You' is 17px there, which is 33pt once the frame is scaled
  // to 390, and 13pt Archivo draws it 44pt wide.
  static const _fontSize = 10.0;

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
typedef _BreakingItem = ({String title, String excerpt, String? image});

/// Breaking news banner.
///
/// The design shows a swipeable stack — a 'Swipe' hint sits in the top-right
/// of the hero — so this is a [PageView]. The second and third items are
/// placeholders in the same spirit as the rest of this screen; they go when
/// the feed API lands.
class _BreakingNewsSection extends StatefulWidget {
  const _BreakingNewsSection();

  @override
  State<_BreakingNewsSection> createState() => _BreakingNewsSectionState();
}

class _BreakingNewsSectionState extends State<_BreakingNewsSection> {
  static const List<_BreakingItem> _items = [
    (
      title: 'Major Infrastructure Overhaul Announced for North Campus',
      excerpt: 'The university administration has unveiled a comprehensi...',
      image: 'assets/images/breaking_news.png',
    ),
    (
      title: 'Senate Approves Revised Academic Calendar for 2025/2026',
      excerpt: 'Lectures resume a fortnight earlier than previously plan...',
      image: null,
    ),
    (
      title: 'Campus Clinic Extends Opening Hours Through Exam Week',
      excerpt: 'The health centre stays open until 10pm from Monday to F...',
      image: null,
    ),
  ];

  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              for (var i = 0; i < _items.length; i++)
                _BreakingNewsCard(
                  item: _items[i],
                  // Nothing left to swipe to on the last card.
                  showSwipeHint: i < _items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreakingNewsCard extends StatelessWidget {
  const _BreakingNewsCard({required this.item, required this.showSwipeHint});

  final _BreakingItem item;
  final bool showSwipeHint;

  /// Inset of the swipe hint from the top-right corner, measured ~28pt.
  static const _swipeInset = 28.0;

  @override
  Widget build(BuildContext context) {
    final image = item.image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image != null)
            Image.asset(image, fit: BoxFit.cover, errorBuilder: _fallback)
          else
            _fallback(context, null, null),
          // Subtle gradient scrim to keep headline text crisp and legible over image
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.65, 1.0],
              ),
            ),
          ),
          _Caption(item: item),
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

  final _BreakingItem item;

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

/// Latest News section with list of articles.
class _LatestNewsSection extends StatelessWidget {
  const _LatestNewsSection();

  static const _newsItems = [
    (
      category: 'Campus',
      title:
          'FOCIT introduces machine learning elective for 400 level students',
    ),
    (category: 'General', title: 'New Library Wing Opens Ahead of Schedule'),
    (category: 'Technology', title: 'New Library Wing Opens Ahead of Schedule'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Latest News',
          onAction: () => context.push(Routes.news),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _newsItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _newsItems[index];
            return ContentCard(
              label: item.category,
              title: item.title,
              footer: const ContentCardAction('READ MORE'),
            );
          },
        ),
      ],
    );
  }
}

/// Upcoming Events section with event schedule cards.
class _UpcomingEventsSection extends StatelessWidget {
  const _UpcomingEventsSection();

  static const _events = [
    (
      tag: 'Official event',
      title: 'New Library Wing Opens Ahead of Schedule',
      meta: 'Mon 21 September · Main Auditorium',
    ),
    (
      tag: 'Official event',
      title: 'Matriculation ceremony for the 2025/2026 session',
      meta: 'Fri 25 September · University Sports Complex',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Upcoming Events',
          onAction: () => context.push(Routes.events),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = _events[index];
            return ContentCard(
              label: event.tag,
              title: event.title,
              // Shipped with 4 here and 6 on Latest News; kept so the
              // extraction is pixel-for-pixel.
              footerGap: 4,
              footer: ContentCardMeta(event.meta),
            );
          },
        ),
      ],
    );
  }
}
