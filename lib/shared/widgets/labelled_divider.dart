import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// A rule with a word in the middle — "Or login with".
///
/// The rules take whatever width the label leaves, which is how the design's
/// own auto-layout arrives at its 103.61 each side.
class LabelledDivider extends StatelessWidget {
  const LabelledDivider({super.key, required this.label});

  final String label;

  /// The design gives the rule [AppColors.fieldLabel] at half opacity.
  static const _opacity = 0.5;
  static const _thickness = 1.0;

  /// Space between each rule and the label. Not specified by design; chosen
  /// so the rules come out near the design's measured length.
  static const _gap = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rule = Divider(
      color: AppColors.fieldLabel.withValues(alpha: _opacity),
      thickness: _thickness,
      height: _thickness,
    );

    return Row(
      children: [
        Expanded(child: rule),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gap),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.fieldLabel,
            ),
          ),
        ),
        Expanded(child: rule),
      ],
    );
  }
}
