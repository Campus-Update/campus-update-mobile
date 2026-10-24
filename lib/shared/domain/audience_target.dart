/// A position in the audience hierarchy:
/// institution → faculty → department → programme → level.
///
/// Every content item is targeted through this, and a user's own placement is
/// what makes their feed personalised. Nulls widen the target: a null faculty
/// means the whole institution.
class AudienceTarget {
  const AudienceTarget({
    required this.institutionId,
    this.facultyId,
    this.departmentId,
    this.programmeId,
    this.academicLevelId,
  });

  final String institutionId;
  final String? facultyId;
  final String? departmentId;
  final String? programmeId;
  final String? academicLevelId;
}

/// `Student | Staff | SchoolAdmin | SuperAdmin`. Self-registration only ever
/// produces the first two.
enum UserRole {
  student,
  staff,
  schoolAdmin,
  superAdmin;

  static UserRole fromApi(String value) => switch (value) {
    'Staff' => UserRole.staff,
    'SchoolAdmin' => UserRole.schoolAdmin,
    'SuperAdmin' => UserRole.superAdmin,
    _ => UserRole.student,
  };
}
