import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/screen_header.dart';

/// Top bar used across profile screens: delegates to the shared [ScreenHeader]
/// with circular back button treatment.
class ProfileScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ProfileScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const ScreenHeader(title: '').preferredSize;

  @override
  Widget build(BuildContext context) {
    return ScreenHeader(
      title: title,
      useCircleButton: true,
      onBack: onBack ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.home);
            }
          },
    );
  }
}
