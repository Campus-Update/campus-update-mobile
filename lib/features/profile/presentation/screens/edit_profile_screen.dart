import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_form_panel.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../../shared/widgets/app_select.dart';
import '../../../auth/domain/default_institution.dart';
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
  late final TextEditingController _fullNameController;
  Faculty? _selectedFaculty;
  Department? _selectedDepartment;
  Programme? _selectedProgramme;
  AcademicLevel? _selectedLevel;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    final initialName = profile?.fullName ?? '';
    _fullNameController = TextEditingController(text: initialName);

    // Attempt to pre-populate selected academic options if already saved
    final inst = defaultLeadCityUniversity;

    if (profile?.facultyId != null || profile?.facultyName != null) {
      _selectedFaculty = inst.faculties.where(
        (f) =>
            f.id == profile?.facultyId ||
            f.name == profile?.facultyName,
      ).firstOrNull;
    }

    if (_selectedFaculty != null &&
        (profile?.departmentId != null || profile?.departmentName != null)) {
      _selectedDepartment = _selectedFaculty!.departments.where(
        (d) =>
            d.id == profile?.departmentId ||
            d.name == profile?.departmentName,
      ).firstOrNull;
    }

    if (_selectedDepartment != null &&
        (profile?.programmeId != null || profile?.programmeName != null)) {
      _selectedProgramme = _selectedDepartment!.programmes.where(
        (p) =>
            p.id == profile?.programmeId ||
            p.name == profile?.programmeName,
      ).firstOrNull;
    }

    if (_selectedProgramme != null &&
        (profile?.academicLevelId != null || profile?.academicLevelName != null)) {
      _selectedLevel = _selectedProgramme!.levels.where(
        (l) =>
            l.id == profile?.academicLevelId ||
            l.name == profile?.academicLevelName,
      ).firstOrNull;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Institution _resolveInstitution() {
    return defaultLeadCityUniversity;
  }

  Future<void> _saveChanges() async {
    if (_busy) return;
    setState(() => _busy = true);

    final rawName = _fullNameController.text.trim();
    String? firstName;
    String? lastName;

    if (rawName.isNotEmpty) {
      final parts = rawName.split(RegExp(r'\s+'));
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final institution = _resolveInstitution();

    await ref.read(userProfileProvider.notifier).updateProfile(
          firstName: firstName,
          lastName: lastName,
          institutionId: institution.id,
          institutionName: institution.name,
          facultyId: _selectedFaculty?.id,
          facultyName: _selectedFaculty?.name,
          departmentId: _selectedDepartment?.id,
          departmentName: _selectedDepartment?.name,
          programmeId: _selectedProgramme?.id,
          programmeName: _selectedProgramme?.name,
          academicLevelId: _selectedLevel?.id,
          academicLevelName: _selectedLevel?.name,
        );

    if (rawName.isNotEmpty) {
      ref.read(pendingProfileProvider.notifier).complete();
    }

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
    final institution = _resolveInstitution();
    final faculties = institution.faculties;
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
                        AppInput(
                          label: 'Full name',
                          hint: 'Enter First Name',
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
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
