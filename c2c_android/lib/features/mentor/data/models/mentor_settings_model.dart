/// Data model for Mentor System Settings Screen matching web frontend (Tab 11 - System Settings)
/// Supports real-time MongoDB Atlas sync with [isMock: false] and seamless offline fallback.
class MentorSettingsData {
  final String id;
  final bool darkMode;
  final bool pushAlerts;
  final bool privacyMode;
  final String alertsLimit;
  final String systemLanguage;
  final String emailDigest;
  final bool soundEffects;
  final String defaultSessionDuration;
  final bool twoFactorAuth;
  final String autoLockTimeout;
  final bool isMock;

  const MentorSettingsData({
    required this.id,
    required this.darkMode,
    required this.pushAlerts,
    required this.privacyMode,
    required this.alertsLimit,
    required this.systemLanguage,
    required this.emailDigest,
    required this.soundEffects,
    required this.defaultSessionDuration,
    required this.twoFactorAuth,
    required this.autoLockTimeout,
    this.isMock = false,
  });

  factory MentorSettingsData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return MentorSettingsData(
      id: json['id'] as String? ?? json['_id'] as String? ?? 'ms-1',
      darkMode: json['darkMode'] as bool? ?? false,
      pushAlerts: json['pushAlerts'] as bool? ?? true,
      privacyMode: json['privacyMode'] as bool? ?? false,
      alertsLimit: json['alertsLimit'] as String? ?? '10',
      systemLanguage: json['systemLanguage'] as String? ?? 'English',
      emailDigest: json['emailDigest'] as String? ?? 'Daily Digest',
      soundEffects: json['soundEffects'] as bool? ?? true,
      defaultSessionDuration: json['defaultSessionDuration'] as String? ?? '45 min',
      twoFactorAuth: json['twoFactorAuth'] as bool? ?? true,
      autoLockTimeout: json['autoLockTimeout'] as String? ?? '30 min',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'darkMode': darkMode,
      'pushAlerts': pushAlerts,
      'privacyMode': privacyMode,
      'alertsLimit': alertsLimit,
      'systemLanguage': systemLanguage,
      'emailDigest': emailDigest,
      'soundEffects': soundEffects,
      'defaultSessionDuration': defaultSessionDuration,
      'twoFactorAuth': twoFactorAuth,
      'autoLockTimeout': autoLockTimeout,
    };
  }

  MentorSettingsData copyWith({
    String? id,
    bool? darkMode,
    bool? pushAlerts,
    bool? privacyMode,
    String? alertsLimit,
    String? systemLanguage,
    String? emailDigest,
    bool? soundEffects,
    String? defaultSessionDuration,
    bool? twoFactorAuth,
    String? autoLockTimeout,
    bool? isMock,
  }) {
    return MentorSettingsData(
      id: id ?? this.id,
      darkMode: darkMode ?? this.darkMode,
      pushAlerts: pushAlerts ?? this.pushAlerts,
      privacyMode: privacyMode ?? this.privacyMode,
      alertsLimit: alertsLimit ?? this.alertsLimit,
      systemLanguage: systemLanguage ?? this.systemLanguage,
      emailDigest: emailDigest ?? this.emailDigest,
      soundEffects: soundEffects ?? this.soundEffects,
      defaultSessionDuration: defaultSessionDuration ?? this.defaultSessionDuration,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
      isMock: isMock ?? this.isMock,
    );
  }
}
