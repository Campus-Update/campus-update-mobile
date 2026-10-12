import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A content item's category as a solid pill — 'Academics', 'Campus'.
///
/// Fully rounded, white label on [AppColors.categoryPill], as the news detail
/// design draws it. The label is 12pt rather than the design's 10, which was
/// too small to read.
class CategoryPill extends StatelessWidget {
  const CategoryPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.categoryPill,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          height: 14 / 12,
          fontWeight: AppFonts.medium,
          color: Colors.white,
        ),
      ),
    );
  }
}
