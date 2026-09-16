import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../domain/content_source.dart';

/// The trust indicator.
///
/// The PRD makes this a hard requirement: every item must visibly say where it
/// came from. It is never optional on a content surface.
class SourceBadge extends StatelessWidget {
  const SourceBadge({
    super.key,
    required this.source,
    this.contentType = ContentType.news,
  });

  final ContentSource source;

  /// Only changes the wording: an official event reads "Official Event".
  final ContentType contentType;

  Color get _color => switch (source) {
    ContentSource.officialSchool => AppColors.sourceOfficial,
    ContentSource.campusUpdate => AppColors.sourceCampusUpdate,
    ContentSource.sponsored => AppColors.sourceSponsored,
    ContentSource.externalEvent => AppColors.sourceExternal,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        source.labelFor(contentType),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _color),
      ),
    );
  }
}
