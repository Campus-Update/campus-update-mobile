import 'dart:async';

import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/features/auth/data/school_repository.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/auth/presentation/screens/select_school_screen.dart';
import 'package:campus_update/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final osun = Institution.fromJson({
  'id': 'osun',
  'name': 'Osun State University',
  'slug': 's',
  'faculties': [
    {'id': 'f', 'name': 'Computing', 'departments': <dynamic>[]},
  ],
});

final comingSoon = Institution.fromJson({
  'id': 'cu',
  'name': 'Campus Update',
  'slug': 'c',
  'faculties': <dynamic>[],
});

void main() {
  Future<void> boot(WidgetTester t, ProviderScope scope) async {
    final loader = FontLoader('Archivo')
      ..addFont(rootBundle.load('assets/fonts/Archivo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Archivo-Medium.ttf'));
    await t.runAsync(loader.load);
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(scope);
  }

  testWidgets('shows a loader while the call is in flight', (t) async {
    await boot(
      t,
      ProviderScope(
        overrides: [
          // A future that never settles: the point is what the screen shows
          // while waiting, and a timer would still be pending at teardown.
          schoolsProvider.overrideWith(
            (_) => Completer<List<Institution>>().future,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SelectSchoolScreen(),
        ),
      ),
    );
    await t.pump();
    expect(find.byType(Loader), findsOneWidget);
  });

  testWidgets('renders schools; coming-soon ones are not tappable', (t) async {
    await boot(
      t,
      ProviderScope(
        overrides: [
          schoolsProvider.overrideWith((_) async => [osun, comingSoon]),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SelectSchoolScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Osun State University'), findsOneWidget);
    expect(find.text('coming soon'), findsOneWidget);

    final rows = find.byType(OptionRow);
    expect(t.widget<OptionRow>(rows.at(0)).onTap, isNotNull);
    expect(t.widget<OptionRow>(rows.at(1)).onTap, isNull);
  });

  testWidgets('offers a retry when the call fails', (t) async {
    await boot(
      t,
      ProviderScope(
        overrides: [
          schoolsProvider.overrideWith((_) => throw Exception('boom')),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SelectSchoolScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
  });

  testWidgets('search filters the list', (t) async {
    await boot(
      t,
      ProviderScope(
        overrides: [
          schoolsProvider.overrideWith((_) async => [osun, comingSoon]),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SelectSchoolScreen(),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.enterText(find.byType(EditableText).first, 'osun');
    await t.pumpAndSettle();
    expect(find.text('Osun State University'), findsOneWidget);
    expect(find.text('Campus Update'), findsNothing);
  });
}
