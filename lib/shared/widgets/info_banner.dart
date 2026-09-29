import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The quiet strip that explains a consequence of what was just chosen.
///
/// Sizing is inferred from the design's institution step rather than read off
/// an inspect; confirm when one is to hand.
class InfoBanner extends StatelessWidget {
  const InfoBanner(
    this.message, {
    super.key,
    this.icon = Icons.shield_outlined,
  });

  final String message;
  final IconData icon;

  static const _radius = 10.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const _gap = 8.0;
  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.formPanel,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: _iconSize, color: AppColors.indigo),
          const SizedBox(width: _gap),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 11,
                color: AppColors.fieldLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
