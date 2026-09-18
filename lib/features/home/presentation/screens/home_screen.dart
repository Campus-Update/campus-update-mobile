import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/widgets.dart';

/// The central landing screen.
///
/// Per the PRD it aggregates the other surfaces: prominent announcements,
/// recent news, upcoming events and relevant calendar dates, all filtered by
/// the user's institution and information preference. The links below stand in
/// until those sections exist.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const EmptyState(
            message: 'Home not built yet.',
            icon: Icons.construction_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => context.push(Routes.calendar),
            child: const Text('School calendar'),
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
        ],
      ),
    );
  }
}
