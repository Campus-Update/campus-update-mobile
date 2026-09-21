import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Password Reset!',
      subtitle:
          'Your password has been successfully reset. You can now sign in with your new password.',
      subtitleMaxLines: 2,
      leading: const _SuccessIllustration(),
      leadingGap: 24.0,
      children: [
        const SizedBox(height: AuthGaps.toButton),
        AppButton(
          label: 'Back to Sign In',
          onPressed: () => context.go(Routes.login),
        ),
      ],
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: const BoxDecoration(
        color: Color(0xFFEDE9FE),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(
            color: Color(0xFF4F46E5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}
