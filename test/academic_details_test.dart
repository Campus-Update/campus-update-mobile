import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/auth/domain/registration_draft.dart';
import 'package:campus_update/features/auth/presentation/screens/academic_details_screen.dart';
import 'package:campus_update/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final osun = Institution.fromJson({
  'id': 'inst',
  'name': 'Osun State University',
  'slug': 's',
  'faculties': [
    {
      'id': 'f1',
      'name': 'Faculty of Computing',
      'departments': [
        {
          'id': 'd1',
          'name': 'Computer Science',
          'programmes': [
            {
              'id': 'p1',
              'name': 'B.Sc. Computer Science',
              'levels': [
                {'id': 'l1', 'name': '100L', 'sortOrder': 100},
                {'id': 'l2', 'name': '200L', 'sortOrder': 200},
              ],
            },
          ],
        },
      ],
    },
  ],
});

void main() {
  Future<void> boot(WidgetTester t, {bool student = true}) async {
    final loader = FontLoader('Archivo')
      ..addFont(rootBundle.load('assets/fonts/Archivo-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Archivo-Medium.ttf'));
    await t.runAsync(loader.load);
    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(registrationDraftProvider.notifier).setInstitution(osun);

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: AcademicDetailsScreen(isStudent: student),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('faculty offers what the chosen school has', (t) async {
    await boot(t);
    final faculty = find.byType(AppSelect<Faculty>);
    expect(faculty, findsOneWidget);
    expect(t.widget<AppSelect<Faculty>>(faculty).options, hasLength(1));

    await t.tap(faculty);
    await t.pumpAndSettle();
    expect(find.text('Faculty of Computing').hitTestable(), findsWidgets);
  });

  testWidgets('department stays empty until a faculty is chosen', (t) async {
    await boot(t);
    expect(
      t
          .widget<AppSelect<Department>>(find.byType(AppSelect<Department>))
          .options,
      isEmpty,
    );

    await t.tap(find.byType(AppSelect<Faculty>));
    await t.pumpAndSettle();
    await t.tap(find.text('Faculty of Computing').last);
    await t.pumpAndSettle();

    expect(
      t
          .widget<AppSelect<Department>>(find.byType(AppSelect<Department>))
          .options,
      hasLength(1),
    );
  });

  testWidgets('choosing a faculty again clears what was below it', (t) async {
    await boot(t);
    // Pick all the way down.
    await t.tap(find.byType(AppSelect<Faculty>));
    await t.pumpAndSettle();
    await t.tap(find.text('Faculty of Computing').last);
    await t.pumpAndSettle();
    await t.tap(find.byType(AppSelect<Department>));
    await t.pumpAndSettle();
    await t.tap(find.text('Computer Science').last);
    await t.pumpAndSettle();
    expect(
      t.widget<AppSelect<Department>>(find.byType(AppSelect<Department>)).value,
      isNotNull,
    );

    // Choosing the faculty again must not leave that department behind it.
    await t.tap(find.byType(AppSelect<Faculty>));
    await t.pumpAndSettle();
    await t.tap(find.text('Faculty of Computing').last);
    await t.pumpAndSettle();
    expect(
      t.widget<AppSelect<Department>>(find.byType(AppSelect<Department>)).value,
      isNull,
      reason: 'a stale department would be sent against the new faculty',
    );
  });

  testWidgets('staff are not asked for programme or level', (t) async {
    await boot(t, student: false);
    expect(find.byType(AppSelect<Faculty>), findsOneWidget);
    expect(find.byType(AppSelect<Department>), findsOneWidget);
    expect(find.byType(AppSelect<Programme>), findsNothing);
    expect(find.byType(AppSelect<AcademicLevel>), findsNothing);
  });
}
