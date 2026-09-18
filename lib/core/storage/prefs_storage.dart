import 'package:shared_preferences/shared_preferences.dart';

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
}
