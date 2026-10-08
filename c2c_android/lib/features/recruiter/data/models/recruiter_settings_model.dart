class RecruiterTeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String initials;

  const RecruiterTeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
  });

  factory RecruiterTeamMember.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? 'Team Member';
    final parts = name.trim().split(' ');
    String initials = 'TM';
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0][0].toUpperCase();
    }

    return RecruiterTeamMember(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: json['email']?.toString() ?? 'member@company.com',
      role: json['role']?.toString() ?? 'Recruiter',
      initials: json['initials']?.toString() ?? initials,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'initials': initials,
      };
}

class RecruiterNotificationPreferences {
  final bool emailAlerts;
  final bool pushAlerts;
  final String candidateDigest;
  final bool applicationNotifications;

  const RecruiterNotificationPreferences({
    this.emailAlerts = true,
    this.pushAlerts = true,
    this.candidateDigest = 'Daily Digest',
    this.applicationNotifications = true,
  });

  factory RecruiterNotificationPreferences.fromJson(Map<String, dynamic> json) {
    return RecruiterNotificationPreferences(
      emailAlerts: json['emailAlerts'] as bool? ?? true,
      pushAlerts: json['pushAlerts'] as bool? ?? true,
      candidateDigest: json['candidateDigest']?.toString() ?? 'Daily Digest',
      applicationNotifications: json['applicationNotifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'emailAlerts': emailAlerts,
        'pushAlerts': pushAlerts,
        'candidateDigest': candidateDigest,
        'applicationNotifications': applicationNotifications,
      };

  RecruiterNotificationPreferences copyWith({
    bool? emailAlerts,
    bool? pushAlerts,
    String? candidateDigest,
    bool? applicationNotifications,
  }) {
    return RecruiterNotificationPreferences(
      emailAlerts: emailAlerts ?? this.emailAlerts,
      pushAlerts: pushAlerts ?? this.pushAlerts,
      candidateDigest: candidateDigest ?? this.candidateDigest,
      applicationNotifications: applicationNotifications ?? this.applicationNotifications,
    );
  }
}

class RecruiterSettingsModel {
  final String repName;
  final String companyName;
  final String websiteUrl;
  final String aboutCompany;
  final String? logoUrl;
  final String verificationStatus; // "VERIFIED" | "PENDING" | "UNFILLED"
  final bool isVerified;
  final String? submittedAt;
  final String? email;
  final List<RecruiterTeamMember> teamMembers;
  final RecruiterNotificationPreferences notificationPreferences;
  final bool isMock;

  const RecruiterSettingsModel({
    required this.repName,
    required this.companyName,
    required this.websiteUrl,
    required this.aboutCompany,
    this.logoUrl,
    this.verificationStatus = 'UNFILLED',
    this.isVerified = false,
    this.submittedAt,
    this.email,
    this.teamMembers = const [],
    this.notificationPreferences = const RecruiterNotificationPreferences(),
    this.isMock = false,
  });

  factory RecruiterSettingsModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final status = (json['verificationStatus']?.toString() ?? 'UNFILLED').toUpperCase();
    final verified = json['isVerified'] == true || status == 'VERIFIED';

    final membersJson = json['teamMembers'] as List<dynamic>? ?? [];
    final members = membersJson
        .map((e) => RecruiterTeamMember.fromJson(e as Map<String, dynamic>))
        .toList();

    return RecruiterSettingsModel(
      repName: json['repName']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      websiteUrl: json['websiteUrl']?.toString() ?? '',
      aboutCompany: json['aboutCompany']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      verificationStatus: status,
      isVerified: verified,
      submittedAt: json['submittedAt']?.toString(),
      email: json['email']?.toString(),
      teamMembers: members.isNotEmpty
          ? members
          : [
              RecruiterTeamMember(
                id: 'owner-1',
                name: json['repName']?.toString() ?? 'Alexander Wright',
                email: json['email']?.toString() ?? 'alexander@luminanexus.com',
                role: 'Account Owner / Admin',
                initials: 'AW',
              )
            ],
      notificationPreferences: json['notificationPreferences'] != null
          ? RecruiterNotificationPreferences.fromJson(
              json['notificationPreferences'] as Map<String, dynamic>)
          : const RecruiterNotificationPreferences(),
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'repName': repName,
        'companyName': companyName,
        'websiteUrl': websiteUrl,
        'aboutCompany': aboutCompany,
        'logoUrl': logoUrl,
        'verificationStatus': verificationStatus,
        'isVerified': isVerified,
        'submittedAt': submittedAt,
        'email': email,
        'teamMembers': teamMembers.map((e) => e.toJson()).toList(),
        'notificationPreferences': notificationPreferences.toJson(),
        'isMock': isMock,
      };

  RecruiterSettingsModel copyWith({
    String? repName,
    String? companyName,
    String? websiteUrl,
    String? aboutCompany,
    String? logoUrl,
    String? verificationStatus,
    bool? isVerified,
    String? submittedAt,
    String? email,
    List<RecruiterTeamMember>? teamMembers,
    RecruiterNotificationPreferences? notificationPreferences,
    bool? isMock,
  }) {
    return RecruiterSettingsModel(
      repName: repName ?? this.repName,
      companyName: companyName ?? this.companyName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      aboutCompany: aboutCompany ?? this.aboutCompany,
      logoUrl: logoUrl ?? this.logoUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isVerified: isVerified ?? this.isVerified,
      submittedAt: submittedAt ?? this.submittedAt,
      email: email ?? this.email,
      teamMembers: teamMembers ?? this.teamMembers,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      isMock: isMock ?? this.isMock,
    );
  }
}
