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

  /// Gap between the two lines. Derived rather than read off the design:
  /// its title sits on a 36 line, so the ink-to-ink gap is larger than the
  /// layout one by the slack above and below the cap.
  static const _gap = 12.0;

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
          // The design sets this as a single line and it fits at the default
          // text size with room to spare. Above roughly 1.15x it no longer
          // does, so it shrinks to fit rather than wrapping to two lines,
          // which is what the design asks for — at the cost of not growing
          // the whole way with the reader's font setting.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtitle!,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
