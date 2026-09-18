import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/env/env.dart';
import '../../../../shared/widgets/widgets.dart';

/// Placeholder. The real form lands with the auth flow; for now this exists so
/// the navigation can be walked end to end.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Sign in',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const EmptyState(
            message: 'Sign-in form not built yet.',
            icon: Icons.construction_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => context.push(Routes.register),
            child: const Text('Create account'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.forgotPassword),
            child: const Text('Forgot password'),
          ),
          if (Env.isDev) ...[
            const SizedBox(height: AppSpacing.xl),
            // TEMPORARY: removed once real sign-in exists.
            AppButton(
              label: 'Skip sign in (dev)',
              onPressed: () => ref.read(authProvider.notifier).signedIn(),
            ),
          ],
        ],
      ),
    );
  }
}
