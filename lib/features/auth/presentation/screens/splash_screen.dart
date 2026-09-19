import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

/// Shown while the session is restored from secure storage. The router moves
/// on as soon as that resolves, so this is usually on screen only briefly.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 96),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Campus Update',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
