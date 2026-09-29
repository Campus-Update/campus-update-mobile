// The rules on Create New Password are displayed live, and the button is the
// only way forward, so these check that the list is enforced rather than
// merely shown. It was not, once.
import 'package:campus_update/app/router.dart';
import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/features/auth/presentation/screens/password_reset_success_screen.dart';
import 'package:campus_update/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> boot(WidgetTester t) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  final r = GoRouter(
    initialLocation: Routes.resetPassword,
    routes: [
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: Routes.passwordResetSuccess,
        builder: (_, __) => const PasswordResetSuccessScreen(),
      ),
    ],
  );
  await t.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: r),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> type(WidgetTester t, String a, String b) async {
  final f = find.byType(EditableText);
  await t.enterText(f.at(0), a);
  await t.enterText(f.at(1), b);
  await t.pumpAndSettle();
}

void main() {
  testWidgets('empty fields cannot submit', (t) async {
    await boot(t);
    await t.tap(find.text('Reset Password'));
    await t.pumpAndSettle();
    expect(find.byType(PasswordResetSuccessScreen), findsNothing);
  });

  testWidgets('weak password cannot submit', (t) async {
    await boot(t);
    await type(t, 'password', 'password'); // no upper, digit or symbol
    await t.tap(find.text('Reset Password'));
    await t.pumpAndSettle();
    expect(find.byType(PasswordResetSuccessScreen), findsNothing);
  });

  testWidgets('mismatched confirmation cannot submit', (t) async {
    await boot(t);
    await type(t, 'Passw0rd!', 'Passw0rd?');
    await t.tap(find.text('Reset Password'));
    await t.pumpAndSettle();
    expect(find.byType(PasswordResetSuccessScreen), findsNothing);
  });

  testWidgets('a password meeting every rule does submit', (t) async {
    await boot(t);
    await type(t, 'Passw0rd!', 'Passw0rd!');
    await t.tap(find.text('Reset Password'));
    await t.pumpAndSettle();
    expect(find.byType(PasswordResetSuccessScreen), findsOneWidget);
  });
}
