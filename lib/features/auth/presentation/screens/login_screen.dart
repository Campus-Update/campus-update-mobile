import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/auth_page.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // Validation runs and reports; there is nothing to call yet. The auth
    // repository lands with the API wiring, and this is where it goes.
    if (!(_form.currentState?.validate() ?? false)) return;
  }

  /// No provider on the backend yet. Left enabled so the screen matches the
  /// design; it does no more than the primary button does until the API is
  /// wired, and both land together.
  void _google() {}

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Welcome back',
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
                autofillHints: const [AutofillHints.username],
                validator: Validators.email,
              ),
              AppInput(
                label: 'Password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: Validators.password,
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
        AppButton(label: 'Sign in', onPressed: _submit),
        const SizedBox(height: AuthGaps.toLink),
        AppLinkText(
          "Don't have an account yet? Create account",
          links: {'Create account': () => context.push(Routes.register)},
        ),
        const SizedBox(height: AuthGaps.toDivider),
        const LabelledDivider(label: 'Or login with'),
        const SizedBox(height: AuthGaps.toSocial),
        SocialButton(label: 'Continue with Google', onPressed: _google),
      ],
    );
  }
}
