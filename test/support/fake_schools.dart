import 'package:campus_update/features/auth/data/school_repository.dart';
import 'package:campus_update/features/auth/domain/institution.dart';

/// Stands in for `GET /schools`, so screens that name the user's school
/// render without a network.
final fakeSchoolsOverride = schoolsProvider.overrideWith(
  (ref) async => const <Institution>[],
);
