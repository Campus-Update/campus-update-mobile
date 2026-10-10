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
    this.institutionName,
    this.facultyName,
    this.departmentName,
    this.programmeName,
    this.academicLevelName,
    this.avatarPath,
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
  final String? institutionName;
  final String? facultyName;
  final String? departmentName;
  final String? programmeName;
  final String? academicLevelName;
  final String? avatarPath;

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

  /// Monogram initials for the avatar when no photo has been selected.
  String get initials {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) return first[0].toUpperCase();
    if (last.isNotEmpty) return last[0].toUpperCase();
    final d = displayName;
    if (d.isNotEmpty) return d[0].toUpperCase();
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
    String? institutionName,
    String? facultyName,
    String? departmentName,
    String? programmeName,
    String? academicLevelName,
    String? avatarPath,
    bool clearAvatar = false,
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
      institutionName: institutionName ?? this.institutionName,
      facultyName: facultyName ?? this.facultyName,
      departmentName: departmentName ?? this.departmentName,
      programmeName: programmeName ?? this.programmeName,
      academicLevelName: academicLevelName ?? this.academicLevelName,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
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
    if (institutionName != null) 'institutionName': institutionName,
    if (facultyName != null) 'facultyName': facultyName,
    if (departmentName != null) 'departmentName': departmentName,
    if (programmeName != null) 'programmeName': programmeName,
    if (academicLevelName != null) 'academicLevelName': academicLevelName,
    if (avatarPath != null) 'avatarPath': avatarPath,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      // Two spellings reach this: the API sends 'Student' and 'SchoolAdmin',
      // while toJson writes the enum's own lowercase name for local storage.
      // Reading only one of them silently turned every staff member into a
      // student on the way back in.
      role: switch (json['role']) {
        final String r when r.isNotEmpty =>
          UserRole.values.where((e) => e.name == r).firstOrNull ??
              UserRole.fromApi(r),
        _ => UserRole.student,
      },
      matriculationOrStaffNumber: json['matriculationOrStaffNumber'] as String?,
      institutionId: json['institutionId'] as String?,
      facultyId: json['facultyId'] as String?,
      departmentId: json['departmentId'] as String?,
      programmeId: json['programmeId'] as String?,
      academicLevelId: json['academicLevelId'] as String?,
      institutionName: json['institutionName'] as String?,
      facultyName: json['facultyName'] as String?,
      departmentName: json['departmentName'] as String?,
      programmeName: json['programmeName'] as String?,
      academicLevelName: json['academicLevelName'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}

/// Default mock user profile data matching the design specification.
const defaultMockUserProfile = UserProfile(
  firstName: 'Jeremiah',
  lastName: 'Alalade',
  email: 'ajeremiahfig@gmail.com',
  institutionName: 'Lead City University',
  facultyName: 'Faculty of Computting Information Technology (FOCIT)',
  departmentName: 'Software Engineering',
  programmeName: 'Software Engineering',
  academicLevelName: 'Software Engineering',
);
