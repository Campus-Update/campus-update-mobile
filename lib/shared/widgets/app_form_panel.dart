import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The lavender card that groups a form's fields.
///
/// It appears on seven screens in the auth flow and is what holds the design
/// together: the fields inside it are white, which only reads because this
/// sits behind them. Put the whole form in one — label, field, and the row of
/// links or checkboxes that belongs with it.
///
/// Figures measured off the design at its 393pt frame width.
class AppFormPanel extends StatelessWidget {
  const AppFormPanel({super.key, required this.children});

  /// Stacked in order, separated by [_gap]. Keeping the spacing here rather
  /// than at the call site is the point: every form then breathes the same.
  final List<Widget> children;

  static const _radius = 10.0;
  static const _gap = 10.0;

  /// Deliberately uneven — the design gives the foot more room than the head,
  /// which is where the checkbox and link row sit.
  static const _padding = EdgeInsets.fromLTRB(17, 21, 18, 29);

  /// The gutter a screen should give this panel, so it comes out at the
  /// design's 347 on a 393 frame. Wider than [AppSpacing.gutter].
  static const gutter = 23.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: _padding,
      decoration: BoxDecoration(
        color: AppColors.formPanel,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: _gap),
            children[i],
          ],
        ],
      ),
    );
  }
}
