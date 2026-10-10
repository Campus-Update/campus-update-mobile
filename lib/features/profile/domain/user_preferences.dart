enum FeedPreferenceMode {
  personalized,
  allCampus,
}

class UserPreferences {
  const UserPreferences({
    this.feedMode = FeedPreferenceMode.personalized,
    this.emergencyAlerts = true,
    this.dailyNewsDigest = true,
    this.pushNotification = true,
    this.twoFactorAuth = true,
    this.passKey = false,
  });

  final FeedPreferenceMode feedMode;
  final bool emergencyAlerts;
  final bool dailyNewsDigest;
  final bool pushNotification;
  final bool twoFactorAuth;
  final bool passKey;

  UserPreferences copyWith({
    FeedPreferenceMode? feedMode,
    bool? emergencyAlerts,
    bool? dailyNewsDigest,
    bool? pushNotification,
    bool? twoFactorAuth,
    bool? passKey,
  }) {
    return UserPreferences(
      feedMode: feedMode ?? this.feedMode,
      emergencyAlerts: emergencyAlerts ?? this.emergencyAlerts,
      dailyNewsDigest: dailyNewsDigest ?? this.dailyNewsDigest,
      pushNotification: pushNotification ?? this.pushNotification,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      passKey: passKey ?? this.passKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'feedMode': feedMode.name,
        'emergencyAlerts': emergencyAlerts,
        'dailyNewsDigest': dailyNewsDigest,
        'pushNotification': pushNotification,
        'twoFactorAuth': twoFactorAuth,
        'passKey': passKey,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      feedMode: json['feedMode'] == FeedPreferenceMode.allCampus.name
          ? FeedPreferenceMode.allCampus
          : FeedPreferenceMode.personalized,
      emergencyAlerts: json['emergencyAlerts'] as bool? ?? true,
      dailyNewsDigest: json['dailyNewsDigest'] as bool? ?? true,
      pushNotification: json['pushNotification'] as bool? ?? true,
      twoFactorAuth: json['twoFactorAuth'] as bool? ?? true,
      passKey: json['passKey'] as bool? ?? false,
    );
  }
}
