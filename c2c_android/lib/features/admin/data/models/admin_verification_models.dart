import 'package:equatable/equatable.dart';

/// Model representing a Verification Queue card (College, Recruiter, or Flagged Content)
class AdminVerificationCardModel extends Equatable {
  final String id;
  final String title;
  final String category; // 'colleges', 'recruiters', 'flagged'
  final String priority; // 'HIGH PRIORITY' or ''
  final String submitted;
  final bool domainMatch;
  final bool accreditationDoc;
  final bool taxIdVerified;
  final String linkedinStatus;
  final bool linkedinOk;
  final String domainUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final bool flaggedByAi;
  final bool isMock;

  const AdminVerificationCardModel({
    required this.id,
    required this.title,
    required this.category,
    this.priority = '',
    required this.submitted,
    this.domainMatch = false,
    this.accreditationDoc = false,
    this.taxIdVerified = false,
    required this.linkedinStatus,
    this.linkedinOk = false,
    required this.domainUrl,
    this.status = 'pending',
    this.flaggedByAi = false,
    this.isMock = false,
  });

  factory AdminVerificationCardModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminVerificationCardModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'v_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Institution',
      category: json['category']?.toString() ?? 'colleges',
      priority: json['priority']?.toString() ?? '',
      submitted: json['submitted']?.toString() ?? 'Submitted recently',
      domainMatch: json['domainMatch'] == true,
      accreditationDoc: json['accreditationDoc'] == true,
      taxIdVerified: json['taxIdVerified'] == true,
      linkedinStatus: json['linkedinStatus']?.toString() ?? 'Unverified',
      linkedinOk: json['linkedinOk'] == true,
      domainUrl: json['domainUrl']?.toString() ?? 'domain.edu',
      status: json['status']?.toString() ?? 'pending',
      flaggedByAi: json['flaggedByAi'] == true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'priority': priority,
    'submitted': submitted,
    'domainMatch': domainMatch,
    'accreditationDoc': accreditationDoc,
    'taxIdVerified': taxIdVerified,
    'linkedinStatus': linkedinStatus,
    'linkedinOk': linkedinOk,
    'domainUrl': domainUrl,
    'status': status,
    'flaggedByAi': flaggedByAi,
    'isMock': isMock,
  };

  AdminVerificationCardModel copyWith({
    String? id,
    String? title,
    String? category,
    String? priority,
    String? submitted,
    bool? domainMatch,
    bool? accreditationDoc,
    bool? taxIdVerified,
    String? linkedinStatus,
    bool? linkedinOk,
    String? domainUrl,
    String? status,
    bool? flaggedByAi,
    bool? isMock,
  }) {
    return AdminVerificationCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      submitted: submitted ?? this.submitted,
      domainMatch: domainMatch ?? this.domainMatch,
      accreditationDoc: accreditationDoc ?? this.accreditationDoc,
      taxIdVerified: taxIdVerified ?? this.taxIdVerified,
      linkedinStatus: linkedinStatus ?? this.linkedinStatus,
      linkedinOk: linkedinOk ?? this.linkedinOk,
      domainUrl: domainUrl ?? this.domainUrl,
      status: status ?? this.status,
      flaggedByAi: flaggedByAi ?? this.flaggedByAi,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    priority,
    submitted,
    domainMatch,
    accreditationDoc,
    taxIdVerified,
    linkedinStatus,
    linkedinOk,
    domainUrl,
    status,
    flaggedByAi,
    isMock,
  ];
}

/// DTO for Queue Status Statistics widget
class AdminQueueStatusDto extends Equatable {
  final int highPriority;
  final int standard;
  final String avgWaitTime;
  final bool isMock;

  const AdminQueueStatusDto({
    this.highPriority = 5,
    this.standard = 7,
    this.avgWaitTime = '2.4 hrs',
    this.isMock = false,
  });

  factory AdminQueueStatusDto.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminQueueStatusDto(
      highPriority: (json['highPriority'] ?? 5) as int,
      standard: (json['standard'] ?? 7) as int,
      avgWaitTime: json['avgWaitTime']?.toString() ?? '2.4 hrs',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'highPriority': highPriority,
    'standard': standard,
    'avgWaitTime': avgWaitTime,
    'isMock': isMock,
  };

  @override
  List<Object?> get props => [highPriority, standard, avgWaitTime, isMock];
}

/// Filter state for Auto-Check Checkboxes
class AdminAutoCheckFilterDto extends Equatable {
  final bool domainVerifiedOnly;
  final bool docsProvidedOnly;
  final bool flaggedByAiOnly;

  const AdminAutoCheckFilterDto({
    this.domainVerifiedOnly = true,
    this.docsProvidedOnly = true,
    this.flaggedByAiOnly = false,
  });

  AdminAutoCheckFilterDto copyWith({
    bool? domainVerifiedOnly,
    bool? docsProvidedOnly,
    bool? flaggedByAiOnly,
  }) {
    return AdminAutoCheckFilterDto(
      domainVerifiedOnly: domainVerifiedOnly ?? this.domainVerifiedOnly,
      docsProvidedOnly: docsProvidedOnly ?? this.docsProvidedOnly,
      flaggedByAiOnly: flaggedByAiOnly ?? this.flaggedByAiOnly,
    );
  }

  @override
  List<Object?> get props => [domainVerifiedOnly, docsProvidedOnly, flaggedByAiOnly];
}
