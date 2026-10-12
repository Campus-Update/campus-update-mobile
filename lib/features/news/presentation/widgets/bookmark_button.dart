import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The bookmark toggle on a news [ContentCard], in its trailing slot.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
  });

  final bool isBookmarked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border_rounded,
          size: 18,
          color: isBookmarked ? AppColors.indigo : AppColors.sourceSponsored,
        ),
      ),
    );
  }
}
