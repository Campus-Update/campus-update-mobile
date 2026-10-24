import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_form_panel.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_select.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/data/school_repository.dart';
import '../../../auth/domain/institution.dart';
import '../../data/profile_providers.dart';
import '../widgets/profile_screen_header.dart';

/// Screen allowing the user to edit their profile details and academic settings.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  Faculty? _selectedFaculty;
  Department? _selectedDepartment;
  Programme? _selectedProgramme;
  AcademicLevel? _selectedLevel;
  bool _busy = false;

  /// Whether the dropdowns have been set from the saved profile. That waits
  /// for the user's school to load, so it happens on the first build that has
  /// it rather than in [initState].
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _firstName = TextEditingController(text: profile?.firstName ?? '');
    _lastName = TextEditingController(text: profile?.lastName ?? '');
  }

  /// Sets the dropdowns to what the profile already holds, within [inst].
  void _prefill(Institution inst) {
    _prefilled = true;
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;

    if (profile.facultyId != null || profile.facultyName != null) {
      _selectedFaculty = inst.faculties
          .where(
            (f) => f.id == profile.facultyId || f.name == profile.facultyName,
          )
          .firstOrNull;
    }

    if (_selectedFaculty != null &&
        (profile.departmentId != null || profile.departmentName != null)) {
      _selectedDepartment = _selectedFaculty!.departments
          .where(
            (d) =>
                d.id == profile.departmentId ||
                d.name == profile.departmentName,
          )
          .firstOrNull;
    }

    if (_selectedDepartment != null &&
        (profile.programmeId != null || profile.programmeName != null)) {
      _selectedProgramme = _selectedDepartment!.programmes
          .where(
            (p) =>
                p.id == profile.programmeId || p.name == profile.programmeName,
          )
          .firstOrNull;
    }

    if (_selectedProgramme != null &&
        (profile.academicLevelId != null ||
            profile.academicLevelName != null)) {
      _selectedLevel = _selectedProgramme!.levels
          .where(
            (l) =>
                l.id == profile.academicLevelId ||
                l.name == profile.academicLevelName,
          )
          .firstOrNull;
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  /// The signed-in user's own school, from `GET /schools`, whose faculties
  /// the dropdowns offer. Null while the schools load, or signed out.
  Institution? _school() {
    final profile = ref.watch(userProfileProvider);
    if (profile == null) return null;
    final schools = ref.watch(schoolsProvider).value ?? const <Institution>[];
    return schools.where((s) => s.id == profile.institutionId).firstOrNull;
  }

  Future<void> _saveChanges() async {
    if (_busy) return;
    setState(() => _busy = true);

    final firstName = _firstName.text.trim();
    final lastName = _lastName.text.trim();

    final institution = _school();
    final notifier = ref.read(userProfileProvider.notifier);

    // Signed in, the change goes to the API; signed out, there is only the
    // copy on this phone to update.
    if (ref.read(userProfileProvider) != null) {
      try {
        await notifier.saveDetails(
          firstName: firstName,
          lastName: lastName,
          institution: institution,
          faculty: _selectedFaculty,
          department: _selectedDepartment,
          programme: _selectedProgramme,
          level: _selectedLevel,
        );
      } on ApiException catch (e) {
        if (mounted) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
        return;
      }
    } else {
      await notifier.updateProfile(
        firstName: firstName,
        lastName: lastName,
        institutionId: institution?.id,
        institutionName: institution?.name,
        facultyId: _selectedFaculty?.id,
        facultyName: _selectedFaculty?.name,
        departmentId: _selectedDepartment?.id,
        departmentName: _selectedDepartment?.name,
        programmeId: _selectedProgramme?.id,
        programmeName: _selectedProgramme?.name,
        academicLevelId: _selectedLevel?.id,
        academicLevelName: _selectedLevel?.name,
      );
    }

    ref.read(pendingProfileProvider.notifier).complete();

    if (mounted) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details updated successfully')),
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final institution = _school();
    if (institution != null && !_prefilled) _prefill(institution);
    final faculties = institution?.faculties ?? const <Faculty>[];
    final departments = _selectedFaculty?.departments ?? const <Department>[];
    final programmes = _selectedDepartment?.programmes ?? const <Programme>[];
    final levels = _selectedProgramme?.levels ?? const <AcademicLevel>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileScreenHeader(title: 'Edit details'),
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
                        // Two fields, as on sign-up and in the API. One name
                        // split on the first space guesses where the surname
                        // starts, and guesses wrong for anyone with two given
                        // names or a compound surname.
                        AppInput(
                          label: 'First Name',
                          hint: 'Enter First Name',
                          controller: _firstName,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                        ),
                        AppInput(
                          label: 'Last Name',
                          hint: 'Enter Last Name',
                          controller: _lastName,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                        ),
                        AppSelect<Faculty>(
                          label: 'Faculty',
                          hint: 'Select Faculty',
                          value: _selectedFaculty,
                          options: faculties,
                          labelOf: (f) => f.name,
                          onChanged: (v) => setState(() {
                            _selectedFaculty = v;
                            _selectedDepartment = null;
                            _selectedProgramme = null;
                            _selectedLevel = null;
                          }),
                        ),
                        AppSelect<Department>(
                          label: 'Department',
                          hint: 'Select Department',
                          value: _selectedDepartment,
                          options: departments,
                          labelOf: (d) => d.name,
                          onChanged: (v) => setState(() {
                            _selectedDepartment = v;
                            _selectedProgramme = null;
                            _selectedLevel = null;
                          }),
                        ),
                        AppSelect<Programme>(
                          label: 'Programme',
                          hint: 'Select Programme',
                          value: _selectedProgramme,
                          options: programmes,
                          labelOf: (p) => p.name,
                          onChanged: (v) => setState(() {
                            _selectedProgramme = v;
                            _selectedLevel = null;
                          }),
                        ),
                        AppSelect<AcademicLevel>(
                          label: 'Level',
                          hint: 'Select Level',
                          value: _selectedLevel,
                          options: levels,
                          labelOf: (l) => l.name,
                          onChanged: (v) => setState(() {
                            _selectedLevel = v;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Save changes',
                      loading: _busy,
                      // Both names are required, as on sign-up.
                      onPressed:
                          _firstName.text.trim().isEmpty ||
                              _lastName.text.trim().isEmpty
                          ? null
                          : _saveChanges,
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
