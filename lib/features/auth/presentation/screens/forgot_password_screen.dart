import 'package:flutter/material.dart';

import '../../../../shared/widgets/widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Reset password',
      child: EmptyState(
        message: 'Not built yet.',
        icon: Icons.construction_outlined,
      ),
    );
  }
}
