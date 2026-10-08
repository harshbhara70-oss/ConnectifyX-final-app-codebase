/// Domain models for the College Settings feature.
///
/// Strictly mirrors web `src/pages/college/Settings.tsx`:
/// 1. Account Information (Email, Phone, Name, Verification status) - Live MongoDB `/college/profile`
/// 2. Change Password (Current, New, Confirm, Strength)
/// 3. Two-Factor Authentication (SMS-based verification toggle)
/// 4. Notification Preferences (Email, SMS alerts, Recruiter activity, Weekly digest, Drive reminders)
/// 5. Placement Cycle Configuration (Eligibility threshold, Auto-notify toggle)
/// 6. Data & Privacy (CSV Export, Log out of all devices)
/// 7. Danger Zone (Deactivate Account)
class CollegeSettingsData {
  final CollegeAccountInfo accountInfo;
  final CollegeSecuritySettings security;
  final CollegeNotificationPreferences notifications;
  final CollegePlacementCycleSettings placementCycle;

  const CollegeSettingsData({
    required this.accountInfo,
    required this.security,
    required this.notifications,
    required this.placementCycle,
  });

  CollegeSettingsData copyWith({
    CollegeAccountInfo? accountInfo,
    CollegeSecuritySettings? security,
    CollegeNotificationPreferences? notifications,
    CollegePlacementCycleSettings? placementCycle,
  }) {
    return CollegeSettingsData(
      accountInfo: accountInfo ?? this.accountInfo,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
      placementCycle: placementCycle ?? this.placementCycle,
    );
  }

  static CollegeSettingsData get initial => CollegeSettingsData(
        accountInfo: CollegeAccountInfo.defaultData,
        security: CollegeSecuritySettings.defaultData,
        notifications: CollegeNotificationPreferences.defaultData,
        placementCycle: CollegePlacementCycleSettings.defaultData,
      );
}

/// 1. Account Information Model
class CollegeAccountInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String university;
  final String address;
  final String website;
  final bool isVerified;
  final bool isMock;

  const CollegeAccountInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.university,
    required this.address,
    required this.website,
    this.isVerified = true,
    this.isMock = false,
  });

  factory CollegeAccountInfo.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return CollegeAccountInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'BITS Pilani Placement Cell Admin',
      email: json['email']?.toString() ?? 'placement@pilani.bits-pilani.ac.in',
      phone: json['phone']?.toString() ?? '+91 9876543210',
      university: json['university']?.toString() ?? 'BITS Pilani',
      address: json['address']?.toString() ?? 'Vidya Vihar, Pilani, Rajasthan - 333031',
      website: json['website']?.toString() ?? 'https://www.bits-pilani.ac.in',
      isVerified: true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'university': university,
        'address': address,
        'website': website,
      };

  CollegeAccountInfo copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? university,
    String? address,
    String? website,
    bool? isVerified,
    bool? isMock,
  }) {
    return CollegeAccountInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      address: address ?? this.address,
      website: website ?? this.website,
      isVerified: isVerified ?? this.isVerified,
      isMock: isMock ?? this.isMock,
    );
  }

  static CollegeAccountInfo get defaultData => const CollegeAccountInfo(
        id: 'col-default',
        name: 'BITS Pilani Placement Cell Admin',
        email: 'placement@pilani.bits-pilani.ac.in',
        phone: '+91 9876543210',
        university: 'BITS Pilani',
        address: 'Vidya Vihar, Pilani, Rajasthan - 333031',
        website: 'https://www.bits-pilani.ac.in',
        isVerified: true,
        isMock: true,
      );
}

/// 2. Security & 2FA Model
class CollegeSecuritySettings {
  final bool twoFactorEnabled;
  final bool isMock;

  const CollegeSecuritySettings({
    this.twoFactorEnabled = false,
    this.isMock = true,
  });

  factory CollegeSecuritySettings.fromJson(Map<String, dynamic> json, {bool isMock = true}) {
    return CollegeSecuritySettings(
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'twoFactorEnabled': twoFactorEnabled,
      };

  CollegeSecuritySettings copyWith({
    bool? twoFactorEnabled,
    bool? isMock,
  }) {
    return CollegeSecuritySettings(
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      isMock: isMock ?? this.isMock,
    );
  }

  static CollegeSecuritySettings get defaultData => const CollegeSecuritySettings(
        twoFactorEnabled: false,
        isMock: true,
      );
}

/// 3. Notification Preferences Model
class CollegeNotificationPreferences {
  final bool notifyEmail;
  final bool notifySms;
  final bool notifyRecruiter;
  final bool notifyDigest;
  final bool notifyDrives;
  final bool isMock;

  const CollegeNotificationPreferences({
    this.notifyEmail = true,
    this.notifySms = false,
    this.notifyRecruiter = true,
    this.notifyDigest = true,
    this.notifyDrives = true,
    this.isMock = true,
  });

  factory CollegeNotificationPreferences.fromJson(Map<String, dynamic> json, {bool isMock = true}) {
    return CollegeNotificationPreferences(
      notifyEmail: json['notifyEmail'] as bool? ?? true,
      notifySms: json['notifySms'] as bool? ?? false,
      notifyRecruiter: json['notifyRecruiter'] as bool? ?? true,
      notifyDigest: json['notifyDigest'] as bool? ?? true,
      notifyDrives: json['notifyDrives'] as bool? ?? true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'notifyEmail': notifyEmail,
        'notifySms': notifySms,
        'notifyRecruiter': notifyRecruiter,
        'notifyDigest': notifyDigest,
        'notifyDrives': notifyDrives,
      };

  CollegeNotificationPreferences copyWith({
    bool? notifyEmail,
    bool? notifySms,
    bool? notifyRecruiter,
    bool? notifyDigest,
    bool? notifyDrives,
    bool? isMock,
  }) {
    return CollegeNotificationPreferences(
      notifyEmail: notifyEmail ?? this.notifyEmail,
      notifySms: notifySms ?? this.notifySms,
      notifyRecruiter: notifyRecruiter ?? this.notifyRecruiter,
      notifyDigest: notifyDigest ?? this.notifyDigest,
      notifyDrives: notifyDrives ?? this.notifyDrives,
      isMock: isMock ?? this.isMock,
    );
  }

  static CollegeNotificationPreferences get defaultData =>
      const CollegeNotificationPreferences(
        notifyEmail: true,
        notifySms: false,
        notifyRecruiter: true,
        notifyDigest: true,
        notifyDrives: true,
        isMock: true,
      );
}

/// 4. Placement Cycle Configuration Model
class CollegePlacementCycleSettings {
  final int eligibilityThreshold;
  final bool autoNotifyEligible;
  final bool isMock;

  const CollegePlacementCycleSettings({
    this.eligibilityThreshold = 70,
    this.autoNotifyEligible = true,
    this.isMock = true,
  });

  factory CollegePlacementCycleSettings.fromJson(Map<String, dynamic> json, {bool isMock = true}) {
    return CollegePlacementCycleSettings(
      eligibilityThreshold: (json['eligibilityThreshold'] as num?)?.toInt() ?? 70,
      autoNotifyEligible: json['autoNotifyEligible'] as bool? ?? true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'eligibilityThreshold': eligibilityThreshold,
        'autoNotifyEligible': autoNotifyEligible,
      };

  CollegePlacementCycleSettings copyWith({
    int? eligibilityThreshold,
    bool? autoNotifyEligible,
    bool? isMock,
  }) {
    return CollegePlacementCycleSettings(
      eligibilityThreshold: eligibilityThreshold ?? this.eligibilityThreshold,
      autoNotifyEligible: autoNotifyEligible ?? this.autoNotifyEligible,
      isMock: isMock ?? this.isMock,
    );
  }

  static CollegePlacementCycleSettings get defaultData =>
      const CollegePlacementCycleSettings(
        eligibilityThreshold: 70,
        autoNotifyEligible: true,
        isMock: true,
      );
}
