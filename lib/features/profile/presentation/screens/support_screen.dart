import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/profile_screen_header.dart';

/// Support & Help Center screen matching the design.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _showCallModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Call Campus Support',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our support team is available Monday to Friday, 8:00 AM – 5:00 PM.',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _ContactActionTile(
                  title: 'Student Helpdesk Line',
                  subtitle: '+234 800 5323 2489',
                  icon: Icons.phone_outlined,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: '+23480053232489'),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Phone number copied to clipboard'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ContactActionTile(
                  title: 'Campus Emergency Line',
                  subtitle: '+234 815 000 1234',
                  icon: Icons.emergency_outlined,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: '+2348150001234'),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Emergency line copied to clipboard'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEmailModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Send an Email',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send your inquiries or support tickets to our campus response team.',
                  style: TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _ContactActionTile(
                  title: 'Support Desk',
                  subtitle: 'support@leadcity.edu.ng',
                  icon: Icons.mail_outline_rounded,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'support@leadcity.edu.ng'),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email address copied to clipboard'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _ContactActionTile(
                  title: 'Campus Update Admin',
                  subtitle: 'help@campusupdate.edu',
                  icon: Icons.alternate_email_rounded,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'help@campusupdate.edu'),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email address copied to clipboard'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFaqModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FaqTile(
                    question: 'How do I update my profile details?',
                    answer:
                        'Go to your Profile tab and tap the "Edit" button below your profile card. You can edit your name, department, faculty, and academic level.',
                  ),
                  _FaqTile(
                    question: 'How do I change my account password?',
                    answer:
                        'Navigate to Settings > Change Password, enter your current password, and satisfy all security criteria for your new password.',
                  ),
                  _FaqTile(
                    question: 'How does personalized feed work?',
                    answer:
                        'Your feed is curated according to your school, faculty, and selected preferences. You can switch between Personalized and All Campus News in Preferences.',
                  ),
                  _FaqTile(
                    question: 'How do I report an issue with the app?',
                    answer:
                        'You can send an email to support@leadcity.edu.ng or use the WhatsApp support line anytime.',
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSocialSheet(BuildContext context, String platform, String handle) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  platform,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with the official campus community on $platform.',
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 13.5,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                _ContactActionTile(
                  title: 'Official Handle',
                  subtitle: handle,
                  icon: Icons.link_rounded,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: handle));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$platform handle copied: $handle')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Support'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Call Us
                    _SupportOptionCard(
                      title: 'Call Us',
                      iconWidget: const Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: Color(0xFF374151),
                      ),
                      onTap: () => _showCallModal(context),
                    ),
                    const SizedBox(height: 12),

                    // 2. Send an Email
                    _SupportOptionCard(
                      title: 'Send an Email',
                      iconWidget: const Icon(
                        Icons.mail_outline_rounded,
                        size: 18,
                        color: Color(0xFF374151),
                      ),
                      onTap: () => _showEmailModal(context),
                    ),
                    const SizedBox(height: 12),

                    // 3. Frequently Asked Questions
                    _SupportOptionCard(
                      title: 'Frequently Asked Questions',
                      iconWidget: const Icon(
                        Icons.help_outline_rounded,
                        size: 18,
                        color: Color(0xFF374151),
                      ),
                      onTap: () => _showFaqModal(context),
                    ),
                    const SizedBox(height: 12),

                    // 4. Chat With Support (Coming Soon)
                    _SupportOptionCard(
                      title: 'Chat With Support',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      iconWidget: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: Color(0xFF374151),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Live chat support is coming soon in an upcoming update.',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // 5. Instagram
                    _SupportOptionCard(
                      title: 'Instagram',
                      iconWidget: const _InstagramVectorIcon(),
                      onTap: () => _showSocialSheet(
                        context,
                        'Instagram',
                        '@leadcityuniversity',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 6. X (Twitter)
                    _SupportOptionCard(
                      title: 'X (Twitter)',
                      iconWidget: const _XTwitterVectorIcon(),
                      onTap: () => _showSocialSheet(
                        context,
                        'X (Twitter)',
                        '@leadcityuniv',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 7. WhatsApp
                    _SupportOptionCard(
                      title: 'WhatsApp',
                      iconWidget: const _WhatsAppVectorIcon(),
                      onTap: () => _showSocialSheet(
                        context,
                        'WhatsApp',
                        '+234 800 5323 2489',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save changes button
                    AppButton(
                      label: 'Save changes',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Support preferences saved'),
                          ),
                        );
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An individual support option card matching the design.
class _SupportOptionCard extends StatelessWidget {
  const _SupportOptionCard({
    required this.title,
    required this.iconWidget,
    this.badge,
    required this.onTap,
  });

  final String title;
  final Widget iconWidget;
  final Widget? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3F4F6),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0x0D4338CA),
          highlightColor: const Color(0x054338CA),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading 38x38 circle avatar with subtle border
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: AppFonts.family,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        badge!,
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF1F2937),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action tile used inside the bottom sheets
class _ContactActionTile extends StatelessWidget {
  const _ContactActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.family,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontFamily: AppFonts.family,
            fontSize: 13,
            color: Color(0xFF4B5563),
          ),
        ),
        trailing: const Icon(
          Icons.copy_rounded,
          size: 18,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

/// Expandable FAQ tile inside the FAQ modal
class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Text(
            question,
            style: const TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Instagram camera outline icon
class _InstagramVectorIcon extends StatelessWidget {
  const _InstagramVectorIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _InstagramPainter(),
    );
  }
}

class _InstagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18.0;
    final strokePaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * s
      ..isAntiAlias = true;

    final dotPaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Outer rounded square
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2.5 * s, 2.5 * s, 13 * s, 13 * s),
      Radius.circular(3.8 * s),
    );
    canvas.drawRRect(rect, strokePaint);

    // Inner circle
    canvas.drawCircle(Offset(9 * s, 9 * s), 3.4 * s, strokePaint);

    // Top-right flash dot
    canvas.drawCircle(Offset(12.6 * s, 5.4 * s), 0.9 * s, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// X (Twitter) circle outline with X inside
class _XTwitterVectorIcon extends StatelessWidget {
  const _XTwitterVectorIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _XTwitterPainter(),
    );
  }
}

class _XTwitterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18.0;
    final strokePaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3 * s
      ..isAntiAlias = true;

    // Outer circle
    canvas.drawCircle(Offset(9 * s, 9 * s), 7.5 * s, strokePaint);

    // Stylized X mark
    final xPaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(
      Offset(5.8 * s, 5.8 * s),
      Offset(12.2 * s, 12.2 * s),
      xPaint,
    );
    canvas.drawLine(
      Offset(12.2 * s, 5.8 * s),
      Offset(5.8 * s, 12.2 * s),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// WhatsApp speech bubble with phone handset inside
class _WhatsAppVectorIcon extends StatelessWidget {
  const _WhatsAppVectorIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _WhatsAppPainter(),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 18.0;
    final strokePaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Speech bubble path with bottom-left pointer
    final bubble = Path()
      ..moveTo(9 * s, 2.5 * s)
      ..cubicTo(13.2 * s, 2.5 * s, 15.8 * s, 5.1 * s, 15.8 * s, 8.8 * s)
      ..cubicTo(15.8 * s, 12.5 * s, 13.0 * s, 15.0 * s, 9 * s, 15.0 * s)
      ..cubicTo(7.7 * s, 15.0 * s, 6.5 * s, 14.6 * s, 5.5 * s, 14.0 * s)
      ..lineTo(3.0 * s, 14.8 * s)
      ..lineTo(3.8 * s, 12.6 * s)
      ..cubicTo(2.8 * s, 11.5 * s, 2.2 * s, 10.2 * s, 2.2 * s, 8.8 * s)
      ..cubicTo(2.2 * s, 5.1 * s, 4.8 * s, 2.5 * s, 9 * s, 2.5 * s)
      ..close();

    canvas.drawPath(bubble, strokePaint);

    // Mini handset curve inside
    final handset = Path()
      ..moveTo(6.5 * s, 7.2 * s)
      ..cubicTo(6.8 * s, 6.7 * s, 7.4 * s, 6.8 * s, 7.8 * s, 7.5 * s)
      ..lineTo(8.2 * s, 8.3 * s)
      ..cubicTo(8.4 * s, 8.7 * s, 8.2 * s, 9.0 * s, 7.8 * s, 9.4 * s)
      ..cubicTo(8.3 * s, 10.2 * s, 8.8 * s, 10.7 * s, 9.6 * s, 11.2 * s)
      ..cubicTo(10.0 * s, 10.8 * s, 10.3 * s, 10.6 * s, 10.7 * s, 10.8 * s)
      ..lineTo(11.5 * s, 11.2 * s)
      ..cubicTo(12.2 * s, 11.6 * s, 12.3 * s, 12.2 * s, 11.8 * s, 12.5 * s)
      ..cubicTo(11.2 * s, 12.9 * s, 9.8 * s, 12.5 * s, 8.2 * s, 10.9 * s)
      ..cubicTo(6.5 * s, 9.2 * s, 6.1 * s, 7.8 * s, 6.5 * s, 7.2 * s)
      ..close();

    final handsetPaint = Paint()
      ..color = const Color(0xFF374151)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(handset, handsetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
