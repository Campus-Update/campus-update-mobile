import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/home/presentation/screens/home_screen.dart';
import 'package:campus_update/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const CampusUpdateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('a signed-out session lands on login', (tester) async {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
    await tester.enterText(find.byType(EditableText).at(0), 'user@example.com');
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
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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

      // Verify Home Screen elements
      expect(find.text('Welcome, Jeremiah!'), findsOneWidget);
      expect(find.text('Complete your profile to sharpen your feed'), findsOneWidget);

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
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedIn();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(hasPendingProfile: false),
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
      expect(find.text('Breaking'), findsOneWidget);
      expect(find.text('Latest News'), findsOneWidget);
      expect(
        find.text('FOCIT introduces machine learning elective for 400 level students'),
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
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      container.read(authProvider.notifier).signedIn();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
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
      expect(find.text('Breaking'), findsOneWidget);
    },
  );
}

