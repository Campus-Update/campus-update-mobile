import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../shared/widgets/widgets.dart';
import 'onboarding_pieces.dart';
import 'onboarding_style.dart';

/// Page one: the app mark branching out to a news card, with For You and
/// Official tags drifting either side.
///
/// [enter] runs 0→1 as the page arrives; [idle] loops 0→1 for as long as it
/// rests.
class NewsIllustration extends StatelessWidget {
  const NewsIllustration({super.key, required this.enter, required this.idle});

  final Animation<double> enter;
  final Animation<double> idle;

  /// Until design exports the card's own photograph, the onboarding
  /// photograph stands in.
  static const _photo = 'assets/images/onboarding.png';

  static const _markCentre = Offset(196.5, 116);
  static const _markSize = 54.0;
  static const _cardRect = Rect.fromLTWH(56, 185, 281, 250);

  @override
  Widget build(BuildContext context) {
    final core = stage(enter, 0, 0.4);
    final forYou = stage(enter, 0.3, 0.65, curve: Curves.easeOutBack);
    final official = stage(enter, 0.38, 0.72, curve: Curves.easeOutBack);

    return AnimatedBuilder(
      animation: Listenable.merge([enter, idle]),
      builder: (context, _) {
        final t = idle.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: core.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 1.08 - 0.08 * core.value,
                  alignment: const Alignment(0, -0.3),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _ConnectorPainter()),
                      ),
                      CanvasPlacement(
                        centre: _markCentre,
                        size: const Size.square(_markSize),
                        child: const _MarkTile(),
                      ),
                      Positioned.fromRect(
                        rect: _cardRect,
                        child: const _NewsCard(photo: _photo),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CanvasPlacement(
              centre: Offset(
                56.4 - 140 * (1 - forYou.value),
                164.6 + bob(t, amplitude: 2.5),
              ),
              size: const Size(98, 34),
              child: Opacity(
                opacity: forYou.value.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: degrees(-6),
                  // The tags size to their words, which run a hair wider on some
                  // platforms than the box they are centred in.
                  child: const OverflowBox(
                    maxWidth: double.infinity,
                    child: _ForYouTag(),
                  ),
                ),
              ),
            ),
            CanvasPlacement(
              centre: Offset(
                324 + 140 * (1 - official.value),
                153.4 + bob(t, phase: 0.4, amplitude: 2.5),
              ),
              size: const Size(92, 32),
              child: Opacity(
                opacity: official.value.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: degrees(5),
                  child: const OverflowBox(
                    maxWidth: double.infinity,
                    child: _OfficialTag(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The app mark on a frosted tile, at the head of the branch.
class _MarkTile extends StatelessWidget {
  const _MarkTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E8FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: OnboardingColors.cardShadow,
      ),
      alignment: Alignment.center,
      child: const AppLogo(size: 28),
    );
  }
}

/// The white line running from the mark down to either top corner of the
/// card.
class _ConnectorPainter extends CustomPainter {
  const _ConnectorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const x = 196.5;
    const top = 143.0;
    const split = 156.0;
    const bottom = 185.0;
    const left = 145.0;
    const right = 248.0;

    final path = Path()
      ..moveTo(x, top)
      ..lineTo(x, split)
      ..moveTo(x, split)
      ..cubicTo(x, 166, left, 160, left, bottom)
      ..moveTo(x, split)
      ..cubicTo(x, 166, right, 160, right, bottom);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) => false;
}

/// A miniature of the news screen: header, photograph and headline.
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.photo});

  final String photo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: OnboardingColors.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 51,
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.graphite,
                ),
                const SizedBox(width: 9),
                Text('Latest News', style: onboardingMockText(16)),
                const Spacer(),
                const _Bell(),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              photo,
              width: double.infinity,
              height: 118,
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.45),
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.indigoSurface),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            'Campus',
            style: onboardingMockText(
              11,
              color: OnboardingColors.mockMuted,
              weight: AppFonts.regular,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New Library Wing Opens\nAhead of Schedule',
            style: onboardingMockText(
              15,
              color: const Color(0xFF4D4D5A),
            ).copyWith(height: 19 / 15),
          ),
        ],
      ),
    );
  }
}

class _Bell extends StatelessWidget {
  const _Bell();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: AppColors.graphite,
          ),
          Positioned(
            right: 1,
            top: 0,
            child: SizedBox.square(
              dimension: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The solid indigo For You tag.
class _ForYouTag extends StatelessWidget {
  const _ForYouTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
      decoration: BoxDecoration(
        color: AppColors.indigo,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: OnboardingColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 14,
              color: AppColors.indigo,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'For You',
            style: onboardingMockText(
              14,
              color: Colors.white,
              weight: AppFonts.regular,
            ),
          ),
        ],
      ),
    );
  }
}

/// The frosted Official tag.
class _OfficialTag extends StatelessWidget {
  const _OfficialTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: OnboardingColors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.indigo,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Official',
            style: onboardingMockText(14, weight: AppFonts.regular),
          ),
        ],
      ),
    );
  }
}
