import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import 'onboarding_style.dart';

/// A rounded square with a white glyph, as the mock cards use for each kind
/// of notice.
class OnboardingIconTile extends StatelessWidget {
  const OnboardingIconTile({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 36,
  });

  final IconData icon;
  final Gradient gradient;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x262B0F6D),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

/// A grey bar standing in for a line of text.
class OnboardingPlaceholderBar extends StatelessWidget {
  const OnboardingPlaceholderBar({
    super.key,
    required this.width,
    this.height = 6,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: OnboardingColors.placeholder,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Text on the mock cards. Archivo, sized by the caller.
TextStyle onboardingMockText(
  double size, {
  Color color = AppColors.graphite,
  FontWeight weight = AppFonts.medium,
}) => TextStyle(
  fontFamily: AppFonts.family,
  fontSize: size,
  height: 1.2,
  fontWeight: weight,
  color: color,
  letterSpacing: -0.01 * size,
);

/// Places [child] with its centre at [centre] on the canvas.
class CanvasPlacement extends StatelessWidget {
  const CanvasPlacement({
    super.key,
    required this.centre,
    required this.size,
    required this.child,
  });

  final Offset centre;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: centre.dx - size.width / 2,
      top: centre.dy - size.height / 2,
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}
