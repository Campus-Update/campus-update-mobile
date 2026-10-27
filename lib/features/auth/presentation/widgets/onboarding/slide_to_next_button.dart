import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import 'onboarding_style.dart';

/// The onboarding's primary control: a gradient pill in a pale track.
///
/// The pill's width is the reader's progress — about half the track on the
/// first page, more on the second — and it can be tapped, or dragged to the
/// end of the track, to move on. On the last page it fills the track and
/// becomes Get Started.
class SlideToNextButton extends StatefulWidget {
  const SlideToNextButton({
    super.key,
    required this.fill,
    required this.last,
    required this.idle,
    required this.onNext,
    required this.onFinish,
  });

  /// How much of the track the pill covers at rest, 0 to 1.
  final double fill;

  /// Whether this is the last page, where the pill reads Get Started.
  final bool last;

  /// The screen's idle loop, which runs the chevrons' shimmer.
  final Animation<double> idle;

  final VoidCallback onNext;
  final VoidCallback onFinish;

  /// The track and pill heights: the design's 50px button plus its 2px ring
  /// either side.
  static const height = 54.0;

  @override
  State<SlideToNextButton> createState() => _SlideToNextButtonState();
}

class _SlideToNextButtonState extends State<SlideToNextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _width = AnimationController(
    vsync: this,
    value: widget.fill,
  );

  /// Set while the pill runs to the end of the track, so a second tap or drag
  /// cannot fire [SlideToNextButton.onNext] twice.
  bool _completing = false;

  double _trackWidth = 1;

  static const _ring = 2.0;
  static const _labelStyle = TextStyle(
    fontFamily: AppFonts.family,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: AppFonts.medium,
    color: Colors.white,
    letterSpacing: -0.16,
  );

  @override
  void didUpdateWidget(SlideToNextButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fill != widget.fill) {
      _completing = false;
      _width.animateTo(
        widget.fill,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _width.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_completing) return;
    if (widget.last) {
      widget.onFinish();
      return;
    }
    _completing = true;
    await _width.animateTo(
      1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInCubic,
    );
    if (mounted) widget.onNext();
  }

  void _drag(DragUpdateDetails details) {
    if (_completing || widget.last) return;
    _width.value = (_width.value + details.delta.dx / _trackWidth).clamp(
      widget.fill,
      1.0,
    );
  }

  void _release(DragEndDetails details) {
    if (_completing || widget.last) return;
    final halfway = widget.fill + (1 - widget.fill) / 2;
    if (_width.value > halfway || (details.primaryVelocity ?? 0) > 500) {
      _complete();
    } else {
      _width.animateTo(
        widget.fill,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.last ? 'Get Started' : 'Next',
      excludeSemantics: true,
      onTap: _complete,
      child: SizedBox(
        width: double.infinity,
        height: SlideToNextButton.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _trackWidth = constraints.maxWidth;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _complete,
              onHorizontalDragUpdate: _drag,
              onHorizontalDragEnd: _release,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: OnboardingColors.pill,
                        borderRadius: BorderRadius.circular(
                          SlideToNextButton.height / 2,
                        ),
                        border: Border.all(color: OnboardingColors.pillBorder),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _width,
                    builder: (context, child) => SizedBox(
                      width: _trackWidth * _width.value,
                      height: SlideToNextButton.height,
                      child: child,
                    ),
                    child: _pill(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pill() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(SlideToNextButton.height / 2),
        border: Border.all(color: AppColors.buttonRing, width: _ring),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: widget.last
            ? const Center(
                key: ValueKey('finish'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Get Started', style: _labelStyle),
                    SizedBox(width: 6),
                    Icon(Icons.chevron_right, size: 20, color: Colors.white),
                  ],
                ),
              )
            : Padding(
                key: const ValueKey('next'),
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: Row(
                  children: [
                    const Text('Next', style: _labelStyle),
                    const Spacer(),
                    _Chevrons(idle: widget.idle),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Three chevrons with a light running through them, pointing the way the
/// pill slides.
class _Chevrons extends StatelessWidget {
  const _Chevrons({required this.idle});

  final Animation<double> idle;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: idle,
      builder: (context, _) => CustomPaint(
        size: const Size(20, 11),
        painter: _ChevronPainter(phase: (idle.value * 5) % 1),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.phase});

  final double phase;

  static const _count = 3;
  static const _pitch = 6.5;
  static const _depth = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < _count; i++) {
      final wave = 0.5 + 0.5 * math.cos(2 * math.pi * (phase - i / _count));
      paint.color = Colors.white.withValues(alpha: 0.35 + 0.65 * wave);
      final x = i * _pitch;
      canvas.drawPath(
        Path()
          ..moveTo(x, 0.5)
          ..lineTo(x + _depth, size.height / 2)
          ..lineTo(x, size.height - 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.phase != phase;
}
