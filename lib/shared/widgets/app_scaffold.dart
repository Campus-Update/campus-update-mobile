import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'screen_header.dart';

/// Standard page shell: safe area, consistent gutter, optional header.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.onBack,
    this.action,
    this.padded = true,
    this.bottom,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onBack;
  final Widget? action;

  /// Set false for lists that should bleed to the screen edge.
  final bool padded;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (title != null)
              ScreenHeader(title: title!, onBack: onBack, action: action),
            Expanded(
              child: padded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter,
                      ),
                      child: child,
                    )
                  : child,
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
