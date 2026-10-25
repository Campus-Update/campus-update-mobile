import 'package:flutter/material.dart';

import 'onboarding_style.dart';

/// The lavender ground behind the illustrations: a flat wash that fades into
/// the white page, a deeper glow behind the artwork, and a fine dot grid.
///
/// It stays put while pages change; only what sits on it moves.
class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(OnboardingCanvas.width, OnboardingCanvas.height),
      painter: _BackdropPainter(),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  /// The dot grid's pitch and dot size, measured off the design.
  static const _dotPitch = 9.0;
  static const _dotRadius = 0.9;

  /// How much of the ground is left at [y]: all of it above the fade, none
  /// below it.
  double _remaining(double y) {
    const from = OnboardingCanvas.fadeFrom;
    const to = OnboardingCanvas.fadeTo;
    if (y <= from) return 1;
    if (y >= to) return 0;
    return 1 - Curves.easeInOut.transform((y - from) / (to - from));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const from = OnboardingCanvas.fadeFrom / OnboardingCanvas.height;
    const to = OnboardingCanvas.fadeTo / OnboardingCanvas.height;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OnboardingColors.ground,
            OnboardingColors.ground,
            OnboardingColors.ground.withValues(alpha: 0),
          ],
          stops: const [0, from, to],
        ).createShader(rect),
    );

    // The glow sits behind the artwork, which is centred a little above the
    // middle of the canvas.
    final glowCentre = Offset(size.width / 2, size.height * 0.5);
    canvas.drawCircle(
      glowCentre,
      size.width * 0.55,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                OnboardingColors.glow.withValues(alpha: 0.75),
                OnboardingColors.glow.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: glowCentre, radius: size.width * 0.55),
            ),
    );

    final dot = Paint();
    for (var y = _dotPitch / 2; y < OnboardingCanvas.fadeTo; y += _dotPitch) {
      final alpha = 0.55 * _remaining(y);
      if (alpha <= 0) continue;
      dot.color = Colors.white.withValues(alpha: alpha);
      for (var x = _dotPitch / 2; x < size.width; x += _dotPitch) {
        canvas.drawCircle(Offset(x, y), _dotRadius, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) => false;
}
