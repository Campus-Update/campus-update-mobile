import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/user_preferences.dart';

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    try {
      return ref.watch(prefsStorageProvider).getUserPreferences();
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<void> updatePreferences({
    FeedPreferenceMode? feedMode,
    bool? emergencyAlerts,
    bool? dailyNewsDigest,
    bool? pushNotification,
    bool? twoFactorAuth,
    bool? passKey,
  }) async {
    final updated = state.copyWith(
      feedMode: feedMode,
      emergencyAlerts: emergencyAlerts,
      dailyNewsDigest: dailyNewsDigest,
      pushNotification: pushNotification,
      twoFactorAuth: twoFactorAuth,
      passKey: passKey,
    );
    state = updated;
    try {
      await ref.read(prefsStorageProvider).saveUserPreferences(updated);
    } catch (_) {}
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
  UserPreferencesNotifier.new,
);
