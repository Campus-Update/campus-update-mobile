import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';
import 'verify_otp_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.args});

  /// The email and code from the screens before. Null if the screen was
  /// reached any other way, when there is nothing to reset with.
  final PasswordResetArgs? args;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _remember = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _password.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_password.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_password.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password.text);
  bool get _hasSpecial =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password.text);
  bool get _matches =>
      _password.text.isNotEmpty && _password.text == _confirm.text;

  /// Every rule the screen displays. The button is the only way forward, so
  /// this is what makes the list mean something rather than describe it.
  bool get _isValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial &&
      _matches;

  Future<void> _submit() async {
    final args = widget.args;
    if (!_isValid || _busy) return;
    if (args == null) {
      setState(() => _error = 'Start again from Forgot Password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            email: args.email,
            code: args.code,
            newPassword: _password.text,
          );
      if (mounted) context.go(Routes.passwordResetSuccess);
    } on ApiException catch (e) {
      // A wrong or expired code only shows up here, so say where to fix it.
      if (mounted) {
        setState(
          () => _error = e.statusCode == 400
              ? '${e.message} Go back to enter it again, or resend it.'
              : e.message,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// One rule. The design sets these 19 apart: a 12 line plus [_ruleGap].
  static const _ruleGap = 7.0;

  Widget _buildRuleItem(String label, bool isSatisfied) {
    final color = isSatisfied ? AppColors.emerald : AppColors.alertRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: _ruleGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Create New Password',
      subtitle:
          'Your new password must be different from previously used passwords.',
      subtitleMaxLines: 2,
      children: [
        Form(
          key: _form,
          child: AppFormPanel(
            children: [
              AppInput(
                label: 'New Password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
              ),
              AppInput(
                label: 'Confirm Password',
                controller: _confirm,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              // The heading and its rules are a single panel child. Passed
              // separately they would each pick up AppFormPanel's own gap,
              // which is what spread them to roughly 32 apart.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Password must contain:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.fieldLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: _ruleGap),
                  _buildRuleItem('At least 8 characters', _hasMinLength),
                  _buildRuleItem(
                    'At least 1 uppercase letter (A–Z)',
                    _hasUppercase,
                  ),
                  _buildRuleItem(
                    'At least 1 lowercase letter (a–z)',
                    _hasLowercase,
                  ),
                  _buildRuleItem('At least 1 number (0–9)', _hasNumber),
                  _buildRuleItem(
                    'At least 1 special character (! @ # \$ %)',
                    _hasSpecial,
                  ),
                  _buildRuleItem('Password matches', _matches),
                ],
              ),
              AppCheckbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
                label: 'Remember Me',
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
        // Disabled until the rules pass, so the list above explains why
        // rather than the tap doing nothing.
        AppButton(
          label: 'Reset Password',
          loading: _busy,
          onPressed: _isValid ? _submit : null,
        ),
      ],
    );
  }
}
