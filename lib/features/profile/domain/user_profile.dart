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
    this.newsEnabled,
    this.announcementsEnabled,
    this.eventsEnabled,
    this.advertisementsEnabled,
    this.pushNotificationsEnabled,
    this.allCampusFeed,
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

  // The feed settings `PUT /auth/academic-settings` takes alongside the
  // academic IDs. That endpoint replaces the whole set at once, so the app
  // keeps all of them to send back. Null when the profile came from an older
  // build that did not store them.
  final bool? newsEnabled;
  final bool? announcementsEnabled;
  final bool? eventsEnabled;
  final bool? advertisementsEnabled;
  final bool? pushNotificationsEnabled;

  /// Everything from the school rather than only the user's faculty,
  /// department and level — the Preferences screen's "All campus".
  final bool? allCampusFeed;

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
    bool? newsEnabled,
    bool? announcementsEnabled,
    bool? eventsEnabled,
    bool? advertisementsEnabled,
    bool? pushNotificationsEnabled,
    bool? allCampusFeed,
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
      newsEnabled: newsEnabled ?? this.newsEnabled,
      announcementsEnabled: announcementsEnabled ?? this.announcementsEnabled,
      eventsEnabled: eventsEnabled ?? this.eventsEnabled,
      advertisementsEnabled:
          advertisementsEnabled ?? this.advertisementsEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      allCampusFeed: allCampusFeed ?? this.allCampusFeed,
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
    if (newsEnabled != null) 'newsEnabled': newsEnabled,
    if (announcementsEnabled != null)
      'announcementsEnabled': announcementsEnabled,
    if (eventsEnabled != null) 'eventsEnabled': eventsEnabled,
    if (advertisementsEnabled != null)
      'advertisementsEnabled': advertisementsEnabled,
    if (pushNotificationsEnabled != null)
      'pushNotificationsEnabled': pushNotificationsEnabled,
    if (allCampusFeed != null) 'allCampusFeed': allCampusFeed,
  };

  /// The body for `PUT /auth/academic-settings`: every academic ID and every
  /// feed setting, since the endpoint replaces them all. A setting the app
  /// has never seen goes as the API's own default, on.
  Map<String, dynamic> toAcademicSettingsJson() => {
    'institutionId': institutionId,
    'facultyId': facultyId,
    'departmentId': departmentId,
    'programmeId': programmeId,
    'academicLevelId': academicLevelId,
    'newsEnabled': newsEnabled ?? true,
    'announcementsEnabled': announcementsEnabled ?? true,
    'eventsEnabled': eventsEnabled ?? true,
    'advertisementsEnabled': advertisementsEnabled ?? true,
    'pushNotificationsEnabled': pushNotificationsEnabled ?? true,
    'allCampusFeed': allCampusFeed ?? false,
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
      newsEnabled: json['newsEnabled'] as bool?,
      announcementsEnabled: json['announcementsEnabled'] as bool?,
      eventsEnabled: json['eventsEnabled'] as bool?,
      advertisementsEnabled: json['advertisementsEnabled'] as bool?,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] as bool?,
      allCampusFeed: json['allCampusFeed'] as bool?,
    );
  }

  /// This profile updated with [server]'s answer. A field the answer leaves
  /// out keeps its value here rather than being cleared, and so does what
  /// only this phone knows: the names looked up for the IDs and the photo.
  UserProfile mergedWith(UserProfile server) => copyWith(
    id: server.id,
    email: server.email,
    firstName: server.firstName,
    lastName: server.lastName,
    role: server.role,
    matriculationOrStaffNumber: server.matriculationOrStaffNumber,
    institutionId: server.institutionId,
    facultyId: server.facultyId,
    departmentId: server.departmentId,
    programmeId: server.programmeId,
    academicLevelId: server.academicLevelId,
    newsEnabled: server.newsEnabled,
    announcementsEnabled: server.announcementsEnabled,
    eventsEnabled: server.eventsEnabled,
    advertisementsEnabled: server.advertisementsEnabled,
    pushNotificationsEnabled: server.pushNotificationsEnabled,
    allCampusFeed: server.allCampusFeed,
  );
}
