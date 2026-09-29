import 'package:flutter/material.dart';

/// Pixel-perfect vector icons for the bottom navigation bar matching the design.

class NavHomeIcon extends StatelessWidget {
  const NavHomeIcon({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HomeIconPainter(color: color),
    );
  }
}

class _HomeIconPainter extends CustomPainter {
  _HomeIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      // Start near left roof slope
      ..moveTo(4.5 * s, 10.5 * s)
      // Roof peak with slight rounding
      ..lineTo(11.2 * s, 4.2 * s)
      ..quadraticBezierTo(12 * s, 3.4 * s, 12.8 * s, 4.2 * s)
      ..lineTo(19.5 * s, 10.5 * s)
      // Right wall
      ..lineTo(19.5 * s, 19.5 * s)
      ..quadraticBezierTo(19.5 * s, 21 * s, 18 * s, 21 * s)
      // Base to door
      ..lineTo(14.5 * s, 21 * s)
      // Door
      ..lineTo(14.5 * s, 15.5 * s)
      ..quadraticBezierTo(14.5 * s, 14 * s, 13.5 * s, 14 * s)
      ..lineTo(10.5 * s, 14 * s)
      ..quadraticBezierTo(9.5 * s, 14 * s, 9.5 * s, 15.5 * s)
      ..lineTo(9.5 * s, 21 * s)
      // Base to left wall
      ..lineTo(6 * s, 21 * s)
      ..quadraticBezierTo(4.5 * s, 21 * s, 4.5 * s, 19.5 * s)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class NavNewsIcon extends StatelessWidget {
  const NavNewsIcon({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _NewsIconPainter(color: color),
    );
  }
}

class _NewsIconPainter extends CustomPainter {
  _NewsIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer card
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4.5 * s, 3.5 * s, 15 * s, 17.5 * s),
      Radius.circular(4 * s),
    );
    canvas.drawRRect(rect, paint);

    // Document header horizontal line
    canvas.drawLine(
      Offset(8 * s, 8 * s),
      Offset(12.5 * s, 8 * s),
      paint..strokeWidth = 1.6 * s,
    );

    // Document lines
    canvas.drawLine(
      Offset(8 * s, 12 * s),
      Offset(16 * s, 12 * s),
      paint,
    );

    canvas.drawLine(
      Offset(8 * s, 16 * s),
      Offset(14 * s, 16 * s),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NewsIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class NavEventsIcon extends StatelessWidget {
  const NavEventsIcon({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _EventsIconPainter(color: color),
    );
  }
}

class _EventsIconPainter extends CustomPainter {
  _EventsIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calendar body
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4.5 * s, 5.5 * s, 15 * s, 15.5 * s),
      Radius.circular(4 * s),
    );
    canvas.drawRRect(rect, paint);

    // Header divider line
    canvas.drawLine(
      Offset(4.5 * s, 10.5 * s),
      Offset(19.5 * s, 10.5 * s),
      paint,
    );

    // Top binder rings
    canvas.drawLine(
      Offset(8.5 * s, 3 * s),
      Offset(8.5 * s, 6.5 * s),
      paint,
    );
    canvas.drawLine(
      Offset(15.5 * s, 3 * s),
      Offset(15.5 * s, 6.5 * s),
      paint,
    );

    // Center-bottom event dot
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(14 * s, 15.5 * s), 1.6 * s, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _EventsIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class NavCalendarIcon extends StatelessWidget {
  const NavCalendarIcon({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CalendarIconPainter(color: color),
    );
  }
}

class _CalendarIconPainter extends CustomPainter {
  _CalendarIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Back card (bottom-left)
    final backPath = Path()
      ..moveTo(4.5 * s, 10 * s)
      ..lineTo(4.5 * s, 18.5 * s)
      ..quadraticBezierTo(4.5 * s, 21 * s, 7 * s, 21 * s)
      ..lineTo(16 * s, 21 * s)
      ..quadraticBezierTo(17.5 * s, 21 * s, 17.5 * s, 19.5 * s);
    canvas.drawPath(backPath, paint);

    // Front card (top-right)
    final frontRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(7.5 * s, 5.5 * s, 13 * s, 13 * s),
      Radius.circular(3.5 * s),
    );
    canvas.drawRRect(frontRect, paint);

    // Front header line
    canvas.drawLine(
      Offset(7.5 * s, 10 * s),
      Offset(20.5 * s, 10 * s),
      paint,
    );

    // Top binder rings on front card
    canvas.drawLine(
      Offset(11 * s, 3.2 * s),
      Offset(11 * s, 6.5 * s),
      paint,
    );
    canvas.drawLine(
      Offset(17 * s, 3.2 * s),
      Offset(17 * s, 6.5 * s),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CalendarIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class NavProfileIcon extends StatelessWidget {
  const NavProfileIcon({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ProfileIconPainter(color: color),
    );
  }
}

class _ProfileIconPainter extends CustomPainter {
  _ProfileIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer circle arc (broken slightly at top-right for the badge dot)
    final outerArc = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(12 * s, 13 * s), radius: 8.5 * s),
        -0.5,
        5.4,
      );
    canvas.drawPath(outerArc, paint);

    // Head circle inside
    canvas.drawCircle(Offset(12 * s, 11 * s), 2.8 * s, paint);

    // Shoulders arc inside
    final shoulders = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(12 * s, 18.5 * s), radius: 5.2 * s),
        3.3,
        2.8,
      );
    canvas.drawPath(shoulders, paint);

    // Small status bubble at top right (at x=18.5, y=5.5)
    canvas.drawCircle(Offset(18.5 * s, 6 * s), 1.8 * s, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
