import 'package:equatable/equatable.dart';

/// DTO for Admin Dashboard Analytics
class AdminAnalyticsDto extends Equatable {
  final int totalStudents;
  final int totalColleges;
  final int totalRecruiters;
  final int totalCompanies;
  final int totalProjects;
  final int totalApplications;
  final int activeProjects;
  final String studentsGrowth;
  final String recruitersGrowth;
  final String roadmapsDone;
  final String mrrRevenue;
  final bool isMock;

  const AdminAnalyticsDto({
    this.totalStudents = 0,
    this.totalColleges = 0,
    this.totalRecruiters = 0,
    this.totalCompanies = 0,
    this.totalProjects = 0,
    this.totalApplications = 0,
    this.activeProjects = 0,
    this.studentsGrowth = '+12% this month',
    this.recruitersGrowth = '+5% this week',
    this.roadmapsDone = '45.2k',
    this.mrrRevenue = '\$2.4M',
    this.isMock = false,
  });

  factory AdminAnalyticsDto.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    final fallbackVal = isMock ? 142500 : 0;
    return AdminAnalyticsDto(
      totalStudents: _parseInt(json['totalStudents'], fallbackVal),
      totalColleges: _parseInt(json['totalColleges'], isMock ? 342 : 0),
      totalRecruiters: _parseInt(json['totalRecruiters'], isMock ? 1284 : 0),
      totalCompanies: _parseInt(json['totalCompanies'], isMock ? 450 : 0),
      totalProjects: _parseInt(json['totalProjects'], isMock ? 8492 : 0),
      totalApplications: _parseInt(json['totalApplications'], isMock ? 34200 : 0),
      activeProjects: _parseInt(json['activeProjects'], isMock ? 8492 : 0),
      studentsGrowth: json['studentsGrowth']?.toString() ?? '+12% this month',
      recruitersGrowth: json['recruitersGrowth']?.toString() ?? '+5% this week',
      roadmapsDone: json['roadmapsDone']?.toString() ?? '45.2k',
      mrrRevenue: json['mrrRevenue']?.toString() ?? '\$2.4M',
      isMock: isMock,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalColleges': totalColleges,
      'totalRecruiters': totalRecruiters,
      'totalCompanies': totalCompanies,
      'totalProjects': totalProjects,
      'totalApplications': totalApplications,
      'activeProjects': activeProjects,
      'studentsGrowth': studentsGrowth,
      'recruitersGrowth': recruitersGrowth,
      'roadmapsDone': roadmapsDone,
      'mrrRevenue': mrrRevenue,
      'isMock': isMock,
    };
  }

  AdminAnalyticsDto copyWith({
    int? totalStudents,
    int? totalColleges,
    int? totalRecruiters,
    int? totalCompanies,
    int? totalProjects,
    int? totalApplications,
    int? activeProjects,
    String? studentsGrowth,
    String? recruitersGrowth,
    String? roadmapsDone,
    String? mrrRevenue,
    bool? isMock,
  }) {
    return AdminAnalyticsDto(
      totalStudents: totalStudents ?? this.totalStudents,
      totalColleges: totalColleges ?? this.totalColleges,
      totalRecruiters: totalRecruiters ?? this.totalRecruiters,
      totalCompanies: totalCompanies ?? this.totalCompanies,
      totalProjects: totalProjects ?? this.totalProjects,
      totalApplications: totalApplications ?? this.totalApplications,
      activeProjects: activeProjects ?? this.activeProjects,
      studentsGrowth: studentsGrowth ?? this.studentsGrowth,
      recruitersGrowth: recruitersGrowth ?? this.recruitersGrowth,
      roadmapsDone: roadmapsDone ?? this.roadmapsDone,
      mrrRevenue: mrrRevenue ?? this.mrrRevenue,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        totalStudents,
        totalColleges,
        totalRecruiters,
        totalCompanies,
        totalProjects,
        totalApplications,
        activeProjects,
        studentsGrowth,
        recruitersGrowth,
        roadmapsDone,
        mrrRevenue,
        isMock,
      ];
}

/// DTO for Pending Approvals Count Box
class PendingApprovalsDto extends Equatable {
  final int collegePending;
  final int recruiterUrgent;
  final int broadcastDrafts;
  final bool isMock;

  const PendingApprovalsDto({
    this.collegePending = 12,
    this.recruiterUrgent = 5,
    this.broadcastDrafts = 2,
    this.isMock = false,
  });

  factory PendingApprovalsDto.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return PendingApprovalsDto(
      collegePending: json['collegePending'] as int? ?? 12,
      recruiterUrgent: json['recruiterUrgent'] as int? ?? 5,
      broadcastDrafts: json['broadcastDrafts'] as int? ?? 2,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collegePending': collegePending,
      'recruiterUrgent': recruiterUrgent,
      'broadcastDrafts': broadcastDrafts,
      'isMock': isMock,
    };
  }

  PendingApprovalsDto copyWith({
    int? collegePending,
    int? recruiterUrgent,
    int? broadcastDrafts,
    bool? isMock,
  }) {
    return PendingApprovalsDto(
      collegePending: collegePending ?? this.collegePending,
      recruiterUrgent: recruiterUrgent ?? this.recruiterUrgent,
      broadcastDrafts: broadcastDrafts ?? this.broadcastDrafts,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        collegePending,
        recruiterUrgent,
        broadcastDrafts,
        isMock,
      ];
}

/// DTO for Live Activity Stream Item
class AdminActivityLogDto extends Equatable {
  final String id;
  final String message;
  final String timeAgo;
  final String iconType; // 'student', 'recruiter', 'warning', 'check'
  final bool isMock;

  const AdminActivityLogDto({
    required this.id,
    required this.message,
    required this.timeAgo,
    required this.iconType,
    this.isMock = false,
  });

  factory AdminActivityLogDto.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return AdminActivityLogDto(
      id: json['id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timeAgo: json['timeAgo']?.toString() ?? '',
      iconType: json['iconType']?.toString() ?? 'student',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timeAgo': timeAgo,
      'iconType': iconType,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [id, message, timeAgo, iconType, isMock];
}

/// DTO for 30-Day Traffic Overview Point
class TrafficDataPointDto extends Equatable {
  final String label;
  final double value;
  final String pointStr;
  final String displayVal;
  final bool isMock;

  const TrafficDataPointDto({
    required this.label,
    required this.value,
    required this.pointStr,
    required this.displayVal,
    this.isMock = false,
  });

  factory TrafficDataPointDto.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return TrafficDataPointDto(
      label: json['label']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      pointStr: json['pointStr']?.toString() ?? '',
      displayVal: json['displayVal']?.toString() ?? '',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'pointStr': pointStr,
      'displayVal': displayVal,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [label, value, pointStr, displayVal, isMock];
}

/// DTO for System Diagnostic Cluster Items
class SystemDiagnosticItemDto extends Equatable {
  final String title;
  final String statusText;
  final bool isOperational;
  final String latency;
  final String iconType; // 'wifi', 'activity', 'shield'
  final bool isMock;

  const SystemDiagnosticItemDto({
    required this.title,
    required this.statusText,
    required this.isOperational,
    required this.latency,
    required this.iconType,
    this.isMock = false,
  });

  @override
  List<Object?> get props => [
        title,
        statusText,
        isOperational,
        latency,
        iconType,
        isMock,
      ];
}
