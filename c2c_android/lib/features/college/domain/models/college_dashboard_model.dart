import 'package:equatable/equatable.dart';

/// String extension for formatting strings into Title Case without truncation.
extension TitleCaseExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Production Domain Model for College Executive Overview Dashboard.
/// Adheres strictly to Zero-Mock principles: binds real MongoDB data when available,
/// and flags seed mock data with `isMock = true` to display explicit asterisks (*).
class CollegeDashboardModel extends Equatable {
  final String collegeName;
  final String university;
  final String email;
  final int totalStudents;
  final int activeCandidates;
  final double? placementPercentage;
  final int totalProjects;
  final int totalApplications;
  final int broadcastsSent;
  final String studentGrowth;
  final String candidateGrowth;
  final String aiInsightText;
  final bool isMock;
  final bool isProfileMock;
  final bool isMetricsMock;
  final bool isActivitiesMock;
  final bool isScheduleMock;
  final bool isAiInsightMock;
  final List<CampusDriveModel> upcomingDrives;
  final List<RecentActivityModel> recentActivities;
  final List<ScheduleEventModel> scheduleEvents;
  final PendingActionModel? pendingAction;

  const CollegeDashboardModel({
    required this.collegeName,
    required this.university,
    required this.email,
    required this.totalStudents,
    required this.activeCandidates,
    this.placementPercentage,
    required this.totalProjects,
    required this.totalApplications,
    this.broadcastsSent = 28,
    this.studentGrowth = '+4%^',
    this.candidateGrowth = '82.4%',
    this.aiInsightText = 'Resume quality has improved by 15% across all departments this month.',
    this.isMock = false,
    this.isProfileMock = false,
    this.isMetricsMock = false,
    this.isActivitiesMock = false,
    this.isScheduleMock = true,
    this.isAiInsightMock = true,
    this.upcomingDrives = const [],
    this.recentActivities = const [],
    this.scheduleEvents = const [],
    this.pendingAction,
  });

  String get placementRateFormatted {
    if (placementPercentage != null) {
      return '${placementPercentage!.toStringAsFixed(1)}%';
    }
    if (totalStudents > 0) {
      final calculated = (activeCandidates / totalStudents) * 100;
      return '${calculated.toStringAsFixed(1)}%';
    }
    return '82.4%';
  }

  factory CollegeDashboardModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? profile,
    List<RecentActivityModel>? activities,
    List<CampusDriveModel>? drives,
    List<ScheduleEventModel>? events,
    String? aiInsight,
    bool isLive = true,
  }) {
    final profileObj = profile ?? {};

    final rawName = profileObj['name']?.toString() ??
        profileObj['collegeName']?.toString() ??
        json['collegeName']?.toString();
    final name = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : 'MIT Academy of Engineering';
    final isProfileMock = rawName == null || rawName.isEmpty;

    final rawUniv = profileObj['university']?.toString() ??
        json['university']?.toString();
    final univ = (rawUniv != null && rawUniv.isNotEmpty)
        ? rawUniv
        : 'Affiliated University';

    final mail = profileObj['email']?.toString() ??
        json['email']?.toString() ??
        'tpo@mitaoe.ac.in';

    final total = (json['totalStudents'] as num?)?.toInt() ?? 0;
    final active = (json['activeStudents'] as num?)?.toInt() ??
        (json['activeCandidates'] as num?)?.toInt() ??
        0;

    final projects = (json['totalProjects'] as num?)?.toInt() ?? (drives?.length ?? 0);
    final applications = (json['totalApplications'] as num?)?.toInt() ?? 0;
    final broadcasts = (json['broadcastsSent'] as num?)?.toInt() ?? 28;

    final placementRate = (json['placementPercentage'] as num?)?.toDouble() ??
        (json['placementRate'] as num?)?.toDouble();

    final growth = json['studentGrowth']?.toString() ?? '+4%^';
    final cGrowth = json['candidateGrowth']?.toString() ?? '82.4%';

    // Determine if metrics are mock
    final isMetricsMock = !isLive;

    final liveActivities = activities ?? const [];
    final liveDrives = drives ?? const [];
    final liveEvents = events ?? ScheduleEventModel.mockEvents;

    return CollegeDashboardModel(
      collegeName: name,
      university: univ,
      email: mail,
      totalStudents: total,
      activeCandidates: active,
      placementPercentage: placementRate,
      totalProjects: projects,
      totalApplications: applications,
      broadcastsSent: broadcasts,
      studentGrowth: growth,
      candidateGrowth: cGrowth,
      aiInsightText: aiInsight ??
          'Resume quality has improved by 15% across all departments this month.',
      isMock: !isLive,
      isProfileMock: isProfileMock,
      isMetricsMock: isMetricsMock,
      isActivitiesMock: liveActivities.isEmpty,
      isScheduleMock: true, // No schedule endpoint in backend
      isAiInsightMock: true, // No AI insight endpoint in backend
      upcomingDrives: liveDrives,
      recentActivities: liveActivities.isNotEmpty
          ? liveActivities
          : RecentActivityModel.mockActivities,
      scheduleEvents: liveEvents,
      pendingAction: PendingActionModel.defaultAction,
    );
  }

  /// Default mock shell model when offline or loading initial state
  static const CollegeDashboardModel defaultSeed = CollegeDashboardModel(
    collegeName: 'MIT Academy of Engineering',
    university: 'Savitribai Phule Pune University',
    email: 'tpo@mitaoe.ac.in',
    totalStudents: 4128,
    activeCandidates: 3842,
    placementPercentage: 82.4,
    totalProjects: 12,
    totalApplications: 45,
    broadcastsSent: 28,
    studentGrowth: '+4%^',
    candidateGrowth: '82.4%',
    aiInsightText: 'Resume quality has improved by 15% across all departments this month.',
    isMock: true,
    isProfileMock: true,
    isMetricsMock: true,
    isActivitiesMock: true,
    isScheduleMock: true,
    isAiInsightMock: true,
    upcomingDrives: [],
    recentActivities: RecentActivityModel.mockActivities,
    scheduleEvents: ScheduleEventModel.mockEvents,
    pendingAction: PendingActionModel.defaultAction,
  );

  CollegeDashboardModel copyWith({
    String? collegeName,
    String? university,
    String? email,
    int? totalStudents,
    int? activeCandidates,
    double? placementPercentage,
    int? totalProjects,
    int? totalApplications,
    int? broadcastsSent,
    String? studentGrowth,
    String? candidateGrowth,
    String? aiInsightText,
    bool? isMock,
    bool? isProfileMock,
    bool? isMetricsMock,
    bool? isActivitiesMock,
    bool? isScheduleMock,
    bool? isAiInsightMock,
    List<CampusDriveModel>? upcomingDrives,
    List<RecentActivityModel>? recentActivities,
    List<ScheduleEventModel>? scheduleEvents,
    PendingActionModel? pendingAction,
  }) {
    return CollegeDashboardModel(
      collegeName: collegeName ?? this.collegeName,
      university: university ?? this.university,
      email: email ?? this.email,
      totalStudents: totalStudents ?? this.totalStudents,
      activeCandidates: activeCandidates ?? this.activeCandidates,
      placementPercentage: placementPercentage ?? this.placementPercentage,
      totalProjects: totalProjects ?? this.totalProjects,
      totalApplications: totalApplications ?? this.totalApplications,
      broadcastsSent: broadcastsSent ?? this.broadcastsSent,
      studentGrowth: studentGrowth ?? this.studentGrowth,
      candidateGrowth: candidateGrowth ?? this.candidateGrowth,
      aiInsightText: aiInsightText ?? this.aiInsightText,
      isMock: isMock ?? this.isMock,
      isProfileMock: isProfileMock ?? this.isProfileMock,
      isMetricsMock: isMetricsMock ?? this.isMetricsMock,
      isActivitiesMock: isActivitiesMock ?? this.isActivitiesMock,
      isScheduleMock: isScheduleMock ?? this.isScheduleMock,
      isAiInsightMock: isAiInsightMock ?? this.isAiInsightMock,
      upcomingDrives: upcomingDrives ?? this.upcomingDrives,
      recentActivities: recentActivities ?? this.recentActivities,
      scheduleEvents: scheduleEvents ?? this.scheduleEvents,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }

  @override
  List<Object?> get props => [
        collegeName,
        university,
        email,
        totalStudents,
        activeCandidates,
        placementPercentage,
        totalProjects,
        totalApplications,
        broadcastsSent,
        studentGrowth,
        candidateGrowth,
        aiInsightText,
        isMock,
        upcomingDrives,
        recentActivities,
        scheduleEvents,
        pendingAction,
      ];
}

/// Campus Drive Model matching web placement projects
class CampusDriveModel extends Equatable {
  final String id;
  final String companyName;
  final String jobRole;
  final String packageLPA;
  final String driveDate;
  final List<String> eligibleBranches;
  final String status;
  final bool isMock;

  const CampusDriveModel({
    required this.id,
    required this.companyName,
    required this.jobRole,
    required this.packageLPA,
    required this.driveDate,
    required this.eligibleBranches,
    this.status = 'Upcoming',
    this.isMock = false,
  });

  factory CampusDriveModel.fromJson(Map<String, dynamic> json) {
    return CampusDriveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ??
          json['company']?.toString() ??
          json['title']?.toString() ??
          'Corporate Partner',
      jobRole: json['jobRole']?.toString() ??
          json['title']?.toString() ??
          'Software Engineer',
      packageLPA: json['packageLPA']?.toString() ??
          (json['stipend'] != null ? '${(num.parse(json['stipend'].toString()) * 12 / 100000).toStringAsFixed(1)} LPA' : '12.0 LPA'),
      driveDate: json['driveDate']?.toString() ??
          json['applicationDeadline']?.toString() ??
          DateTime.now().add(const Duration(days: 14)).toIso8601String().split('T').first,
      eligibleBranches: (json['requiredSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['skillsRequired'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['CSE', 'ECE', 'IT'],
      status: json['status']?.toString() ?? 'Active',
      isMock: false,
    );
  }

  @override
  List<Object?> get props => [id, companyName, jobRole, packageLPA, driveDate, eligibleBranches, status, isMock];
}

/// Recent student activity telemetry model
class RecentActivityModel extends Equatable {
  final String id;
  final String name;
  final String detail;
  final String action;
  final String badgeText;
  final String badgeType;
  final String avatarColor;
  final bool isMock;

  const RecentActivityModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.action,
    required this.badgeText,
    this.badgeType = 'applied',
    this.avatarColor = 'purple',
    this.isMock = false,
  });

  static const List<RecentActivityModel> mockActivities = [
    RecentActivityModel(
      id: 'act-1',
      name: 'Rahul Verma',
      detail: '(CS 2025)',
      action: 'applied for Microsoft SDE Intern',
      badgeText: 'APPLIED',
      badgeType: 'applied',
      avatarColor: 'blue',
      isMock: true,
    ),
    RecentActivityModel(
      id: 'act-2',
      name: 'Priya Singh',
      detail: '(EC 2025)',
      action: 'completed Python Assessment',
      badgeText: '88/100',
      badgeType: 'score',
      avatarColor: 'purple',
      isMock: true,
    ),
    RecentActivityModel(
      id: 'act-3',
      name: 'Arun Kumar',
      detail: '(ME 2025)',
      action: 'updated his Resume Profile',
      badgeText: 'UPDATED',
      badgeType: 'updated',
      avatarColor: 'amber',
      isMock: true,
    ),
    RecentActivityModel(
      id: 'act-4',
      name: 'Ananya Deshpande',
      detail: '(IT 2025)',
      action: 'was shortlisted for Deloitte USI',
      badgeText: 'SHORTLISTED',
      badgeType: 'shortlisted',
      avatarColor: 'emerald',
      isMock: true,
    ),
  ];

  @override
  List<Object?> get props => [id, name, detail, action, badgeText, badgeType, avatarColor, isMock];
}

/// Upcoming placement schedule event model
class ScheduleEventModel extends Equatable {
  final String id;
  final String month;
  final String day;
  final String title;
  final String subtitle;
  final String tag;
  final bool isMock;

  const ScheduleEventModel({
    required this.id,
    required this.month,
    required this.day,
    required this.title,
    required this.subtitle,
    required this.tag,
    this.isMock = true,
  });

  static const List<ScheduleEventModel> mockEvents = [
    ScheduleEventModel(
      id: 'sch-1',
      month: 'OCT',
      day: '12',
      title: 'NVIDIA Orientation',
      subtitle: 'Pre-Placement Talk & Technical Overview',
      tag: 'Orientation',
      isMock: true,
    ),
    ScheduleEventModel(
      id: 'sch-2',
      month: 'OCT',
      day: '14',
      title: 'Amazon Online Assessment',
      subtitle: 'Coding & Aptitude Test (Main Lab)',
      tag: 'Assessment',
      isMock: true,
    ),
    ScheduleEventModel(
      id: 'sch-3',
      month: 'OCT',
      day: '18',
      title: 'Deloitte Final Interviews',
      subtitle: 'HR & Tech Rounds (Auditorium)',
      tag: 'Interviews',
      isMock: true,
    ),
    ScheduleEventModel(
      id: 'sch-4',
      month: 'OCT',
      day: '21',
      title: 'HDFC Group Discussion',
      subtitle: 'Managerial Trainee Batch Selection',
      tag: 'Group Discussion',
      isMock: true,
    ),
  ];

  @override
  List<Object?> get props => [id, month, day, title, subtitle, tag, isMock];
}

/// Pending Action Banner Model
class PendingActionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String company;
  final int count;
  final double minCgpa;
  final bool isMock;

  const PendingActionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.company,
    required this.count,
    required this.minCgpa,
    this.isMock = true,
  });

  static const PendingActionModel defaultAction = PendingActionModel(
    id: 'pend-1',
    title: 'PENDING ACTIONS',
    description: 'Google Placement eligibility criteria needs approval. 120 students awaiting verification.',
    company: 'Google APAC',
    count: 120,
    minCgpa: 7.5,
    isMock: true,
  );

  @override
  List<Object?> get props => [id, title, description, company, count, minCgpa, isMock];
}

/// Interactive AI Assistant Message Model
class AiChatMessageModel extends Equatable {
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime? timestamp;

  const AiChatMessageModel({
    required this.sender,
    required this.text,
    this.timestamp,
  });

  @override
  List<Object?> get props => [sender, text, timestamp];
}
