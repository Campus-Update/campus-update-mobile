import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/profile/domain/user_preferences.dart';
import '../../features/profile/domain/user_profile.dart';

/// Non-sensitive local settings.
class PrefsStorage {
  const PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeen = 'onboarding_seen';
  static const _feedScope = 'feed_scope';

  bool get onboardingSeen => _prefs.getBool(_onboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_onboardingSeen, value);

  /// `personalised` or `allCampus` — the PRD's two feed modes.
  String get feedScope => _prefs.getString(_feedScope) ?? 'personalised';
  Future<void> setFeedScope(String value) =>
      _prefs.setString(_feedScope, value);

  static const _hasPendingProfile = 'has_pending_profile';

  /// Whether the user has a pending profile to complete. Defaults to true.
  bool get hasPendingProfile => _prefs.getBool(_hasPendingProfile) ?? true;
  Future<void> setHasPendingProfile(bool value) =>
      _prefs.setBool(_hasPendingProfile, value);

  static const _currentUserEmail = 'current_user_email';

  String? get currentUserEmail => _prefs.getString(_currentUserEmail);

  Future<void> setCurrentUserEmail(String? email) async {
    if (email == null || email.isEmpty) {
      await _prefs.remove(_currentUserEmail);
    } else {
      await _prefs.setString(_currentUserEmail, email.toLowerCase().trim());
    }
  }

  static String _profileKeyFor(String email) =>
      'user_profile_${email.toLowerCase().trim()}';

  UserProfile? getUserProfile(String email) {
    final raw = _prefs.getString(_profileKeyFor(email));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final email = profile.email?.toLowerCase().trim();
    if (email != null && email.isNotEmpty) {
      final jsonStr = jsonEncode(profile.toJson());
      await _prefs.setString(_profileKeyFor(email), jsonStr);
    }
  }

  UserProfile? getCurrentUserProfile() {
    final email = currentUserEmail;
    if (email == null || email.isEmpty) return null;
    return getUserProfile(email);
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_currentUserEmail);
  }

  static const _userPreferencesKey = 'user_preferences';

  UserPreferences getUserPreferences() {
    final raw = _prefs.getString(_userPreferencesKey);
    if (raw == null || raw.isEmpty) return const UserPreferences();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromJson(map);
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _prefs.setString(
      _userPreferencesKey,
      jsonEncode(preferences.toJson()),
    );
  }
}
