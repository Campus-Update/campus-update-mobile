import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/data/profile_providers.dart';
import '../storage/storage_providers.dart';

/// Which auth zone the router should show.
///
/// [unknown] is the splash state: the session is being restored from secure
/// storage and neither zone should be shown yet.
enum AuthStatus { unknown, signedOut, signedIn }

/// Session state.
///
/// Restoring is currently a token and session presence check. Once the auth repository
/// lands it should also validate the token and fetch the profile.
class AuthNotifier extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    _restore();
    return AuthStatus.unknown;
  }

  Future<void> _restore() async {
    try {
      final token = await ref.read(secureStorageProvider).readAccessToken();
      final currentEmail = ref.read(prefsStorageProvider).currentUserEmail;
      state = (token != null || currentEmail != null)
          ? AuthStatus.signedIn
          : AuthStatus.signedOut;
    } catch (_) {
      // Keychain unavailable (tests, or a device that denies it): treat the
      // user as signed out rather than hanging on the splash screen forever.
      state = AuthStatus.signedOut;
    }
  }

  void signedIn({String? email, String? firstName, String? lastName}) {
    if (email != null && email.isNotEmpty) {
      ref
          .read(userProfileProvider.notifier)
          .signIn(email: email, firstName: firstName, lastName: lastName);
    }
    state = AuthStatus.signedIn;
  }

  /// Sets the state without touching storage. Used by the router tests and by
  /// the dev-only shortcut on the login screen.
  void signedOut() => state = AuthStatus.signedOut;

  Future<void> signOut() async {
    await ref.read(secureStorageProvider).clear();
    await ref.read(userProfileProvider.notifier).signOut();
    state = AuthStatus.signedOut;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
