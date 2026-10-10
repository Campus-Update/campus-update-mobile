import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_repository.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/network/api_exception.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/home/presentation/screens/home_screen.dart';
import 'package:campus_update/features/profile/data/profile_repository.dart';
import 'package:campus_update/features/profile/domain/user_profile.dart';
import 'package:campus_update/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for the real repository so a test that drives the login screen
/// does not reach the deployed API. Without it these tests make a live network
/// call, which is slow, flaky, and fails against a server that has never heard
/// of the credentials they type.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async => AuthSession(
    userId: 'test-user',
    accessToken: 'access',
    refreshToken: 'refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );

  @override
  Future<AuthSession> register(RegistrationRequest request) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

/// Stands in for GET /auth/profile.
///
/// Default is to fail, which is the case the greeting has to survive: the
/// sign-in still goes through and the name falls back to the email. Pass a
/// [profile] for the case where the API does say who the user is.
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository([this.profile]);

  final UserProfile? profile;

  @override
  Future<UserProfile> fetch() async {
    final p = profile;
    if (p == null) {
      throw const ApiException(statusCode: 500, message: 'no profile');
    }
    return p;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    // Treat onboarding as already seen, so the router's signed-out target is
    // login rather than the first-run screen.
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('starts on the splash screen while the session is unknown', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('a signed-out session lands on login', (tester) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedOut();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signing in with valid credentials navigates to the home page', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedOut();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Enter email and password
    await tester.enterText(
      find.byType(EditableText).at(0),
      'jeremiah@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
    await tester.pumpAndSettle();

    // Tap Sign in
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    // Navigated to Home Screen
    expect(find.text('Welcome, Jeremiah!'), findsOneWidget);
    expect(
      find.text('Complete your profile to sharpen your feed'),
      findsOneWidget,
    );
  });

  testWidgets('a signed-in session lands on home with the tab bar', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    // Home is the landing tab; its title and its tab label both render.
    expect(find.text('Home'), findsWidgets);
    expect(find.text('News'), findsOneWidget); // the tab label only
  });

  testWidgets(
    'home screen allows backward navigation from notifications and detail screens',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(authProvider.notifier)
          .signedIn(email: 'jeremiah@example.com');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CampusUpdateApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Home Screen elements
      expect(find.text('Welcome, Jeremiah!'), findsOneWidget);
      expect(
        find.text('Complete your profile to sharpen your feed'),
        findsOneWidget,
      );

      // Tap Notifications icon on Home screen
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsWidgets);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Returned to Home
      expect(find.text('Welcome, Jeremiah!'), findsOneWidget);
    },
  );

  testWidgets('forgot password flow navigates to OTP verification with email', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedOut();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Forgot Password link on login screen
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Send verification code'), findsOneWidget);

    // Enter valid email and submit
    await tester.enterText(find.byType(EditableText), 'user@example.com');
    await tester.tap(find.text('Send verification code'));
    await tester.pumpAndSettle();

    // Verify it navigated to OTP screen with email
    expect(find.text('Check Your Email'), findsOneWidget);
    expect(
      find.text("We've sent a 6-digit verification code to user@example.com"),
      findsOneWidget,
    );

    // Enter 6 digit OTP to navigate to Create New Password
    await tester.enterText(find.byType(EditableText).first, '123456');
    await tester.pumpAndSettle();

    expect(find.text('Create New Password'), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);

    // Enter valid new password matching all criteria
    await tester.enterText(find.byType(EditableText).at(0), 'Password123!');
    await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
    // The button is disabled until every rule passes, so let the rebuild
    // settle before tapping it.
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Reset Password'));
    await tester.tap(find.text('Reset Password'));
    await tester.pumpAndSettle();

    // Verify it navigated to Password Reset success screen
    expect(find.text('Password Reset!'), findsOneWidget);
    expect(find.text('Back to Sign In'), findsOneWidget);

    // Tap Back to Sign In and verify return to Login
    await tester.tap(find.text('Back to Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets(
    'home screen without pending profile hides profile card and renders feed directly',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedIn();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(hasPendingProfile: false, userName: 'Jeremiah'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Profile completion card must NOT be present
      expect(
        find.text('Complete your profile to sharpen your feed'),
        findsNothing,
      );

      // Header, Breaking news, Latest news, and Upcoming events must be visible
      expect(find.text('Welcome, Jeremiah!'), findsOneWidget);
      expect(find.text('LIVE UPDATES'), findsOneWidget);
      expect(find.text('Latest News'), findsOneWidget);
      expect(
        find.text(
          'FOCIT introduces machine learning elective for 400 level students',
        ),
        findsOneWidget,
      );
      expect(find.text('Upcoming Events'), findsOneWidget);
      expect(
        find.text('Matriculation ceremony for the 2025/2026 session'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping Not now on profile completion card dismisses it from home screen',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedIn();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Card is initially visible
      expect(
        find.text('Complete your profile to sharpen your feed'),
        findsOneWidget,
      );

      // Tap 'Not now'
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      // Card is dismissed
      expect(
        find.text('Complete your profile to sharpen your feed'),
        findsNothing,
      );
      expect(find.text('LIVE UPDATES'), findsOneWidget);
    },
  );

  testWidgets(
    'displays dynamic greeting for different signed-in users rather than hardcoding',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedOut();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CampusUpdateApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Sign in as Emmanuel
      await tester.enterText(
        find.byType(EditableText).at(0),
        'emmanuel@campus.edu',
      );
      await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Home Screen greets Emmanuel, NOT Jeremiah
      expect(find.text('Welcome, Emmanuel!'), findsOneWidget);
      expect(find.text('Welcome, Jeremiah!'), findsNothing);
    },
  );

  testWidgets(
    'editing profile name updates greeting on home screen and marks profile complete',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
        ],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedIn(email: 'user@example.com');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CampusUpdateApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially greeted with email-derived name
      expect(find.text('Welcome, User!'), findsOneWidget);

      // Tap 'Add details' button on profile card
      await tester.tap(find.text('Add details'));
      await tester.pumpAndSettle();

      // Now on Edit details screen
      expect(find.text('Edit details'), findsOneWidget);

      // Enter Full Name as 'Amara Okafor'
      await tester.enterText(find.byType(EditableText).first, 'Amara Okafor');
      await tester.pumpAndSettle();

      // Tap 'Save changes'
      await tester.ensureVisible(find.text('Save changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Returned to Home Screen, greeted with new name
      expect(find.text('Welcome, Amara!'), findsOneWidget);
      // Profile completion card should now be marked complete
      expect(
        find.text('Complete your profile to sharpen your feed'),
        findsNothing,
      );
    },
  );

  Widget homeUnder(ProviderContainer container) => UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: HomeScreen(hasPendingProfile: false, userName: 'Jeremiah'),
    ),
  );

  Finder categoryTab(String label) =>
      find.byKey(ValueKey('category-tab-$label'));

  testWidgets('the name from GET /auth/profile wins over the email', (
    tester,
  ) async {
    // The case this whole call exists for: signing in on a device the user
    // never registered on. Nothing is stored locally, so without the profile
    // fetch the greeting falls back to the front of the email address.
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(
          _FakeProfileRepository(
            const UserProfile(
              id: 'u1',
              email: 'daanny214@example.com',
              firstName: 'Daniel',
              lastName: 'Isiyemi',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedOut();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(EditableText).at(0),
      'daanny214@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'Password123!');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Daniel!'), findsOneWidget);
    expect(find.text('Welcome, Daanny214!'), findsNothing);
  });

  testWidgets('home screen shows the six category tabs from the design', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(homeUnder(container));
    await tester.pumpAndSettle();

    for (final label in [
      'All',
      'For You',
      'General',
      'Campus',
      'Technology',
      'Health',
    ]) {
      expect(categoryTab(label), findsOneWidget, reason: 'missing tab: $label');
    }
  });

  testWidgets('tapping a category tab moves the underline to it', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(homeUnder(container));
    await tester.pumpAndSettle();

    // Reads the bottom border of the box wrapping a given tab.
    BorderSide underlineOf(String label) {
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: categoryTab(label),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return (box.decoration as BoxDecoration).border!.bottom;
    }

    // The design underlines 'For You' at rest.
    expect(underlineOf('For You').color, isNot(Colors.transparent));
    expect(underlineOf('Campus').color, Colors.transparent);

    await tester.tap(categoryTab('Campus'));
    await tester.pumpAndSettle();

    expect(underlineOf('Campus').color, isNot(Colors.transparent));
    expect(underlineOf('For You').color, Colors.transparent);
  });

  testWidgets('the feed lists are built from the shared ContentCard', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(homeUnder(container));
    await tester.pumpAndSettle();

    // Three news items and two events, all through the one component rather
    // than hand-rolled rows.
    expect(find.byType(ContentCard), findsNWidgets(5));
    expect(find.byType(ContentCardAction), findsNWidgets(3));
    expect(find.byType(ContentCardMeta), findsNWidgets(2));

    // Both section headings come from the shared widget too.
    expect(find.byType(SectionHeader), findsNWidgets(2));
    expect(find.text('See all'), findsNWidgets(2));
  });

  testWidgets('the breaking hero swipes and drops the hint on the last card', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.read(authProvider.notifier).signedIn();

    await tester.pumpWidget(homeUnder(container));
    await tester.pumpAndSettle();

    expect(find.text('LIVE UPDATES'), findsOneWidget);
    expect(find.text('Swipe'), findsOneWidget);

    final hero = find.byType(PageView);
    expect(hero, findsOneWidget);

    // Second card: still swipeable, so the hint stays.
    await tester.fling(hero, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(
      find.text('Senate Approves Revised Academic Calendar for 2025/2026'),
      findsOneWidget,
    );
    expect(find.text('Swipe'), findsOneWidget);

    // Third and last card: nothing left to swipe to.
    await tester.fling(hero, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(
      find.text('Campus Clinic Extends Opening Hours Through Exam Week'),
      findsOneWidget,
    );
    expect(find.text('Swipe'), findsNothing);
  });
}
