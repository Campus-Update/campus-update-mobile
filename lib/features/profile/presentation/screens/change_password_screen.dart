import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_form_panel.dart';
import '../../../../shared/widgets/app_input.dart';
import '../widgets/profile_screen_header.dart';

/// Screen allowing the user to update their account password.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUppercase =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase =>
      _newPasswordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _newPasswordController.text.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );
  bool get _passwordsMatch =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _newPasswordController.text;

  bool get _isValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar &&
      _passwordsMatch &&
      _currentPasswordController.text.isNotEmpty;

  Future<void> _saveChanges() async {
    if (_busy) return;

    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your current password')),
      );
      return;
    }

    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please satisfy all password criteria before saving'),
        ),
      );
      return;
    }

    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _busy = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Widget _buildRuleItem(String text, bool satisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: satisfied
                  ? const Color(0xFF059669)
                  : const Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.family,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: satisfied
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Change Password'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFormPanel(
                      children: [
                        AppInput(
                          label: 'Current Password',
                          controller: _currentPasswordController,
                          obscure: true,
                          textInputAction: TextInputAction.next,
                        ),
                        AppInput(
                          label: 'New Password',
                          controller: _newPasswordController,
                          obscure: true,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.next,
                        ),
                        AppInput(
                          label: 'Confirm New Password',
                          controller: _confirmPasswordController,
                          obscure: true,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password must contain:',
                      style: TextStyle(
                        fontFamily: AppFonts.family,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRuleItem('At least 8 characters', _hasMinLength),
                    _buildRuleItem(
                      'At least 1 uppercase letter (A-Z)',
                      _hasUppercase,
                    ),
                    _buildRuleItem(
                      'At least 1 lowercase letter (a-z)',
                      _hasLowercase,
                    ),
                    _buildRuleItem('At least 1 number (0-9)', _hasNumber),
                    _buildRuleItem(
                      'At least 1 special character (e.g. ! @ # \$ %)',
                      _hasSpecialChar,
                    ),
                    _buildRuleItem('Password matches', _passwordsMatch),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Save changes',
                      variant: AppButtonVariant.primary,
                      loading: _busy,
                      onPressed: _saveChanges,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
