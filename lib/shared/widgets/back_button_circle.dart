import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// The circular back button the design puts at the top left of a screen.
///
/// Renders nothing when there is nowhere to go back to, so a screen reached
/// by replacing the stack — the first screen of a flow — does not show a
/// button that would do nothing.
///
/// Sizing is taken from the design's academic questions, which are the only
/// frames that draw it; confirm against Figma when its inspect is to hand.
class BackButtonCircle extends StatelessWidget {
  const BackButtonCircle({super.key, this.onPressed});

  /// Defaults to popping the current route.
  final VoidCallback? onPressed;

  static const size = 40.0;
  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    if (!canPop && onPressed == null) return const SizedBox.shrink();

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.fieldBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.chevron_left,
            size: _iconSize,
            color: AppColors.graphite,
          ),
        ),
      ),
    );
  }
}
