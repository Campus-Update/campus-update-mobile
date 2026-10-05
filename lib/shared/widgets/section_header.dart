import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The heading above a content list: a title on the left, a link on the right.
///
/// 'Latest News · See all' and 'Upcoming Events · See all' are the same row
/// with a different string and route, so it is one widget. Values are the ones
/// the home screen already shipped with.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See all',
    this.onAction,
  });

  final String title;

  /// The link on the right. Hidden when [onAction] is null.
  final String actionLabel;

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: AppFonts.medium,
            color: AppColors.feedTitle,
            letterSpacing: -0.2,
          ),
        ),
        if (onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: AppFonts.medium,
                color: AppColors.feedLink,
              ),
            ),
          ),
      ],
    );
  }
}
