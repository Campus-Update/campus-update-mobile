import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/user_profile.dart';

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

/// Manages the authenticated user's profile and identity.
class UserProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    try {
      return ref.watch(prefsStorageProvider).getCurrentUserProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> setProfile(UserProfile profile) async {
    state = profile;
    try {
      await ref.read(prefsStorageProvider).saveUserProfile(profile);
      if (profile.email != null && profile.email!.isNotEmpty) {
        await ref.read(prefsStorageProvider).setCurrentUserEmail(profile.email);
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? matriculationOrStaffNumber,
    String? institutionId,
    String? facultyId,
    String? departmentId,
    String? programmeId,
    String? academicLevelId,
  }) async {
    final current = state ?? const UserProfile();
    final updated = current.copyWith(
      firstName: firstName ?? current.firstName,
      lastName: lastName ?? current.lastName,
      matriculationOrStaffNumber:
          matriculationOrStaffNumber ?? current.matriculationOrStaffNumber,
      institutionId: institutionId ?? current.institutionId,
      facultyId: facultyId ?? current.facultyId,
      departmentId: departmentId ?? current.departmentId,
      programmeId: programmeId ?? current.programmeId,
      academicLevelId: academicLevelId ?? current.academicLevelId,
    );
    await setProfile(updated);
  }

  Future<void> signIn({
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final prefs = ref.read(prefsStorageProvider);
      var profile = prefs.getUserProfile(email);
      if (profile != null) {
        if ((firstName != null && firstName.isNotEmpty) ||
            (lastName != null && lastName.isNotEmpty)) {
          profile = profile.copyWith(
            firstName: firstName ?? profile.firstName,
            lastName: lastName ?? profile.lastName,
          );
          await prefs.saveUserProfile(profile);
        }
      } else {
        profile = UserProfile(
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
        await prefs.saveUserProfile(profile);
      }
      await prefs.setCurrentUserEmail(email);
      state = profile;
    } catch (_) {
      state = UserProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    }
  }

  Future<void> signOut() async {
    state = null;
    try {
      await ref.read(prefsStorageProvider).clearCurrentUser();
    } catch (_) {}
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile?>(
  UserProfileNotifier.new,
);
