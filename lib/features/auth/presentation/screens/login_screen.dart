import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../features/profile/data/profile_providers.dart';
import '../../../../features/profile/data/profile_repository.dart';
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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!(_form.currentState?.validate() ?? false)) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .login(email: _email.text.trim(), password: _password.text);

      // Login hands back tokens and nothing else, so who the session belongs
      // to has to be fetched. On a device the user did not register on there
      // is nothing stored locally, and without this the home screen greets
      // them by the front of their email address.
      //
      // A failure here must not block the sign-in: the credentials were
      // accepted and the tokens are stored. The email still gives the
      // greeting something to fall back on.
      await _loadProfile();

      // Telling the notifier is what moves the router out of the signed-out
      // zone.
      ref.read(authProvider.notifier).signedIn(email: _email.text.trim());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        // 401 here means the credentials are wrong, not that a session
        // lapsed — the default message would tell them to sign in again,
        // which is what they are already doing.
        _error = e.isUnauthorized
            ? 'That email and password do not match.'
            : e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// No provider on the backend yet. Left enabled so the screen matches the
  /// design; it does no more than the primary button does until the API is
  /// wired, and both land together.
  void _google() {}

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).fetch();
      await ref.read(userProfileProvider.notifier).setProfile(profile);
    } on ApiException {
      // Signed in regardless; the greeting falls back to the email.
    }
  }

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
                hint: 'Enter Email Address',
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
        if (_error != null) ...[
          const SizedBox(height: AuthGaps.toLink),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.alertRed),
          ),
        ],
        const SizedBox(height: AuthGaps.toButton),
        AppButton(label: 'Sign in', loading: _busy, onPressed: _submit),
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
