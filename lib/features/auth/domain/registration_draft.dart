import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_repository.dart';
import 'institution.dart';

/// The answers gathered on the way to creating an account.
///
/// Registration is one call but four screens, so the answers live here rather
/// than being threaded through navigation. Going back a step keeps what was
/// already typed, and the final screen can see everything at once.
class RegistrationDraft {
  const RegistrationDraft({
    this.email = '',
    this.password = '',
    this.institution,
    this.role,
    this.fullName = '',
    this.facultyId,
    this.departmentId,
    this.programmeId,
    this.academicLevelId,
  });

  final String email;
  final String password;
  final Institution? institution;
  final UserRole? role;
  final String fullName;
  final String? facultyId;
  final String? departmentId;
  final String? programmeId;
  final String? academicLevelId;

  RegistrationDraft copyWith({
    String? email,
    String? password,
    Institution? institution,
    UserRole? role,
    String? fullName,
    String? facultyId,
    String? departmentId,
    String? programmeId,
    String? academicLevelId,
  }) => RegistrationDraft(
    email: email ?? this.email,
    password: password ?? this.password,
    institution: institution ?? this.institution,
    role: role ?? this.role,
    fullName: fullName ?? this.fullName,
    facultyId: facultyId ?? this.facultyId,
    departmentId: departmentId ?? this.departmentId,
    programmeId: programmeId ?? this.programmeId,
    academicLevelId: academicLevelId ?? this.academicLevelId,
  );

  /// The API wants a first and last name; the screen asks for one field.
  /// Everything after the first space is the surname, and someone with a
  /// single name gets it in both — the API rejects an empty one.
  (String first, String last) get _names {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return (fullName.trim(), fullName.trim());
    return (parts.first, parts.sublist(1).join(' '));
  }

  /// Null until every field register insists on has been answered.
  RegistrationRequest? toRequest() {
    final institutionId = institution?.id;
    final role = this.role;
    final (first, last) = _names;
    if (institutionId == null ||
        role == null ||
        email.isEmpty ||
        password.isEmpty ||
        first.isEmpty) {
      return null;
    }
    return RegistrationRequest(
      email: email,
      password: password,
      firstName: first,
      lastName: last,
      role: role,
      institutionId: institutionId,
      facultyId: facultyId,
      departmentId: departmentId,
      programmeId: programmeId,
      academicLevelId: academicLevelId,
    );
  }
}

class RegistrationDraftNotifier extends Notifier<RegistrationDraft> {
  @override
  RegistrationDraft build() => const RegistrationDraft();

  void setCredentials({required String email, required String password}) =>
      state = state.copyWith(email: email, password: password);

  void setInstitution(Institution institution) =>
      state = state.copyWith(institution: institution);

  void setRole(UserRole role) => state = state.copyWith(role: role);

  void setDetails({
    String? fullName,
    String? facultyId,
    String? departmentId,
    String? programmeId,
    String? academicLevelId,
  }) => state = state.copyWith(
    fullName: fullName,
    facultyId: facultyId,
    departmentId: departmentId,
    programmeId: programmeId,
    academicLevelId: academicLevelId,
  );

  /// After a completed sign-up, so a second one does not inherit the first.
  void clear() => state = const RegistrationDraft();
}

final registrationDraftProvider =
    NotifierProvider<RegistrationDraftNotifier, RegistrationDraft>(
      RegistrationDraftNotifier.new,
    );
