import 'package:campus_update/app/theme/app_theme.dart';
import 'package:campus_update/core/storage/prefs_storage.dart';
import 'package:campus_update/core/storage/storage_providers.dart';
import 'package:campus_update/features/auth/data/school_repository.dart';
import 'package:campus_update/features/auth/domain/default_institution.dart';
import 'package:campus_update/features/profile/data/preferences_provider.dart';
import 'package:campus_update/features/profile/data/profile_providers.dart';
import 'package:campus_update/features/profile/domain/user_preferences.dart';
import 'package:campus_update/features/profile/domain/user_profile.dart';
import 'package:campus_update/features/profile/presentation/screens/account_info_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/change_password_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/preferences_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/profile_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/settings_screen.dart';
import 'package:campus_update/features/profile/presentation/screens/support_screen.dart';
import 'package:campus_update/features/profile/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PrefsStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = PrefsStorage(prefs);
  });

  Widget createTestWidget(Widget child, [ProviderContainer? container]) {
    final c = container ??
        ProviderContainer(
          overrides: [
            prefsStorageProvider.overrideWithValue(storage),
            schoolsProvider.overrideWith(
              (ref) => Future.value([defaultLeadCityUniversity]),
            ),
          ],
        );

    return UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: child,
      ),
    );
  }

  group('ProfileScreen (Screen 1)', () {
    testWidgets('renders Profile screen with user card and menu items', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Profile'), findsOneWidget);

      // Default user card details
      expect(find.text('Jeremiah Alalade'), findsOneWidget);
      expect(find.text('ajeremiahfig@gmail.com'), findsOneWidget);
      expect(find.text('Lead City University'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Menu list items
      expect(find.text('Account information'), findsOneWidget);
      expect(find.text('Preference'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Saved articles'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('displays customized user profile when available', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          prefsStorageProvider.overrideWithValue(storage),
          schoolsProvider.overrideWith(
            (ref) => Future.value([defaultLeadCityUniversity]),
          ),
        ],
      );

      await container.read(userProfileProvider.notifier).setProfile(
            const UserProfile(
              firstName: 'Tolani',
              lastName: 'Balogun',
              email: 'tolani@leadcity.edu.ng',
              institutionName: 'Lead City University',
            ),
          );

      await tester.pumpWidget(
        createTestWidget(const ProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tolani Balogun'), findsOneWidget);
      expect(find.text('tolani@leadcity.edu.ng'), findsOneWidget);
      expect(find.text('TB'), findsOneWidget);
    });

    testWidgets('shows initials when no avatar is selected, without hardcoding image', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const ProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('JA'), findsOneWidget);
    });
  });

  group('AccountInformationScreen (Screen 2)', () {
    testWidgets('renders account details rows accurately', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AccountInformationScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Personal details'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Check fields and default values
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Jeremiah'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Alalade'), findsOneWidget);
      expect(find.text('Institution'), findsOneWidget);
      expect(find.text('Lead City University'), findsOneWidget);
      expect(find.text('Faculty'), findsOneWidget);
      expect(
        find.text('Faculty of Computting Information Technology (FOCIT)'),
        findsOneWidget,
      );
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('Programme'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Software Engineering'), findsNWidgets(3));
    });
  });

  group('EditProfileScreen (Screen 3)', () {
    testWidgets('renders Edit details form and saves changes', (tester) async {
      final container = ProviderContainer(
        overrides: [
          prefsStorageProvider.overrideWithValue(storage),
          schoolsProvider.overrideWith(
            (ref) => Future.value([defaultLeadCityUniversity]),
          ),
        ],
      );

      await tester.pumpWidget(
        createTestWidget(const EditProfileScreen(), container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit details'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Faculty'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('Programme'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);

      // Enter a new name
      await tester.enterText(
        find.byType(EditableText).first,
        'Jeremiah Alalade',
      );
      await tester.pumpAndSettle();

      // Tap Save changes
      await tester.ensureVisible(find.text('Save changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      final profile = container.read(userProfileProvider);
      expect(profile?.firstName, 'Jeremiah');
      expect(profile?.lastName, 'Alalade');
      expect(profile?.fullName, 'Jeremiah Alalade');
    });
  });

  group('PreferenceScreen', () {
    testWidgets('renders feed preference options and toggle switches', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          prefsStorageProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(
        createTestWidget(const PreferencesScreen(), container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preference'), findsOneWidget);
      expect(find.text('Personalized'), findsOneWidget);
      expect(find.text('All campus information'), findsOneWidget);
      expect(find.text('Emergency Alerts'), findsOneWidget);
      expect(find.text('Daily News Digest'), findsOneWidget);

      // Initial state is personalized
      expect(
        container.read(userPreferencesProvider).feedMode,
        FeedPreferenceMode.personalized,
      );

      // Tap 'All campus information'
      await tester.tap(find.text('All campus information'));
      await tester.pumpAndSettle();

      expect(
        container.read(userPreferencesProvider).feedMode,
        FeedPreferenceMode.allCampus,
      );
    });
  });

  group('SettingsScreen and LogoutConfirmationDialog', () {
    testWidgets('renders settings options and active session', (tester) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Authentication & Login'), findsOneWidget);
      expect(find.text('Push Notification'), findsOneWidget);
      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.text('Pass-key'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Active Sessions'), findsOneWidget);
      expect(find.text('iPhone 13'), findsOneWidget);
      expect(find.text('This Device • Lagos, Nigeria'), findsOneWidget);
      expect(find.text('Logout from all devices'), findsOneWidget);
    });

    testWidgets('tapping Logout from all devices opens confirmation dialog', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout from all devices'));
      await tester.pumpAndSettle();

      // Dialog is open
      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(
        find.text(
          'You will be logged out of all active sessions on other devices. This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm Logout'), findsOneWidget);

      // Tap Cancel dismisses the dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(LogoutConfirmationDialog), findsNothing);
    });
  });

  group('ChangePasswordScreen', () {
    testWidgets('validates password criteria dynamically', (tester) async {
      await tester.pumpWidget(createTestWidget(const ChangePasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
      expect(find.text('Password must contain:'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('At least 1 uppercase letter (A-Z)'), findsOneWidget);
      expect(find.text('At least 1 lowercase letter (a-z)'), findsOneWidget);
      expect(find.text('At least 1 number (0-9)'), findsOneWidget);
      expect(
        find.text('At least 1 special character (e.g. ! @ # \$ %)'),
        findsOneWidget,
      );
      expect(find.text('Password matches'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);

      // Enter Current Password (first EditableText)
      final editableFinder = find.byType(EditableText);
      await tester.enterText(editableFinder.at(0), 'OldPass123!');
      await tester.pumpAndSettle();

      // Enter New Password (second EditableText)
      await tester.enterText(editableFinder.at(1), 'NewPass123!');
      await tester.pumpAndSettle();

      // Enter matching Confirm New Password (third EditableText)
      await tester.enterText(editableFinder.at(2), 'NewPass123!');
      await tester.pumpAndSettle();

      // Tap Save changes
      await tester.ensureVisible(find.text('Save changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Password changed successfully'), findsOneWidget);
    });
  });

  group('SupportScreen', () {
    testWidgets('renders all support options, coming soon badge, and action button', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SupportScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Call Us'), findsOneWidget);
      expect(find.text('Send an Email'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Chat With Support'), findsOneWidget);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Instagram'), findsOneWidget);
      expect(find.text('X (Twitter)'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('tapping Call Us shows support telephone options', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Call Us'));
      await tester.pumpAndSettle();

      expect(find.text('Call Campus Support'), findsOneWidget);
      expect(find.text('Student Helpdesk Line'), findsOneWidget);
      expect(find.text('+234 800 5323 2489'), findsOneWidget);
    });

    testWidgets('tapping Send an Email shows support email options', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send an Email'));
      await tester.pumpAndSettle();

      expect(find.text('Send an Email'), findsWidgets);
      expect(find.text('Support Desk'), findsOneWidget);
      expect(find.text('support@leadcity.edu.ng'), findsOneWidget);
    });

    testWidgets('tapping Chat With Support shows coming soon message', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat With Support'));
      await tester.pumpAndSettle();

      expect(
        find.text('Live chat support is coming soon in an upcoming update.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping Save changes shows confirmation snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(const SupportScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save changes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Support preferences saved'), findsOneWidget);
    });
  });
}
