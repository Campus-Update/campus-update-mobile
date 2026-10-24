import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the real schools response shape', () {
    final json = <String, dynamic>{
      'id': 'd94d9c5c-69df-4bf2-9132-1f4eb39e9125',
      'name': 'Osun State University',
      'slug': 'osun-state-university',
      'acronym': null,
      'logoUrl': null,
      'faculties': [
        {
          'id': 'f1',
          'name': 'Faculty of Computing',
          'code': 'FCOM',
          'departments': [
            {
              'id': 'd1',
              'name': 'Computer Science',
              'code': 'CSC',
              'programmes': [
                {
                  'id': 'p1',
                  'name': 'B.Sc. Computer Science',
                  'code': 'BSC-CS',
                  'levels': [
                    {'id': 'l2', 'name': '200L', 'sortOrder': 200},
                    {'id': 'l1', 'name': '100L', 'sortOrder': 100},
                  ],
                },
              ],
            },
          ],
        },
      ],
    };

    final i = Institution.fromJson(json);
    expect(i.name, 'Osun State University');
    expect(i.isAvailable, isTrue);
    expect(
      i.faculties.single.departments.single.programmes.single.name,
      'B.Sc. Computer Science',
    );
    // Levels arrive unordered from the API and must read 100L before 200L.
    expect(
      i.faculties.single.departments.single.programmes.single.levels.map(
        (l) => l.name,
      ),
      ['100L', '200L'],
    );
  });

  test('an institution with no faculties reads as coming soon', () {
    final i = Institution.fromJson({
      'id': 'x',
      'name': 'Campus Update',
      'slug': 'campus-update',
      'faculties': <dynamic>[],
    });
    expect(i.isAvailable, isFalse);
    expect(i.subtitle, 'coming soon');
  });

  test('missing and null fields do not throw', () {
    final i = Institution.fromJson({'id': 'x', 'name': 'Y'});
    expect(i.slug, '');
    expect(i.faculties, isEmpty);
  });
}
