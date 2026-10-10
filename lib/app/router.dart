import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../core/auth/auth_state.dart';
import '../core/storage/storage_providers.dart';
import '../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../features/announcements/presentation/screens/announcements_list_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/password_reset_success_screen.dart';
import '../features/auth/presentation/screens/academic_details_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/select_role_screen.dart';
import '../features/auth/presentation/screens/select_school_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/verify_otp_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/events_list_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/news/presentation/screens/news_detail_screen.dart';
import '../features/news/presentation/screens/news_list_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/account_info_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/preferences_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/settings_screen.dart';
import '../features/profile/presentation/screens/support_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../shared/widgets/nav_icons.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';
  static const forgotPassword = '/forgot-password';

  // The know-your-user questions, asked once the account exists.
  static const selectSchool = '/select-school';
  static const selectRole = '/select-role';
  static const academicDetails = '/academic-details';
  static const resetPassword = '/reset-password';
  static const passwordResetSuccess = '/password-reset-success';

  static const home = '/home';
  static const news = '/news';
  static const announcements = '/announcements';
  static const events = '/events';
  static const profile = '/profile';

  static const calendar = '/calendar';
  static const notifications = '/notifications';
  static const search = '/search';
  static const editProfile = '/profile/edit';
  static const accountInformation = '/profile/account';
  static const preferences = '/profile/preferences';
  static const settings = '/profile/settings';
  static const changePassword = '/profile/change-password';
  static const support = '/profile/support';

  /// Routes reachable without a session.
  static const unauthenticated = {
    splash,
    onboarding,
    login,
    register,
    verifyOtp,
    forgotPassword,
    selectSchool,
    selectRole,
    academicDetails,
    resetPassword,
    passwordResetSuccess,
  };
}

/// Bridges auth changes into go_router without rebuilding the router, which
/// would drop the navigation stack.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthListenable(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authProvider);
      final location = state.matchedLocation;
      final inUnauthenticatedZone = Routes.unauthenticated.contains(location);

      return switch (status) {
        // Session is still being restored; hold on the splash screen.
        AuthStatus.unknown => location == Routes.splash ? null : Routes.splash,
        // First run lands on onboarding; after that, straight to login.
        AuthStatus.signedOut =>
          inUnauthenticatedZone && location != Routes.splash
              ? null
              : (ref.read(prefsStorageProvider).onboardingSeen
                    ? Routes.login
                    : Routes.onboarding),
        AuthStatus.signedIn => inUnauthenticatedZone ? Routes.home : null,
      };
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.verifyOtp,
        builder: (context, state) {
          final args = state.extra as OtpArgs?;
          return VerifyOtpScreen(
            title: args?.title ?? 'Verify OTP',
            email: args?.email,
            onVerified: args == null
                ? null
                : (_) {
                    if (args.next == Routes.home) {
                      ref
                          .read(authProvider.notifier)
                          .signedIn(email: args.email);
                    } else {
                      context.push(args.next);
                    }
                  },
          );
        },
      ),
      GoRoute(
        path: Routes.selectSchool,
        builder: (_, __) => const SelectSchoolScreen(),
      ),
      GoRoute(
        path: Routes.selectRole,
        builder: (_, __) => const SelectRoleScreen(),
      ),
      GoRoute(
        path: Routes.academicDetails,
        builder: (_, state) =>
            AcademicDetailsScreen(isStudent: state.extra as bool? ?? true),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, __) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: Routes.passwordResetSuccess,
        builder: (_, __) => const PasswordResetSuccessScreen(),
      ),

      // Above the shell: these cover the tab bar and pop back to the active tab.
      GoRoute(
        path: Routes.announcements,
        builder: (_, __) => const AnnouncementsListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) =>
                AnnouncementDetailScreen(id: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(path: Routes.search, builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: Routes.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.accountInformation,
        builder: (_, __) => const AccountInformationScreen(),
      ),
      GoRoute(
        path: Routes.preferences,
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: Routes.support,
        builder: (_, __) => const SupportScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, state) {
                  final pendingParam =
                      state.uri.queryParameters['pendingProfile'];
                  final bool? hasPending = pendingParam != null
                      ? pendingParam == 'true'
                      : null;
                  return HomeScreen(hasPendingProfile: hasPending);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.news,
                builder: (_, __) => const NewsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        NewsDetailScreen(id: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.events,
                builder: (_, __) => const EventsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, s) =>
                        EventDetailScreen(id: s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.calendar,
                builder: (_, __) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// The bottom tab bar. Data-driven so adding a tab is one list entry.
class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    const inactive = AppColors.textMuted;
    const active = AppColors.indigo;

    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          // `initialLocation: true` resets a tab to its root when re-tapped.
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(
              icon: NavHomeIcon(color: inactive),
              selectedIcon: NavHomeIcon(color: active),
              label: 'Home',
            ),
            NavigationDestination(
              icon: NavNewsIcon(color: inactive),
              selectedIcon: NavNewsIcon(color: active),
              label: 'News',
            ),
            NavigationDestination(
              icon: NavEventsIcon(color: inactive),
              selectedIcon: NavEventsIcon(color: active),
              label: 'Events',
            ),
            NavigationDestination(
              icon: NavCalendarIcon(color: inactive),
              selectedIcon: NavCalendarIcon(color: active),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: NavProfileIcon(color: inactive),
              selectedIcon: NavProfileIcon(color: active),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
