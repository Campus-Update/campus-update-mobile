import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/core/auth/auth_repository.dart';
import 'package:campus_update/core/auth/auth_state.dart';
import 'package:campus_update/core/network/api_exception.dart';
import 'package:campus_update/features/auth/domain/institution.dart';
import 'package:campus_update/features/profile/data/profile_providers.dart';
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

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.failWith});

  final ApiException? failWith;
  RegistrationRequest? sent;

  @override
  Future<AuthSession> register(RegistrationRequest request) async {
    sent = request;
    if (failWith != null) throw failWith!;
    return AuthSession(
      userId: 'u1',
      accessToken: 'a',
      refreshToken: 'r',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

Future<void> choose(WidgetTester t, Finder select, String option) async {
  await t.tap(select);
  await t.pumpAndSettle();
  await t.tap(find.text(option).last);
  await t.pumpAndSettle();
}

AppButton buttonOf(WidgetTester t) =>
    t.widget<AppButton>(find.widgetWithText(AppButton, 'Continue'));

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

  testWidgets('tapping a select opens a sheet from the bottom', (t) async {
    await boot(t);
    expect(find.byType(BottomSheet), findsNothing);

    await t.tap(find.byType(AppSelect<Faculty>));
    await t.pumpAndSettle();

    expect(
      find.byType(BottomSheet),
      findsOneWidget,
      reason: 'a phone picks from a sheet, not a menu pinned to the field',
    );
    // The sheet is titled by the field it belongs to, and lists the options.
    expect(find.text('Faculty of Computing'), findsOneWidget);
  });

  testWidgets('choosing from the sheet sets the field and closes it', (
    t,
  ) async {
    await boot(t);
    await t.tap(find.byType(AppSelect<Faculty>));
    await t.pumpAndSettle();
    await t.tap(find.text('Faculty of Computing').last);
    await t.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(
      t.widget<AppSelect<Faculty>>(find.byType(AppSelect<Faculty>)).value,
      isNotNull,
    );
  });

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

  testWidgets('a student must answer everything before registering', (t) async {
    await boot(t);
    expect(buttonOf(t).onPressed, isNull, reason: 'nothing answered yet');

    await t.enterText(find.byType(EditableText).at(0), 'Ada');
    await t.enterText(find.byType(EditableText).at(1), 'Lovelace');
    await t.pumpAndSettle();
    expect(buttonOf(t).onPressed, isNull, reason: 'a name alone is not enough');

    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    expect(buttonOf(t).onPressed, isNull);
    await choose(t, find.byType(AppSelect<Department>), 'Computer Science');
    expect(buttonOf(t).onPressed, isNull);
    await choose(
      t,
      find.byType(AppSelect<Programme>),
      'B.Sc. Computer Science',
    );
    expect(buttonOf(t).onPressed, isNull, reason: 'level still missing');

    await choose(t, find.byType(AppSelect<AcademicLevel>), '100L');
    expect(buttonOf(t).onPressed, isNotNull, reason: 'now it is complete');
  });

  testWidgets('staff finish without a programme or level', (t) async {
    await boot(t, student: false);
    await t.enterText(find.byType(EditableText).at(0), 'Grace');
    await t.enterText(find.byType(EditableText).at(1), 'Hopper');
    await t.pumpAndSettle();
    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    expect(buttonOf(t).onPressed, isNull);
    await choose(t, find.byType(AppSelect<Department>), 'Computer Science');
    expect(buttonOf(t).onPressed, isNotNull);
  });

  testWidgets('clearing a parent disables the button again', (t) async {
    await boot(t, student: false);
    await t.enterText(find.byType(EditableText).at(0), 'Grace');
    await t.enterText(find.byType(EditableText).at(1), 'Hopper');
    await t.pumpAndSettle();
    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    await choose(t, find.byType(AppSelect<Department>), 'Computer Science');
    expect(buttonOf(t).onPressed, isNotNull);

    // Re-picking the faculty clears the department, so it is incomplete again.
    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    expect(buttonOf(t).onPressed, isNull);
  });

  testWidgets('staff are not asked for programme or level', (t) async {
    await boot(t, student: false);
    expect(find.byType(AppSelect<Faculty>), findsOneWidget);
    expect(find.byType(AppSelect<Department>), findsOneWidget);
    expect(find.byType(AppSelect<Programme>), findsNothing);
    expect(find.byType(AppSelect<AcademicLevel>), findsNothing);
  });

  _registrationTests();
}

// Does the account actually get created, and with what?
void _registrationTests() {
  testWidgets('a finished form registers and signs in', (t) async {
    final repo = _FakeRepo();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(registrationDraftProvider.notifier)
      ..setInstitution(osun)
      ..setCredentials(email: 'ada@example.com', password: 'Passw0rd!')
      ..setRole(UserRole.student);

    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AcademicDetailsScreen(isStudent: true)),
      ),
    );
    await t.pumpAndSettle();

    await t.enterText(find.byType(EditableText).at(0), 'Ada');
    await t.enterText(find.byType(EditableText).at(1), 'Lovelace');
    await t.pumpAndSettle();
    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    await choose(t, find.byType(AppSelect<Department>), 'Computer Science');
    await choose(
      t,
      find.byType(AppSelect<Programme>),
      'B.Sc. Computer Science',
    );
    await choose(t, find.byType(AppSelect<AcademicLevel>), '100L');

    expect(repo.sent, isNull, reason: 'nothing sent before Continue');
    await t.tap(find.widgetWithText(AppButton, 'Continue'));
    await t.pumpAndSettle();

    final sent = repo.sent;
    expect(sent, isNotNull, reason: 'Continue must call register');
    final json = sent!.toJson();
    expect(json['email'], 'ada@example.com');
    expect(json['firstName'], 'Ada');
    expect(json['lastName'], 'Lovelace');
    expect(json['role'], 'Student');

    // Register returns tokens only and there is no profile endpoint, so this
    // is the one moment the name can be kept. Without it the home screen
    // greets a brand new user with no name at all.
    final profile = container.read(userProfileProvider);
    expect(profile?.firstName, 'Ada');
    expect(profile?.lastName, 'Lovelace');
    expect(profile?.displayName, 'Ada');
    expect(json['institutionId'], 'inst');
    expect(json['facultyId'], 'f1');
    expect(json['departmentId'], 'd1');
    expect(json['programmeId'], 'p1');
    expect(json['academicLevelId'], 'l1');

    // Registering returns a session, so there is no separate sign-in.
    expect(container.read(authProvider), AuthStatus.signedIn);
  });

  testWidgets('a duplicate email says where to go back to', (t) async {
    final repo = _FakeRepo(
      failWith: const ApiException(statusCode: 409, message: 'Conflict'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(registrationDraftProvider.notifier)
      ..setInstitution(osun)
      ..setCredentials(email: 'taken@example.com', password: 'Passw0rd!')
      ..setRole(UserRole.staff);

    t.view.physicalSize = const Size(393, 852);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AcademicDetailsScreen(isStudent: false)),
      ),
    );
    await t.pumpAndSettle();

    await t.enterText(find.byType(EditableText).at(0), 'Grace');
    await t.enterText(find.byType(EditableText).at(1), 'Hopper');
    await t.pumpAndSettle();
    await choose(t, find.byType(AppSelect<Faculty>), 'Faculty of Computing');
    await choose(t, find.byType(AppSelect<Department>), 'Computer Science');
    await t.tap(find.widgetWithText(AppButton, 'Continue'));
    await t.pumpAndSettle();

    expect(find.textContaining('already registered'), findsOneWidget);
    expect(container.read(authProvider), isNot(AuthStatus.signedIn));
  });
}
