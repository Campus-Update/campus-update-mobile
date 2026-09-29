import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';

/// Manages whether the user has a pending profile to complete.
///
/// When true, the Home screen displays the profile completion banner.
/// When false, the Home screen displays the feed directly without the banner.
class PendingProfileNotifier extends Notifier<bool> {
  @override
  bool build() {
    try {
      return ref.watch(prefsStorageProvider).hasPendingProfile;
    } catch (_) {
      // In unit/widget tests where SharedPreferences may not be initialized.
      return true;
    }
  }

  void setHasPendingProfile(bool value) {
    state = value;
    try {
      ref.read(prefsStorageProvider).setHasPendingProfile(value);
    } catch (_) {}
  }

  void dismiss() => setHasPendingProfile(false);
  void complete() => setHasPendingProfile(false);
  void reset() => setHasPendingProfile(true);
}

final pendingProfileProvider = NotifierProvider<PendingProfileNotifier, bool>(
  PendingProfileNotifier.new,
);
