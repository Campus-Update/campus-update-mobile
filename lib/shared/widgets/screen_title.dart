import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The centred heading and the muted line under it, which nearly every screen
/// in the auth flow opens with.
///
/// Both styles come from the type scale, which was measured off these very
/// screens — 24/500 on a 36 line for the title, 12/400 on a 100% line for the
/// subtitle.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  /// Gap between the two lines.
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.graphite,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: _gap),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
