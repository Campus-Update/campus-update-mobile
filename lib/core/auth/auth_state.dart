import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';

/// Which auth zone the router should show.
///
/// [unknown] is the splash state: the session is being restored from secure
/// storage and neither zone should be shown yet.
enum AuthStatus { unknown, signedOut, signedIn }

/// Session state.
///
/// Restoring is currently only a token presence check. Once the auth repository
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
      state = token == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    } catch (_) {
      // Keychain unavailable (tests, or a device that denies it): treat the
      // user as signed out rather than hanging on the splash screen forever.
      state = AuthStatus.signedOut;
    }
  }

  void signedIn() => state = AuthStatus.signedIn;

  /// Sets the state without touching storage. Used by the router tests and by
  /// the dev-only shortcut on the login screen.
  void signedOut() => state = AuthStatus.signedOut;

  Future<void> signOut() async {
    await ref.read(secureStorageProvider).clear();
    state = AuthStatus.signedOut;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);
