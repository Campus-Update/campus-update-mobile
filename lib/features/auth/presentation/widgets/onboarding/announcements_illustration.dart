import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import 'onboarding_pieces.dart';
import 'onboarding_style.dart';

/// Page two: a lock screen with an urgent notice swinging in over a quieter
/// one.
///
/// [enter] runs 0→1 as the page arrives; [idle] loops 0→1 for as long as it
/// rests.
class AnnouncementsIllustration extends StatelessWidget {
  const AnnouncementsIllustration({
    super.key,
    required this.enter,
    required this.idle,
  });

  final Animation<double> enter;
  final Animation<double> idle;

  static const _phoneRect = Rect.fromLTWH(86, 91, 222, 335);
  static const _urgentCentre = Offset(190.5, 289.6);
  static const _urgentSize = Size(296, 100);
  static const _urgentTilt = -4.0;
  static const _quietRect = Rect.fromLTWH(59, 352, 300, 62);

  @override
  Widget build(BuildContext context) {
    final phone = stage(enter, 0, 0.35);
    final quiet = stage(enter, 0.25, 0.5);
    final urgent = stage(enter, 0.35, 0.72, curve: Curves.easeOutBack);
    final urgentFade = stage(enter, 0.35, 0.5);

    return AnimatedBuilder(
      animation: Listenable.merge([enter, idle]),
      builder: (context, _) {
        final t = idle.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRect(
              rect: _phoneRect,
              child: Opacity(
                opacity: phone.value,
                child: Transform.scale(
                  scale: 1.06 - 0.06 * phone.value,
                  child: const _LockScreen(),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: _quietRect.translate(0, 12 * (1 - quiet.value)),
              child: Opacity(opacity: quiet.value, child: const _QuietNotice()),
            ),
            CanvasPlacement(
              centre: _urgentCentre.translate(
                -180 * (1 - urgent.value),
                bob(t, phase: 0.2, amplitude: 2),
              ),
              size: _urgentSize,
              child: Opacity(
                opacity: urgentFade.value,
                child: Transform.rotate(
                  angle: degrees(
                    _urgentTilt * urgent.value + bob(t, amplitude: 0.8),
                  ),
                  child: const _UrgentNotice(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A handset's lock screen: island, date and time.
class _LockScreen extends StatelessWidget {
  const _LockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OnboardingColors.phoneScreen,
        borderRadius: BorderRadius.circular(38),
        border: Border.all(color: OnboardingColors.phoneFrame, width: 5),
        boxShadow: OnboardingColors.cardShadow,
      ),
      child: Column(
        children: [
          const SizedBox(height: 13),
          Container(
            width: 76,
            height: 21,
            decoration: BoxDecoration(
              color: OnboardingColors.phoneIsland,
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Mon, September 21',
            style: onboardingMockText(
              13,
              color: OnboardingColors.phoneDate,
              weight: AppFonts.regular,
            ),
          ),
          Text(
            '09:17',
            style: onboardingMockText(
              57,
              color: OnboardingColors.phoneTime,
            ).copyWith(height: 1.1),
          ),
        ],
      ),
    );
  }
}

/// The urgent notice, crisp and tilted.
class _UrgentNotice extends StatelessWidget {
  const _UrgentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white),
        boxShadow: OnboardingColors.cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingIconTile(
                icon: Icons.warning_amber_rounded,
                gradient: OnboardingColors.tileRed,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Exam Timetable Updated',
                      style: onboardingMockText(15),
                    ),
                    const SizedBox(height: 8),
                    const OnboardingPlaceholderBar(width: 190),
                    const SizedBox(height: 6),
                    const OnboardingPlaceholderBar(width: 130),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEDEBF8)),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.north_east,
                  size: 12,
                  color: OnboardingColors.mockMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  'View announcement',
                  style: onboardingMockText(
                    12,
                    color: const Color(0xFF6B6B7B),
                    weight: AppFonts.regular,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: OnboardingColors.urgentSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: AppColors.alertRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Urgent',
                        style: onboardingMockText(
                          12,
                          color: AppColors.alertRed,
                          weight: AppFonts.regular,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The quieter notice behind, held out of focus.
class _QuietNotice extends StatelessWidget {
  const _QuietNotice();

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.fromLTRB(16, 11, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OnboardingIconTile(
              icon: Icons.outlined_flag_rounded,
              gradient: OnboardingColors.tileOrange,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Registration Deadline Extended',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: onboardingMockText(
                      14,
                      color: OnboardingColors.mockMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const OnboardingPlaceholderBar(width: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
