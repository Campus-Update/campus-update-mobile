import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../domain/content_source.dart';

/// Announcement priority.
///
/// The PRD requires priority to be distinguishable **not by colour alone**, so
/// each level carries its own icon and its own word. Colour is reinforcement,
/// never the only signal.
class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge({super.key, required this.urgency});

  final Urgency urgency;

  (Color, IconData, String) get _style => switch (urgency) {
    Urgency.urgent => (AppColors.urgencyUrgent, Icons.error_outline, 'Urgent'),
    Urgency.important => (
      AppColors.urgencyImportant,
      Icons.priority_high,
      'Important',
    ),
    Urgency.normal => (AppColors.urgencyNormal, Icons.info_outline, 'Normal'),
  };

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _style;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
