import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

/// Blocked: the verification rule is still undefined — see
/// `docs/ARCHITECTURE.md` and the open questions. Do not build this screen
/// until the rule is agreed.
class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Verify your account',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
