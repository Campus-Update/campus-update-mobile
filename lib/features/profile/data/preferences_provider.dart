import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../../shared/data/feed_repository.dart';
import '../domain/user_preferences.dart';
import 'profile_providers.dart';

/// The Preferences and Settings switches.
///
/// Two of them live on the API, through `PUT /auth/academic-settings`: the
/// feed mode (`allCampusFeed`) and push notifications
/// (`pushNotificationsEnabled`). For a signed-in user those are read from the
/// profile and saved there. The rest — emergency alerts, the daily digest,
/// two-factor and pass-key — have no endpoint yet and stay on this phone.
class UserPreferencesNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    UserPreferences local;
    try {
      local = ref.watch(prefsStorageProvider).getUserPreferences();
    } catch (_) {
      local = const UserPreferences();
    }
    final profile = ref.watch(userProfileProvider);
    return local.copyWith(
      feedMode: switch (profile?.allCampusFeed) {
        true => FeedPreferenceMode.allCampus,
        false => FeedPreferenceMode.personalized,
        null => null,
      },
      pushNotification: profile?.pushNotificationsEnabled,
    );
  }

  /// Throws [ApiException] when the feed mode or push setting could not be
  /// saved; the switch is put back first.
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
    final previous = state;
    state = updated;
    try {
      await ref.read(prefsStorageProvider).saveUserPreferences(updated);
    } catch (_) {}

    if ((feedMode != null || pushNotification != null) &&
        ref.read(userProfileProvider) != null) {
      try {
        await ref
            .read(userProfileProvider.notifier)
            .saveFeedSettings(
              allCampusFeed: feedMode == null
                  ? null
                  : feedMode == FeedPreferenceMode.allCampus,
              pushNotificationsEnabled: pushNotification,
            );
        // The feed mode decides what /feed returns, so the feed reloads.
        if (feedMode != null) ref.invalidate(feedRepositoryProvider);
      } catch (_) {
        // Put the switch back, so the screen does not claim a setting the
        // API never took.
        state = previous;
        rethrow;
      }
    }
  }
}

final userPreferencesProvider =
    NotifierProvider<UserPreferencesNotifier, UserPreferences>(
      UserPreferencesNotifier.new,
    );
