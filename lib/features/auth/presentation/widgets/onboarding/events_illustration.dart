import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../../shared/widgets/widgets.dart';
import 'onboarding_pieces.dart';
import 'onboarding_style.dart';

/// Page three: the app mark at the centre of a dial, with the kinds of date
/// it keeps flying out to sit around it.
///
/// [enter] runs 0→1 as the page arrives; [idle] loops 0→1 for as long as it
/// rests.
class EventsIllustration extends StatelessWidget {
  const EventsIllustration({
    super.key,
    required this.enter,
    required this.idle,
  });

  final Animation<double> enter;
  final Animation<double> idle;

  static const _centre = Offset(196.5, 234);
  static const _discRadius = 65.0;
  static const _logoSize = 54.0;

  static const _tags = [
    _Tag(
      'Official Event',
      Icons.school_outlined,
      OnboardingColors.tileIndigo,
      Offset(87.4, 151.4),
      140,
      -5,
    ),
    _Tag(
      'Promoted Event',
      Icons.campaign_outlined,
      OnboardingColors.tileOrange,
      Offset(299.7, 142.7),
      152,
      5,
    ),
    _Tag(
      'Registration',
      Icons.assignment_outlined,
      OnboardingColors.tileIndigo,
      Offset(96.5, 332.7),
      134,
      3,
    ),
    _Tag(
      'Exam Period',
      Icons.calendar_month_outlined,
      OnboardingColors.tileIndigo,
      Offset(298, 340.9),
      136,
      -3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dial = stage(enter, 0, 0.3);
    final disc = stage(enter, 0.08, 0.38, curve: Curves.easeOutBack);
    final mark = stage(enter, 0.2, 0.48);
    final tags = [
      for (var i = 0; i < _tags.length; i++)
        (
          move: stage(
            enter,
            0.35 + 0.06 * i,
            0.7 + 0.06 * i,
            curve: Curves.easeOutBack,
          ),
          fade: stage(enter, 0.35 + 0.06 * i, 0.5 + 0.06 * i),
        ),
    ];

    return AnimatedBuilder(
      animation: Listenable.merge([enter, idle]),
      builder: (context, _) {
        final t = idle.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: dial.value,
                child: Transform.scale(
                  scale: 0.85 + 0.15 * dial.value,
                  origin:
                      _centre -
                      const Offset(
                        OnboardingCanvas.width / 2,
                        OnboardingCanvas.height / 2,
                      ),
                  child: CustomPaint(
                    painter: _DialPainter(centre: _centre, turn: t),
                  ),
                ),
              ),
            ),
            CanvasPlacement(
              centre: _centre,
              size: const Size.square(_discRadius * 2),
              child: Transform.scale(
                scale: 0.6 + 0.4 * disc.value,
                child: Opacity(
                  opacity: disc.value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFC),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: OnboardingColors.cardShadow,
                    ),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: mark.value,
                      child: Transform.rotate(
                        angle: -0.35 * 2 * math.pi * (1 - mark.value),
                        child: const AppLogo(size: _logoSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            for (var i = 0; i < _tags.length; i++)
              CanvasPlacement(
                centre: Offset(
                  lerpDouble(
                    _centre.dx,
                    _tags[i].centre.dx,
                    tags[i].move.value,
                  )!,
                  lerpDouble(
                        _centre.dy,
                        _tags[i].centre.dy,
                        tags[i].move.value,
                      )! +
                      bob(t, phase: i * 0.27, amplitude: 3),
                ),
                size: Size(_tags[i].width, 54),
                child: Opacity(
                  opacity: tags[i].fade.value,
                  child: Transform.rotate(
                    angle: degrees(_tags[i].tilt),
                    child: Transform.scale(
                      scale: 0.4 + 0.6 * tags[i].move.value,
                      child: _TagCard(tag: _tags[i]),
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

class _Tag {
  const _Tag(
    this.label,
    this.icon,
    this.gradient,
    this.centre,
    this.width,
    this.tilt,
  );

  final String label;
  final IconData icon;
  final Gradient gradient;
  final Offset centre;
  final double width;
  final double tilt;
}

class _TagCard extends StatelessWidget {
  const _TagCard({required this.tag});

  final _Tag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: OnboardingColors.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          OnboardingIconTile(icon: tag.icon, gradient: tag.gradient),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.label,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: onboardingMockText(13),
                ),
                const SizedBox(height: 6),
                const OnboardingPlaceholderBar(width: 64, height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The beam from the top of the screen, the glow, and the ticked ring around
/// the disc. [turn] walks the ticks round by one pitch per idle loop, so the
/// ring creeps without ever jumping.
class _DialPainter extends CustomPainter {
  const _DialPainter({required this.centre, required this.turn});

  final Offset centre;
  final double turn;

  static const _glowRadius = 110.0;
  static const _ringRadius = 85.5;
  static const _tickOuter = 79.0;
  static const _tickInner = 72.0;
  static const _ticks = 90;

  @override
  void paint(Canvas canvas, Size size) {
    final beamTop = Offset(centre.dx, 0);
    final beamBottom = Offset(centre.dx, centre.dy - _ringRadius);
    final beamRect = Rect.fromPoints(
      beamTop.translate(-2, 0),
      beamBottom.translate(2, 0),
    );
    final beamShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.white.withValues(alpha: 0.3)],
    ).createShader(beamRect);
    canvas.drawLine(
      beamTop,
      beamBottom,
      Paint()
        ..shader = beamShader
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      beamTop,
      beamBottom,
      Paint()
        ..shader = beamShader
        ..strokeWidth = 1.2,
    );

    canvas.drawCircle(
      centre,
      _glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFC3C1F6),
            const Color(0xFFC3C1F6).withValues(alpha: 0.6),
            const Color(0xFFC3C1F6).withValues(alpha: 0),
          ],
          stops: const [0, 0.75, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: _glowRadius)),
    );

    canvas.drawCircle(
      centre,
      _ringRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final tick = Paint()
      ..color = const Color(0xFF7B78E0).withValues(alpha: 0.45)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    const pitch = 2 * math.pi / _ticks;
    for (var i = 0; i < _ticks; i++) {
      final a = i * pitch + turn * pitch;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        centre + dir * _tickInner,
        centre + dir * _tickOuter,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) => oldDelegate.turn != turn;
}
