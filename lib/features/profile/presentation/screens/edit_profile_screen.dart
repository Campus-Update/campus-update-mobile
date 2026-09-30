import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/utils/validators.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _idNumber;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _firstName = TextEditingController(text: profile?.firstName ?? '');
    _lastName = TextEditingController(text: profile?.lastName ?? '');
    _email = TextEditingController(text: profile?.email ?? '');
    _idNumber = TextEditingController(
      text: profile?.matriculationOrStaffNumber ?? '',
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();
    final idNumber = _idNumber.text.trim();

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          firstName: firstName,
          lastName: lastName,
          matriculationOrStaffNumber: idNumber.isNotEmpty ? idNumber : null,
        );

    if (firstName.isNotEmpty) {
      ref.read(pendingProfileProvider.notifier).complete();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit profile',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppFormPanel(
                children: [
                  AppInput(
                    label: 'First Name',
                    hint: 'Enter your first name',
                    controller: _firstName,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.givenName],
                    validator: (v) => Validators.required(v, 'First name'),
                  ),
                  AppInput(
                    label: 'Last Name',
                    hint: 'Enter your last name',
                    controller: _lastName,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.familyName],
                  ),
                  AppInput(
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    controller: _email,
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  AppInput(
                    label: 'Matriculation / Staff Number',
                    hint: 'e.g. 2026/12345',
                    controller: _idNumber,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Save profile', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
