import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';

/// Modal dialog confirming logout of active sessions on other devices.
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => const LogoutConfirmationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.bottomCenter,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Concentric layered red warning badge
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 94,
                  height: 94,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC7C7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: _WarningTriangleInfoIcon(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Are you sure?',
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'You will be logged out of all active sessions on other devices. '
                'This action cannot be undone.',
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF4B5563),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Confirm Logout',
                    variant: AppButtonVariant.danger,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningTriangleInfoIcon extends StatelessWidget {
  const _WarningTriangleInfoIcon();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(26, 26),
      painter: _WarningTriangleInfoPainter(),
    );
  }
}

class _WarningTriangleInfoPainter extends CustomPainter {
  const _WarningTriangleInfoPainter();

  static const _iconColor = Color(0xFFDC2626);
  static const _backgroundColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 29.0;
    canvas.save();
    canvas.scale(scale, scale);

    final bgPaint = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final redPaint = Paint()
      ..color = _iconColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Rounded equilateral-like triangle with smooth corners
    final triPath = Path()
      ..moveTo(10.5, 6.0)
      ..cubicTo(12.5, 2.0, 16.5, 2.0, 18.5, 6.0)
      ..lineTo(24.5, 17.5)
      ..cubicTo(28.0, 23.0, 25.5, 25.5, 21.5, 25.5)
      ..lineTo(7.5, 25.5)
      ..cubicTo(3.5, 25.5, 1.0, 23.0, 4.5, 17.5)
      ..close();

    canvas.drawPath(triPath, bgPaint);

    // Inner "i" dot
    canvas.drawCircle(const Offset(14.5, 9.0), 1.4, redPaint);

    // Inner "i" stem with rounded bottom
    final stemRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(13.3, 13.5, 2.5, 8.0),
      const Radius.circular(1.2),
    );
    canvas.drawRRect(stemRRect, redPaint);

    // Inner "i" serif on top-left of stem
    final serifPath = Path()
      ..moveTo(13.4, 15.2)
      ..lineTo(12.2, 15.6)
      ..lineTo(11.8, 14.4)
      ..lineTo(13.4, 13.5)
      ..close();
    canvas.drawPath(serifPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
