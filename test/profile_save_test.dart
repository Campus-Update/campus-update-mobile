import 'dart:convert';
import 'dart:typed_data';

import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/profile/data/profile_providers.dart';
import 'package:campus_update/features/profile/data/profile_repository.dart';
import 'package:campus_update/features/profile/domain/user_profile.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request with the body it was sent, as the API echoes the
/// saved profile, and remembers each request.
class _EchoAdapter implements HttpClientAdapter {
  final requests =
      <({String method, String path, Map<String, dynamic> body})>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = Map<String, dynamic>.from(options.data as Map);
    requests.add((method: options.method, path: options.path, body: body));
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _signedIn = UserProfile(
  email: 'feed-probe@example.com',
  firstName: 'Feed',
  lastName: 'Probe',
  institutionId: 'osun',
  facultyId: 'f-comp',
  departmentId: 'd-cs',
  programmeId: 'p-bsc',
  academicLevelId: 'l-100',
  newsEnabled: true,
  announcementsEnabled: false,
  eventsEnabled: true,
  advertisementsEnabled: false,
  pushNotificationsEnabled: true,
  allCampusFeed: false,
);

Future<(ProviderContainer, _EchoAdapter)> _setUp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final adapter = _EchoAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      profileRepositoryProvider.overrideWithValue(ProfileRepository(dio)),
    ],
  );
  addTearDown(container.dispose);
  await container.read(userProfileProvider.notifier).setProfile(_signedIn);
  return (container, adapter);
}

void main() {
  test('Edit profile saves the name, then the academic choice', () async {
    final (container, adapter) = await _setUp();

    await container
        .read(userProfileProvider.notifier)
        .saveDetails(
          firstName: 'Ada',
          lastName: 'Obi',
          institution: const Institution(
            id: 'osun',
            name: 'Osun',
            slug: 'osun',
          ),
          faculty: const Faculty(id: 'f-sci', name: 'Faculty of Science'),
        );

    expect(adapter.requests.map((r) => r.path), [
      '/api/v1/auth/profile',
      '/api/v1/auth/academic-settings',
    ]);
    expect(adapter.requests.first.body['firstName'], 'Ada');
    expect(adapter.requests.last.body['facultyId'], 'f-sci');
    // A setting the user did not touch goes back as it was.
    expect(adapter.requests.last.body['announcementsEnabled'], false);

    final saved = container.read(userProfileProvider)!;
    expect(saved.fullName, 'Ada Obi');
    expect(saved.facultyName, 'Faculty of Science');
  });
}
