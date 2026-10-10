import 'package:campus_update/app/router.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/storage/prefs_storage.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/auth/data/school_repository.dart';
import 'package:campus_update/features/auth/domain/default_institution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('router can navigate to /profile/settings', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = PrefsStorage(prefs);

    final container = ProviderContainer(
      overrides: [
        prefsStorageProvider.overrideWithValue(storage),
        schoolsProvider.overrideWith(
          (ref) => Future.value([defaultLeadCityUniversity]),
        ),
      ],
    );

    // Set signed in
    container.read(authProvider.notifier).state = AuthStatus.signedIn;

    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Now push /profile/settings
    router.push(Routes.settings);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Authentication & Login'), findsOneWidget);
  });
}
