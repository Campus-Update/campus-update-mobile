import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../features/announcements/presentation/screens/announcements_list_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/events_list_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/news/presentation/screens/news_detail_screen.dart';
import '../features/news/presentation/screens/news_list_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/preferences_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const news = '/news';
  static const announcements = '/announcements';
  static const events = '/events';
  static const profile = '/profile';

  static const calendar = '/calendar';
  static const notifications = '/notifications';
  static const search = '/search';
  static const editProfile = '/profile/edit';
  static const preferences = '/profile/preferences';

  /// Routes reachable without a session.
  static const unauthenticated = {
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
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
        AuthStatus.signedOut =>
          inUnauthenticatedZone && location != Routes.splash
              ? null
              : Routes.login,
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
        path: Routes.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // Above the shell: these cover the tab bar and pop back to the active tab.
      GoRoute(
        path: Routes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(path: Routes.search, builder: (_, __) => const SearchScreen()),

      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const HomeScreen(),
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
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, __) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'preferences',
                    builder: (_, __) => const PreferencesScreen(),
                  ),
                ],
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

  static const _tabs = [
    (icon: Icons.article_outlined, selected: Icons.article, label: 'News'),
    (
      icon: Icons.campaign_outlined,
      selected: Icons.campaign,
      label: 'Announcements',
    ),
    (icon: Icons.event_outlined, selected: Icons.event, label: 'Events'),
    (
      icon: Icons.calendar_month_outlined,
      selected: Icons.calendar_month,
      label: 'Calendar',
    ),
    (icon: Icons.person_outline, selected: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // `initialLocation: true` resets a tab to its root when re-tapped.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selected),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
