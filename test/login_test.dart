// Signing in is the first call that produces a session, so these cover what
// the screen does when it succeeds and when it is refused.
import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/core/auth/auth_repository.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/network/api_exception.dart';
import 'package:campus_update/features/auth/presentation/screens/login_screen.dart';
import 'package:campus_update/features/profile/data/profile_repository.dart';
import 'package:campus_update/features/profile/domain/user_profile.dart';
import 'package:campus_update/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.failWith});

  final ApiException? failWith;
  int calls = 0;
  String? sawEmail;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    calls++;
    sawEmail = email;
    if (failWith != null) throw failWith!;
    return AuthSession(
      userId: 'u1',
      accessToken: 'a',
      refreshToken: 'r',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthSession> register(RegistrationRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

/// Signing in now also reads GET /auth/profile, so the screen needs one of
/// these or it reaches the live API.
class _FakeProfileRepo implements ProfileRepository {
  _FakeProfileRepo([this.profile]);

  final UserProfile? profile;
  int calls = 0;

  @override
  Future<UserProfile> fetch() async {
    calls++;
    final p = profile;
    if (p == null) {
      throw const ApiException(statusCode: 500, message: 'no profile');
    }
    return p;
  }
}

Future<ProviderContainer> boot(
  WidgetTester t,
  AuthRepository repo, {
  ProfileRepository? profileRepo,
}) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      profileRepositoryProvider.overrideWithValue(
        profileRepo ?? _FakeProfileRepo(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
    ),
  );
  await t.pumpAndSettle();
  return container;
}

Future<void> fillIn(WidgetTester t) async {
  final f = find.byType(EditableText);
  await t.enterText(f.at(0), 'user@example.com');
  await t.enterText(f.at(1), 'Passw0rd!');
  await t.pumpAndSettle();
}

void main() {
  testWidgets('a bad email never reaches the network', (t) async {
    final repo = _FakeRepo();
    await boot(t, repo);
    await t.enterText(find.byType(EditableText).at(0), 'not-an-email');
    await t.enterText(find.byType(EditableText).at(1), 'Passw0rd!');
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();
    expect(repo.calls, 0);
  });

  testWidgets('a good form signs in and flips the session', (t) async {
    final repo = _FakeRepo();
    final container = await boot(t, repo);
    expect(container.read(authProvider), isNot(AuthStatus.signedIn));

    await fillIn(t);
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();

    expect(repo.calls, 1);
    expect(repo.sawEmail, 'user@example.com');
    expect(container.read(authProvider), AuthStatus.signedIn);
  });

  testWidgets('signing in reads the profile, and a failure does not block it', (
    t,
  ) async {
    final profileRepo = _FakeProfileRepo(
      const UserProfile(id: 'u1', firstName: 'Daniel', lastName: 'Isiyemi'),
    );
    final container = await boot(t, _FakeRepo(), profileRepo: profileRepo);

    await fillIn(t);
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();

    expect(profileRepo.calls, 1, reason: 'login must fetch who signed in');
    expect(container.read(authProvider), AuthStatus.signedIn);

    // The credentials were accepted and the tokens are stored, so a profile
    // that cannot be read must not strand the user on the login screen.
    final failing = await boot(t, _FakeRepo());
    await fillIn(t);
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();
    expect(failing.read(authProvider), AuthStatus.signedIn);
  });

  testWidgets('wrong credentials explain themselves', (t) async {
    final repo = _FakeRepo(
      failWith: const ApiException(statusCode: 401, message: 'Unauthorized'),
    );
    final container = await boot(t, repo);
    await fillIn(t);
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();

    expect(find.text('That email and password do not match.'), findsOneWidget);
    expect(container.read(authProvider), isNot(AuthStatus.signedIn));
  });

  testWidgets('a network failure shows its own message', (t) async {
    final repo = _FakeRepo(
      failWith: const ApiException(
        statusCode: null,
        message: 'No connection. Check your network and try again.',
        isNetworkError: true,
      ),
    );
    await boot(t, repo);
    await fillIn(t);
    await t.tap(find.widgetWithText(AppButton, 'Sign in'));
    await t.pumpAndSettle();
    expect(find.textContaining('No connection'), findsOneWidget);
  });
}
