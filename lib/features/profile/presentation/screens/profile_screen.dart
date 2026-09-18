import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../shared/widgets/widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const EmptyState(
            message: 'Profile not built yet.',
            icon: Icons.construction_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => context.push(Routes.editProfile),
            child: const Text('Edit profile'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.preferences),
            child: const Text('Preferences'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.notifications),
            child: const Text('Notifications'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push(Routes.search),
            child: const Text('Search'),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Sign out',
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
