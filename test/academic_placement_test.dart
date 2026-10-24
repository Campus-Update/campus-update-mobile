import 'package:campus_update/features/auth/data/school_repository.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/profile/data/profile_providers.dart';
import 'package:campus_update/features/profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedIn extends UserProfileNotifier {
  _SignedIn(this.profile);

  final UserProfile? profile;

  @override
  UserProfile? build() => profile;
}

const _schools = [
  Institution(
    id: 'other',
    name: 'Another University',
    slug: 'another',
    faculties: [Faculty(id: 'f-other', name: 'Faculty of Law')],
  ),
  Institution(
    id: 'osun',
    name: 'Osun State University',
    slug: 'osun',
    faculties: [
      Faculty(
        id: 'f-comp',
        name: 'Faculty of Computing',
        departments: [
          Department(
            id: 'd-cs',
            name: 'Computer Science',
            programmes: [
              Programme(
                id: 'p-bsc',
                name: 'B.Sc. Computer Science',
                levels: [
                  AcademicLevel(id: 'l-100', name: '100 Level', sortOrder: 100),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];

ProviderContainer _container(UserProfile? profile) {
  final container = ProviderContainer(
    overrides: [
      userProfileProvider.overrideWith(() => _SignedIn(profile)),
      schoolsProvider.overrideWith((ref) async => _schools),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test("names come from the user's own school, not the first one", () async {
    final container = _container(
      const UserProfile(
        institutionId: 'osun',
        facultyId: 'f-comp',
        departmentId: 'd-cs',
        programmeId: 'p-bsc',
        academicLevelId: 'l-100',
      ),
    );
    await container.read(schoolsProvider.future);

    final placement = container.read(academicPlacementProvider);
    expect(placement.institution, 'Osun State University');
    expect(placement.faculty, 'Faculty of Computing');
    expect(placement.department, 'Computer Science');
    expect(placement.programme, 'B.Sc. Computer Science');
    expect(placement.level, '100 Level');
  });

  test('a user with only a school chosen gets no faculty', () async {
    final container = _container(const UserProfile(institutionId: 'osun'));
    await container.read(schoolsProvider.future);

    final placement = container.read(academicPlacementProvider);
    expect(placement.institution, 'Osun State University');
    expect(placement.faculty, isNull);
  });

  test('signed out, there is nothing to show', () async {
    final container = _container(null);
    await container.read(schoolsProvider.future);

    expect(container.read(academicPlacementProvider).institution, isNull);
  });
}
