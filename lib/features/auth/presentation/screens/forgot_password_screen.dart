import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../core/network/api_exception.dart';
import 'verify_otp_screen.dart';
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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    final email = _email.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // The API answers the same whether or not the address has an
      // account, so a success here says only that the request went.
      await ref.read(authRepositoryProvider).forgotPassword(email);
      if (!mounted) return;
      context.push(
        Routes.verifyOtp,
        extra: OtpArgs(
          title: 'Check Your Email',
          next: Routes.resetPassword,
          email: email,
          length: 8,
        ),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                hint: 'Enter Email Address',
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
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.alertRed),
          ),
        ],
        const SizedBox(height: AuthGaps.toButton),
        AppButton(
          label: 'Send verification code',
          loading: _busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
