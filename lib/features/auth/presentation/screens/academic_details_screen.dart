import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
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

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _hasName => _name.text.trim().isNotEmpty;

  void _finish() {
    if (!_hasName) return;
    context.go(Routes.home);
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
      footer: AppButton(
        label: 'Continue',
        onPressed: _hasName ? _finish : null,
      ),
    );
  }
}
