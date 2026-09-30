import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../profile/data/profile_providers.dart';

/// The central landing screen matching the UI design specification.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    this.hasPendingProfile,
    this.userName,
  });

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
              if (showProfileCard) ...[
                const SizedBox(height: AppSpacing.md),
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
            child: const Center(
              child: _SparkleFeedIcon(),
            ),
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => context.push(Routes.editProfile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2B88),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Add details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(pendingProfileProvider.notifier).dismiss(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F2937),
                      side: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Not now',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
      child: CustomPaint(
        painter: _FeedIconPainter(),
      ),
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

/// Breaking news banner featuring the hero news item.
class _BreakingNewsSection extends StatelessWidget {
  const _BreakingNewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.alertRed,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Breaking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Just Now',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            child: AspectRatio(
              aspectRatio: 350 / 184,
              child: Image.asset(
                'assets/images/breaking_news.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF334155), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Major Infrastructure Overhaul Announced for North Campus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'The university administration has unveiled a comprehensi...',
                          style: TextStyle(
                            color: Color(0xCCFFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
      title: 'FOCIT introduces machine learning elective for 400 level students',
    ),
    (
      category: 'General',
      title: 'New Library Wing Opens Ahead of Schedule',
    ),
    (
      category: 'Technology',
      title: 'New Library Wing Opens Ahead of Schedule',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Latest News',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(Routes.news),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3730A3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _newsItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final item = _newsItems[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soft lavender placeholder thumbnail
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'READ MORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(Routes.events),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3730A3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = _events[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soft lavender placeholder thumbnail
                Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.meta,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
