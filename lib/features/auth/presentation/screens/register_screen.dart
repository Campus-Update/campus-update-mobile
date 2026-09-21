import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? value) {
    final first = Validators.password(value);
    if (first != null) return first;
    return value == _password.text ? null : 'Passwords do not match';
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    // Nothing registers the account yet — that call lands with the API, and
    // it needs the institution, role and academic details the questions after
    // this collect. For now the form only carries the flow forward.
    context.push(Routes.verifyOtp);
  }

  /// No provider on the backend yet. Left enabled so the screen matches the
  /// design; it does no more than the primary button does until the API is
  /// wired, and both land together.
  void _google() {}

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Create Account',
      subtitle: 'Sign in to manage your campus latest news and information',
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
              ),
              AppInput(
                label: 'Password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.password,
              ),
              AppInput(
                label: 'Re-enter Password',
                controller: _confirm,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: _confirmValidator,
                // Done puts the keyboard away. It deliberately does not
                // submit: the form goes forward only when the button is
                // tapped.
                onSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AppCheckbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v),
                      label: 'Remember Me',
                    ),
                  ),
                  Flexible(
                    child: AppLinkText(
                      'Forgot Password?',
                      underline: true,
                      textAlign: TextAlign.right,
                      links: {
                        'Forgot Password?': () =>
                            context.push(Routes.forgotPassword),
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AuthGaps.toButton),
        AppButton(label: 'Create account', onPressed: _submit),
        const SizedBox(height: AuthGaps.toLink),
        AppLinkText(
          'Already have an Account? Login',
          links: {'Login': () => context.go(Routes.login)},
        ),
        const SizedBox(height: AuthGaps.toDivider),
        const LabelledDivider(label: 'Or sign up with'),
        const SizedBox(height: AuthGaps.toSocial),
        SocialButton(label: 'Google', onPressed: _google),
        const SizedBox(height: AuthGaps.toTerms),
        AppLinkText(
          "By creating an account you agree to Campus Update's Terms and "
          'Privacy notice.',
          links: {'Terms': _openTerms, 'Privacy': _openPrivacy},
        ),
      ],
    );
  }

  // No destinations published yet; wired when the URLs are settled.
  void _openTerms() {}
  void _openPrivacy() {}
}
