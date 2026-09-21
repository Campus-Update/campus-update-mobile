import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _remember = false;

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
  bool get _hasSpecial => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_password.text);
  bool get _matches =>
      _password.text.isNotEmpty && _password.text == _confirm.text;

  bool get _allValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecial &&
      _matches;

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (!_allValid) return;
    context.go(Routes.login);
  }

  Widget _buildRuleItem(String label, bool isSatisfied) {
    final color = isSatisfied ? AppColors.emerald : AppColors.alertRed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w400,
              ),
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
              const SizedBox(height: 8),
              Text(
                'Password must contain:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.fieldLabel,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              _buildRuleItem('At least 8 characters', _hasMinLength),
              _buildRuleItem('At least 1 uppercase letter (A–Z)', _hasUppercase),
              _buildRuleItem('At least 1 lowercase letter (a–z)', _hasLowercase),
              _buildRuleItem('At least 1 number (0–9)', _hasNumber),
              _buildRuleItem(
                'At least 1 special character (! @ # \$ %)',
                _hasSpecial,
              ),
              _buildRuleItem('Password matches', _matches),
              const SizedBox(height: 8),
              AppCheckbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
                label: 'Remember Me',
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthGaps.toButton),
        AppButton(
          label: 'Reset Password',
          onPressed: _submit,
        ),
      ],
    );
  }
}
