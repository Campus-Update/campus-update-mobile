import 'package:campus_update/app/app.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
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
  });
}
