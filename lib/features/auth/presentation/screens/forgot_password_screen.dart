import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    context.push(Routes.verifyOtp, extra: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Forgot Password',
      subtitle:
          "No worries! Enter your email address and we'll send you a verification code to reset your password.",
      subtitleMaxLines: 3,
      leading: Image.asset(
        'assets/icons/forgot_password.png',
        width: 150,
        height: 141,
        fit: BoxFit.contain,
      ),
      leadingGap: 16.0,
      children: [
        Form(
          key: _form,
          child: AppFormPanel(
            children: [
              AppInput(
                label: 'Email Address',
                hint: 'Enter First Name',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                onSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthGaps.toButton),
        AppButton(label: 'Send verification code', onPressed: _submit),
      ],
    );
  }
}
