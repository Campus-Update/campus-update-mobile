import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/domain/content_item.dart';
import '../../../../shared/domain/content_source.dart';

/// A single alert card matching the design: urgency icon + label at top,
/// thin horizontal divider, bold title, and muted timestamp.
class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.item, this.onTap});

  final ContentItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (urgencyColor, urgencyIcon, urgencyLabel) = _styleFor(item.urgency);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency header: icon + label.
            Row(
              children: [
                Icon(urgencyIcon, size: 16, color: urgencyColor),
                const SizedBox(width: 6),
                Text(
                  urgencyLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.family,
                    fontSize: 13,
                    fontWeight: AppFonts.medium,
                    color: urgencyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Subtle divider spanning across card.
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 10),

            // Alert title.
            Text(
              item.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.family,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Timestamp.
            Text(
              _relativeTime(item.publishedAt),
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: AppFonts.family,
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (Color, IconData, String) _styleFor(Urgency urgency) =>
      switch (urgency) {
        Urgency.urgent => (
          const Color(0xFFEF4444),
          Icons.warning_amber_rounded,
          'Urgent',
        ),
        Urgency.important => (
          const Color(0xFF0D9488),
          Icons.info_outline,
          'Important',
        ),
        Urgency.normal => (
          const Color(0xFF6366F1),
          Icons.notifications_none_rounded,
          'Normal',
        ),
      };

  /// Formats a timestamp as a friendly relative string.
  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
