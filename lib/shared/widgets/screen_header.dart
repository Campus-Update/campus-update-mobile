import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import 'back_button_circle.dart';

/// Back arrow or circular back button, centred title, matching spacer on the
/// right so the title is optically centred regardless of the action slot.
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
    this.useCircleButton = false,
  });

  final String title;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;
  final Widget? action;

  /// When true, renders [BackButtonCircle] with gutter padding rather than
  /// the standard back arrow.
  final bool useCircleButton;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.headerHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    if (useCircleButton) {
      return SizedBox(
        height: AppSpacing.headerHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Row(
            children: [
              BackButtonCircle(onPressed: onBack),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.family,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.graphite,
                  ),
                ),
              ),
              SizedBox(
                width: BackButtonCircle.size,
                child: action,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: AppSpacing.headerHeight,
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.headerHeight,
            child: canPop || onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  )
                : null,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(width: AppSpacing.headerHeight, child: action),
        ],
      ),
    );
  }
}
