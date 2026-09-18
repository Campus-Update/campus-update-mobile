import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Back arrow, centred title, matching spacer on the right so the title is
/// optically centred regardless of the action slot.
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.action,
  });

  final String title;

  /// Defaults to popping the current route.
  final VoidCallback? onBack;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.headerHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
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
