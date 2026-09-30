import '../../../../shared/domain/audience_target.dart';

/// User profile model representing the authenticated user.
class UserProfile {
  const UserProfile({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.role = UserRole.student,
    this.matriculationOrStaffNumber,
    this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programmeId,
    this.academicLevelId,
  });

  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final UserRole? role;
  final String? matriculationOrStaffNumber;
  final String? institutionId;
  final String? facultyId;
  final String? departmentId;
  final String? programmeId;
  final String? academicLevelId;

  /// Friendly display name for greetings and headers.
  ///
  /// Falls back in order:
  /// 1. [firstName] (trimmed)
  /// 2. [lastName] (trimmed)
  /// 3. Capitalised local part of [email] (e.g. "jeremiah.doe@uni.edu" -> "Jeremiah")
  /// 4. Empty string if no name or email is available.
  String get displayName {
    final first = firstName?.trim() ?? '';
    if (first.isNotEmpty) return first;

    final last = lastName?.trim() ?? '';
    if (last.isNotEmpty) return last;

    final em = email?.trim() ?? '';
    if (em.isNotEmpty) {
      final local = em.split('@').first;
      final part = local.split('.').first.split('_').first.split('-').first;
      if (part.isNotEmpty) {
        return part[0].toUpperCase() + part.substring(1);
      }
    }

    return '';
  }

  /// Full name (First + Last) or display name fallback.
  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) return '$first $last';
    if (first.isNotEmpty) return first;
    if (last.isNotEmpty) return last;
    return displayName;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? matriculationOrStaffNumber,
    String? institutionId,
    String? facultyId,
    String? departmentId,
    String? programmeId,
    String? academicLevelId,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      matriculationOrStaffNumber:
          matriculationOrStaffNumber ?? this.matriculationOrStaffNumber,
      institutionId: institutionId ?? this.institutionId,
      facultyId: facultyId ?? this.facultyId,
      departmentId: departmentId ?? this.departmentId,
      programmeId: programmeId ?? this.programmeId,
      academicLevelId: academicLevelId ?? this.academicLevelId,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (email != null) 'email': email,
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (role != null) 'role': role!.name,
    if (matriculationOrStaffNumber != null)
      'matriculationOrStaffNumber': matriculationOrStaffNumber,
    if (institutionId != null) 'institutionId': institutionId,
    if (facultyId != null) 'facultyId': facultyId,
    if (departmentId != null) 'departmentId': departmentId,
    if (programmeId != null) 'programmeId': programmeId,
    if (academicLevelId != null) 'academicLevelId': academicLevelId,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      role: json['role'] != null
          ? UserRole.values.where((e) => e.name == json['role']).firstOrNull ??
                UserRole.student
          : UserRole.student,
      matriculationOrStaffNumber: json['matriculationOrStaffNumber'] as String?,
      institutionId: json['institutionId'] as String?,
      facultyId: json['facultyId'] as String?,
      departmentId: json['departmentId'] as String?,
      programmeId: json['programmeId'] as String?,
      academicLevelId: json['academicLevelId'] as String?,
    );
  }
}
