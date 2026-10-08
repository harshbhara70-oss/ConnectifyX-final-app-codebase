import 'package:equatable/equatable.dart';

/// AI Configuration Readiness Score Weights matching sliders in web SettingsView.tsx
class AdminAiWeightsModel extends Equatable {
  final int academicWeight;
  final int softSkillsWeight;
  final int techProjectsWeight;
  final int extracurricularWeight;
  final bool isMock;

  const AdminAiWeightsModel({
    this.academicWeight = 40,
    this.softSkillsWeight = 30,
    this.techProjectsWeight = 20,
    this.extracurricularWeight = 10,
    this.isMock = false,
  });

  int get totalWeight => academicWeight + softSkillsWeight + techProjectsWeight + extracurricularWeight;

  AdminAiWeightsModel copyWith({
    int? academicWeight,
    int? softSkillsWeight,
    int? techProjectsWeight,
    int? extracurricularWeight,
    bool? isMock,
  }) {
    return AdminAiWeightsModel(
      academicWeight: academicWeight ?? this.academicWeight,
      softSkillsWeight: softSkillsWeight ?? this.softSkillsWeight,
      techProjectsWeight: techProjectsWeight ?? this.techProjectsWeight,
      extracurricularWeight: extracurricularWeight ?? this.extracurricularWeight,
      isMock: isMock ?? this.isMock,
    );
  }

  factory AdminAiWeightsModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminAiWeightsModel(
      academicWeight: (json['academicWeight'] as num?)?.toInt() ?? 40,
      softSkillsWeight: (json['softSkillsWeight'] as num?)?.toInt() ?? 30,
      techProjectsWeight: (json['techProjectsWeight'] as num?)?.toInt() ?? 20,
      extracurricularWeight: (json['extracurricularWeight'] as num?)?.toInt() ?? 10,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicWeight': academicWeight,
      'softSkillsWeight': softSkillsWeight,
      'techProjectsWeight': techProjectsWeight,
      'extracurricularWeight': extracurricularWeight,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        academicWeight,
        softSkillsWeight,
        techProjectsWeight,
        extracurricularWeight,
        isMock,
      ];
}

/// Third-party API Integration model matching web SettingsView.tsx
class AdminIntegrationModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status; // 'Connected' or 'Configure'
  final String iconType; // 'share', 'video', 'code'
  final bool isConnected;
  final bool isMock;

  const AdminIntegrationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.iconType,
    this.isConnected = true,
    this.isMock = false,
  });

  AdminIntegrationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    String? iconType,
    bool? isConnected,
    bool? isMock,
  }) {
    return AdminIntegrationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      iconType: iconType ?? this.iconType,
      isConnected: isConnected ?? this.isConnected,
      isMock: isMock ?? this.isMock,
    );
  }

  factory AdminIntegrationModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminIntegrationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Connected',
      iconType: json['iconType']?.toString() ?? 'share',
      isConnected: json['isConnected'] == true || json['status'] == 'Connected',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'iconType': iconType,
      'isConnected': isConnected,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        iconType,
        isConnected,
        isMock,
      ];
}

/// Security Audit Log entry matching web SettingsView.tsx table
class AdminSecurityAuditModel extends Equatable {
  final String timestamp;
  final String event;
  final String user;
  final String ip;
  final String status; // 'Success', 'Blocked', 'Warning'
  final bool isMock;

  const AdminSecurityAuditModel({
    required this.timestamp,
    required this.event,
    required this.user,
    required this.ip,
    required this.status,
    this.isMock = false,
  });

  factory AdminSecurityAuditModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminSecurityAuditModel(
      timestamp: json['timestamp']?.toString() ?? json['time']?.toString() ?? '',
      event: json['event']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Success',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'event': event,
      'user': user,
      'ip': ip,
      'status': status,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [timestamp, event, user, ip, status, isMock];
}

/// General & User Policies Configuration model
class AdminGeneralSettingsModel extends Equatable {
  final String platformName;
  final String supportEmail;
  final int sessionTimeoutMinutes;
  final bool autoApproveColleges;
  final bool mandatory2fa;
  final int maxResumeSizeMb;
  final String emailDigest;
  final bool systemAlertWebhooks;
  final bool isMock;

  const AdminGeneralSettingsModel({
    this.platformName = 'Campus2Corporate',
    this.supportEmail = 'admin@campus2corporate.com',
    this.sessionTimeoutMinutes = 30,
    this.autoApproveColleges = false,
    this.mandatory2fa = true,
    this.maxResumeSizeMb = 10,
    this.emailDigest = 'Daily',
    this.systemAlertWebhooks = true,
    this.isMock = false,
  });

  AdminGeneralSettingsModel copyWith({
    String? platformName,
    String? supportEmail,
    int? sessionTimeoutMinutes,
    bool? autoApproveColleges,
    bool? mandatory2fa,
    int? maxResumeSizeMb,
    String? emailDigest,
    bool? systemAlertWebhooks,
    bool? isMock,
  }) {
    return AdminGeneralSettingsModel(
      platformName: platformName ?? this.platformName,
      supportEmail: supportEmail ?? this.supportEmail,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      autoApproveColleges: autoApproveColleges ?? this.autoApproveColleges,
      mandatory2fa: mandatory2fa ?? this.mandatory2fa,
      maxResumeSizeMb: maxResumeSizeMb ?? this.maxResumeSizeMb,
      emailDigest: emailDigest ?? this.emailDigest,
      systemAlertWebhooks: systemAlertWebhooks ?? this.systemAlertWebhooks,
      isMock: isMock ?? this.isMock,
    );
  }

  factory AdminGeneralSettingsModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminGeneralSettingsModel(
      platformName: json['platformName']?.toString() ?? 'Campus2Corporate',
      supportEmail: json['supportEmail']?.toString() ?? 'admin@campus2corporate.com',
      sessionTimeoutMinutes: (json['sessionTimeoutMinutes'] as num?)?.toInt() ?? 30,
      autoApproveColleges: json['autoApproveColleges'] == true,
      mandatory2fa: json['mandatory2fa'] != false,
      maxResumeSizeMb: (json['maxResumeSizeMb'] as num?)?.toInt() ?? 10,
      emailDigest: json['emailDigest']?.toString() ?? 'Daily',
      systemAlertWebhooks: json['systemAlertWebhooks'] != false,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platformName': platformName,
      'supportEmail': supportEmail,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'autoApproveColleges': autoApproveColleges,
      'mandatory2fa': mandatory2fa,
      'maxResumeSizeMb': maxResumeSizeMb,
      'emailDigest': emailDigest,
      'systemAlertWebhooks': systemAlertWebhooks,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        platformName,
        supportEmail,
        sessionTimeoutMinutes,
        autoApproveColleges,
        mandatory2fa,
        maxResumeSizeMb,
        emailDigest,
        systemAlertWebhooks,
        isMock,
      ];
}

/// Aggregate DTO for Admin Platform Settings
class AdminSettingsDto extends Equatable {
  final AdminAiWeightsModel aiWeights;
  final List<AdminIntegrationModel> integrations;
  final List<AdminSecurityAuditModel> auditLogs;
  final AdminGeneralSettingsModel general;
  final bool maintenanceEnabled;
  final bool isMock;

  const AdminSettingsDto({
    required this.aiWeights,
    required this.integrations,
    required this.auditLogs,
    required this.general,
    this.maintenanceEnabled = false,
    this.isMock = false,
  });

  AdminSettingsDto copyWith({
    AdminAiWeightsModel? aiWeights,
    List<AdminIntegrationModel>? integrations,
    List<AdminSecurityAuditModel>? auditLogs,
    AdminGeneralSettingsModel? general,
    bool? maintenanceEnabled,
    bool? isMock,
  }) {
    return AdminSettingsDto(
      aiWeights: aiWeights ?? this.aiWeights,
      integrations: integrations ?? this.integrations,
      auditLogs: auditLogs ?? this.auditLogs,
      general: general ?? this.general,
      maintenanceEnabled: maintenanceEnabled ?? this.maintenanceEnabled,
      isMock: isMock ?? this.isMock,
    );
  }

  factory AdminSettingsDto.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawIntegrations = json['integrations'] as List<dynamic>? ?? [];
    final rawLogs = json['auditLogs'] as List<dynamic>? ?? [];

    return AdminSettingsDto(
      aiWeights: json['aiWeights'] != null
          ? AdminAiWeightsModel.fromJson(json['aiWeights'] as Map<String, dynamic>, isMock: isMock)
          : AdminAiWeightsModel(isMock: isMock),
      integrations: rawIntegrations
          .map((i) => AdminIntegrationModel.fromJson(i as Map<String, dynamic>, isMock: isMock))
          .toList(),
      auditLogs: rawLogs
          .map((l) => AdminSecurityAuditModel.fromJson(l as Map<String, dynamic>, isMock: isMock))
          .toList(),
      general: json['general'] != null
          ? AdminGeneralSettingsModel.fromJson(json['general'] as Map<String, dynamic>, isMock: isMock)
          : AdminGeneralSettingsModel(isMock: isMock),
      maintenanceEnabled: json['maintenanceEnabled'] == true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aiWeights': aiWeights.toJson(),
      'integrations': integrations.map((i) => i.toJson()).toList(),
      'auditLogs': auditLogs.map((l) => l.toJson()).toList(),
      'general': general.toJson(),
      'maintenanceEnabled': maintenanceEnabled,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        aiWeights,
        integrations,
        auditLogs,
        general,
        maintenanceEnabled,
        isMock,
      ];
}
