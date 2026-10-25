import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../../../../app/theme/app_colors.dart';

/// The illustration area at the top of every onboarding page.
///
/// Each illustration is laid out on this fixed canvas and scaled to the screen
/// width, so the positions below can be the ones measured off the design.
/// Measured from the motion export (an iPhone at 393pt wide); there is no
/// Figma for these screens yet, so every figure here is a reading off video
/// frames and worth confirming once one exists.
abstract final class OnboardingCanvas {
  static const width = 393.0;
  static const height = 430.0;

  /// Where the lavender ground starts fading to the white page, and where it
  /// has gone.
  static const fadeFrom = 240.0;
  static const fadeTo = 425.0;
}

/// Colours the onboarding illustrations use and nothing else does.
///
/// Sampled off video, which renders the brand indigo (#4F46E5) as #5F6CEE —
/// lighter and bluer. Each value here has had that shift taken back out, so
/// they are estimates; confirm against the design when it lands.
abstract final class OnboardingColors {
  /// The lavender behind the illustrations.
  static const ground = Color(0xFFD4D1FB);

  /// The deeper lavender glowing behind each illustration.
  static const glow = Color(0xFFBEBAF6);

  /// The pill above each title, and the track the Next button runs in.
  static const pill = AppColors.formPanel;
  static const pillBorder = Color(0xFFE4E1F7);

  /// Grey bars that stand in for lines of text on the mock cards.
  static const placeholder = Color(0xFFE7E5F8);

  /// Muted text on the mock cards.
  static const mockMuted = Color(0xFF9C9BAD);

  /// The handset drawn on the announcements page.
  static const phoneFrame = Color(0xFF2D2A80);
  static const phoneScreen = Color(0xFFE6E4FB);
  static const phoneIsland = Color(0xFF1B1E3A);
  static const phoneDate = Color(0xFFA3A3C7);
  static const phoneTime = Color(0xFFCBCAE8);

  /// The Urgent badge on the mock notification.
  static const urgentSurface = Color(0xFFFDE3E6);

  /// Icon tiles: brand indigo, alert red for the urgent notice, and an orange
  /// for promoted and secondary notices that the palette does not yet have.
  static const tileIndigo = LinearGradient(
    colors: [Color(0xFF5B54EA), Color(0xFF3B33C4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const tileRed = LinearGradient(
    colors: [Color(0xFFF15050), Color(0xFFC81E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const tileOrange = LinearGradient(
    colors: [Color(0xFFFF9B3D), Color(0xFFF26A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// The soft shadow under every floating card and chip.
  static const cardShadow = [
    BoxShadow(color: Color(0x1A3B33C4), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

/// A slice of a page's entrance, from [begin] to [end] of its timeline.
///
/// Driven rather than a [CurvedAnimation], which subscribes to its parent the
/// moment it is made — these are made in build methods, so that would leak a
/// listener on every rebuild.
Animation<double> stage(
  Animation<double> parent,
  double begin,
  double end, {
  Curve curve = Curves.easeOutCubic,
}) => parent.drive(CurveTween(curve: Interval(begin, end, curve: curve)));

/// A gentle float for things at rest: one full sine wave per turn of the idle
/// loop, so it repeats without a seam. [phase] staggers neighbours.
double bob(double t, {double phase = 0, double amplitude = 3}) =>
    math.sin((t + phase) * 2 * math.pi) * amplitude;

/// Degrees to radians, since every tilt below was measured in degrees.
double degrees(double d) => d * math.pi / 180;
