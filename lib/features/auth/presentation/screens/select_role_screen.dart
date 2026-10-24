import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/auth/auth_repository.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/registration_draft.dart';
import '../widgets/kyu_page.dart';

/// Step two: student or staff.
///
/// The answer decides what the next question asks — staff have no programme
/// or level — so it travels on rather than being read back from anywhere.
class SelectRoleScreen extends ConsumerStatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  ConsumerState<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends ConsumerState<SelectRoleScreen> {
  bool? _isStudent;

  void _continue() {
    final student = _isStudent;
    if (student == null) return;
    ref
        .read(registrationDraftProvider.notifier)
        .setRole(student ? UserRole.student : UserRole.staff);
    context.push(Routes.academicDetails, extra: student);
  }

  @override
  Widget build(BuildContext context) {
    return KyuPage(
      step: 2,
      title: 'Are you a student or staff?',
      subtitle:
          'This decides which announcements reach you. Staff communication '
          'never goes to students, whatever your preferences say.',
      body: Column(
        children: [
          OptionRow(
            title: 'Student',
            subtitle:
                'News, announcements and events for your programme and level.',
            selected: _isStudent == true,
            onTap: () => setState(() => _isStudent = true),
          ),
          const SizedBox(height: OptionRow.gap),
          OptionRow(
            title: 'Staff',
            subtitle:
                'Institution, faculty, department and staff '
                'communications.',
            selected: _isStudent == false,
            onTap: () => setState(() => _isStudent = false),
          ),
        ],
      ),
      footer: AppButton(
        label: 'Continue',
        onPressed: _isStudent == null ? null : _continue,
      ),
    );
  }
}
