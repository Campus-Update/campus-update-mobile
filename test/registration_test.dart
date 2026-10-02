// Registration is one call made from the last of four screens, so these cover
// the draft that carries the answers and what the final screen does with them.
import 'package:campus_update/core/auth/auth_repository.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/auth/domain/registration_draft.dart';
import 'package:flutter_test/flutter_test.dart';

final osun = Institution.fromJson({
  'id': 'inst-1',
  'name': 'Osun State University',
  'slug': 's',
  'faculties': <dynamic>[],
});

void main() {
  test('an incomplete draft produces no request', () {
    expect(const RegistrationDraft().toRequest(), isNull);

    // Everything but the institution.
    const partial = RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: 'Ada Lovelace',
      role: UserRole.student,
    );
    expect(partial.toRequest(), isNull);
  });

  test('a complete draft produces the payload register expects', () {
    final draft = const RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: 'Ada Lovelace',
      role: UserRole.student,
      facultyId: 'f1',
      departmentId: 'd1',
      programmeId: 'p1',
      academicLevelId: 'l1',
    ).copyWith(institution: osun);

    final json = draft.toRequest()!.toJson();
    expect(json['email'], 'a@b.com');
    expect(json['firstName'], 'Ada');
    expect(json['lastName'], 'Lovelace');
    expect(json['institutionId'], 'inst-1');
    expect(json['facultyId'], 'f1');
    // The spec types this an integer; the API reads a string.
    expect(json['role'], 'Student');
  });

  test('staff send their own role', () {
    final draft = const RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: 'Grace Hopper',
      role: UserRole.staff,
    ).copyWith(institution: osun);
    expect(draft.toRequest()!.toJson()['role'], 'Staff');
  });

  test('a single name fills both halves, since neither may be empty', () {
    final draft = const RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: 'Prince',
      role: UserRole.student,
    ).copyWith(institution: osun);
    final json = draft.toRequest()!.toJson();
    expect(json['firstName'], 'Prince');
    expect(json['lastName'], 'Prince');
  });

  test('a three-part name keeps everything after the first as the surname', () {
    final draft = const RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: '  Ada  King Lovelace ',
      role: UserRole.student,
    ).copyWith(institution: osun);
    final json = draft.toRequest()!.toJson();
    expect(json['firstName'], 'Ada');
    expect(json['lastName'], 'King Lovelace');
  });

  test('the optional ids stay null when nothing was picked', () {
    final draft = const RegistrationDraft(
      email: 'a@b.com',
      password: 'Passw0rd!',
      fullName: 'Ada Lovelace',
      role: UserRole.student,
    ).copyWith(institution: osun);
    final json = draft.toRequest()!.toJson();
    for (final k in [
      'facultyId',
      'departmentId',
      'programmeId',
      'academicLevelId',
    ]) {
      expect(json[k], isNull, reason: '$k must be nullable, not empty');
    }
  });
}
