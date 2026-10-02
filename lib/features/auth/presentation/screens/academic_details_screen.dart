import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_repository.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/registration_draft.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../widgets/kyu_page.dart';

/// Step three: where the person sits in the school.
///
/// A student is asked for programme and level as well; staff have neither,
/// so the form is shorter. Only the name is required — the API takes the
/// rest as nullable, and the screen says as much.
class AcademicDetailsScreen extends ConsumerStatefulWidget {
  const AcademicDetailsScreen({super.key, required this.isStudent});

  final bool isStudent;

  @override
  ConsumerState<AcademicDetailsScreen> createState() =>
      _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends ConsumerState<AcademicDetailsScreen> {
  final _name = TextEditingController();
  String? _faculty;
  String? _department;
  String? _programme;
  String? _level;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _hasName => _name.text.trim().isNotEmpty;

  /// The end of the questions is where the account is finally created: this
  /// is the first moment every field register insists on exists.
  Future<void> _finish() async {
    if (_busy || !_hasName) return;

    final drafts = ref.read(registrationDraftProvider.notifier)
      ..setDetails(
        fullName: _name.text.trim(),
        facultyId: _faculty,
        departmentId: _department,
        programmeId: _programme,
        academicLevelId: _level,
      );
    final request = ref.read(registrationDraftProvider).toRequest();
    if (request == null) {
      setState(
        () => _error = 'Something is missing. Please go back and check.',
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(authRepositoryProvider).register(request);
      drafts.clear();
      // Registering returns a session, so there is no separate sign-in.
      ref.read(authProvider.notifier).signedIn();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        // The email is chosen four screens back, so say where to fix it.
        _error = e.isConflict
            ? 'That email is already registered. Go back and use another, '
                  'or sign in instead.'
            : e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KyuPage(
      step: 3,
      title: 'Tell us where you sit',
      subtitle:
          'This is what lets Campus Update put the right notices in front of '
          'you. Only your name is required, the rest can wait, and all of it '
          'is editable later.',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormPanel(
              children: [
                AppInput(
                  label: 'Full Name',
                  hint: 'Enter Name',
                  controller: _name,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.name],
                ),
                AppSelect(
                  label: 'Faculty',
                  hint: 'Select Faculty',
                  value: _faculty,
                  // Filled from GET /api/v1/schools once it is wired; the
                  // institution picked in step one supplies the tree.
                  options: const [],
                  onChanged: (v) => setState(() => _faculty = v),
                ),
                AppSelect(
                  label: 'Department',
                  hint: 'Select Department',
                  value: _department,
                  options: const [],
                  onChanged: (v) => setState(() => _department = v),
                ),
                if (widget.isStudent) ...[
                  AppSelect(
                    label: 'Programme',
                    hint: 'Select Programme',
                    value: _programme,
                    options: const [],
                    onChanged: (v) => setState(() => _programme = v),
                  ),
                  AppSelect(
                    label: 'Level',
                    hint: 'Select Level',
                    value: _level,
                    options: const [],
                    onChanged: (v) => setState(() => _level = v),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Faculty, department and level come next — you can add them any '
              'time.',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      // No Skip: the name is where firstName and lastName come from, and
      // registration requires both. The four selects below it stay optional,
      // which is what the API's nullable ids allow for.
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.alertRed,
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Continue',
            loading: _busy,
            onPressed: _hasName ? _finish : null,
          ),
        ],
      ),
    );
  }
}
