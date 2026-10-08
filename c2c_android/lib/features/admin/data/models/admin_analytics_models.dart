import 'package:equatable/equatable.dart';

/// DTO for Admin Platform Analytics Main Response
class AdminPlatformAnalyticsDto extends Equatable {
  final int totalActiveUsers;
  final String activeUsersGrowth;
  final String avgSessionDuration;
  final String sessionDurationGrowth;
  final String systemHealth;
  final String systemHealthStatus;
  final bool isSystemHealthy;
  final List<GrowthTrajectoryPoint> growthTrajectory;
  final EngagementMetricsDto engagement;
  final List<PlacementFunnelStage> placementFunnel;
  final List<ContentRoadmapMetric> contentRoadmaps;
  final String selectedDateRange;
  final bool isMock;
  final bool isLiveAtlasConnected;

  const AdminPlatformAnalyticsDto({
    this.totalActiveUsers = 124592,
    this.activeUsersGrowth = '+14.2% from last month',
    this.avgSessionDuration = '18m 42s',
    this.sessionDurationGrowth = '+2.1% from last month',
    this.systemHealth = '99.98%',
    this.systemHealthStatus = 'All services operational',
    this.isSystemHealthy = true,
    this.growthTrajectory = const [],
    this.engagement = const EngagementMetricsDto(),
    this.placementFunnel = const [],
    this.contentRoadmaps = const [],
    this.selectedDateRange = '30_days',
    this.isMock = false,
    this.isLiveAtlasConnected = false,
  });

  factory AdminPlatformAnalyticsDto.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
    bool isLiveAtlasConnected = false,
    String dateRange = '30_days',
  }) {
    final trajectoryJson = json['growthTrajectory'] as List<dynamic>?;
    final trajectory = trajectoryJson != null
        ? trajectoryJson
            .map((e) => GrowthTrajectoryPoint.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : _defaultGrowthTrajectory();

    final engagementJson = json['engagement'];
    final engagement = engagementJson is Map<String, dynamic>
        ? EngagementMetricsDto.fromJson(engagementJson)
        : (engagementJson is Map
            ? EngagementMetricsDto.fromJson(
                Map<String, dynamic>.from(engagementJson))
            : const EngagementMetricsDto());

    final funnelJson = json['placementFunnel'] as List<dynamic>?;
    final funnel = funnelJson != null
        ? funnelJson
            .map((e) => PlacementFunnelStage.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : _defaultPlacementFunnel();

    final roadmapsJson = json['contentRoadmaps'] as List<dynamic>?;
    final roadmaps = roadmapsJson != null
        ? roadmapsJson
            .map((e) => ContentRoadmapMetric.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ))
            .toList()
        : _defaultContentRoadmaps();

    return AdminPlatformAnalyticsDto(
      totalActiveUsers: _parseInt(json['totalActiveUsers'], 124592),
      activeUsersGrowth:
          json['activeUsersGrowth']?.toString() ?? '+14.2% from last month',
      avgSessionDuration:
          json['avgSessionDuration']?.toString() ?? '18m 42s',
      sessionDurationGrowth:
          json['sessionDurationGrowth']?.toString() ?? '+2.1% from last month',
      systemHealth: json['systemHealth']?.toString() ?? '99.98%',
      systemHealthStatus: json['systemHealthStatus']?.toString() ??
          'All services operational',
      isSystemHealthy: json['isSystemHealthy'] as bool? ?? true,
      growthTrajectory: trajectory,
      engagement: engagement,
      placementFunnel: funnel,
      contentRoadmaps: roadmaps,
      selectedDateRange: json['selectedDateRange']?.toString() ?? dateRange,
      isMock: isMock,
      isLiveAtlasConnected: isLiveAtlasConnected,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static List<GrowthTrajectoryPoint> _defaultGrowthTrajectory() {
    return const [
      GrowthTrajectoryPoint(week: 'Week 1', label: '18.2k', count: 18200, isMock: true),
      GrowthTrajectoryPoint(week: 'Week 2', label: '24.5k', count: 24500, isMock: true),
      GrowthTrajectoryPoint(week: 'Week 3', label: '31.8k', count: 31800, isMock: true),
      GrowthTrajectoryPoint(week: 'Week 4', label: '42.0k', count: 42000, isMock: true),
    ];
  }

  static List<PlacementFunnelStage> _defaultPlacementFunnel() {
    return const [
      PlacementFunnelStage(
        stage: 'Profile Created',
        shortStage: 'Profile',
        percent: 100,
        count: '45,210',
        colorHex: 0xFF6D28D9,
        isMock: true,
      ),
      PlacementFunnelStage(
        stage: 'Assessment',
        shortStage: 'Assess',
        percent: 78,
        count: '35,263',
        colorHex: 0xFF9333EA,
        isMock: true,
      ),
      PlacementFunnelStage(
        stage: 'Interview',
        shortStage: 'Interview',
        percent: 45,
        count: '20,344',
        colorHex: 0xFFA855F7,
        isMock: true,
      ),
      PlacementFunnelStage(
        stage: 'Placed',
        shortStage: 'Placed',
        percent: 22,
        count: '9,946',
        colorHex: 0xFFCBD5E1,
        isMock: true,
      ),
    ];
  }

  static List<ContentRoadmapMetric> _defaultContentRoadmaps() {
    return const [
      ContentRoadmapMetric(
        label: 'Tech Found.',
        fullLabel: 'Technical Foundations',
        heightPercent: 0.40,
        value: '12.4k',
        enrollments: 12400,
        isActive: false,
        isMock: true,
      ),
      ContentRoadmapMetric(
        label: 'Software Eng.',
        fullLabel: 'Software Engineering',
        heightPercent: 0.85,
        value: '28.1k',
        enrollments: 28100,
        isActive: true,
        isMock: true,
      ),
      ContentRoadmapMetric(
        label: 'Data Analytics',
        fullLabel: 'Data & Analytics',
        heightPercent: 0.60,
        value: '18.6k',
        enrollments: 18600,
        isActive: false,
        isMock: true,
      ),
      ContentRoadmapMetric(
        label: 'Prod Mgmt',
        fullLabel: 'Product Management',
        heightPercent: 0.35,
        value: '9.2k',
        enrollments: 9200,
        isActive: false,
        isMock: true,
      ),
      ContentRoadmapMetric(
        label: 'UX Design',
        fullLabel: 'User Experience Design',
        heightPercent: 0.50,
        value: '14.8k',
        enrollments: 14800,
        isActive: false,
        isMock: true,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalActiveUsers': totalActiveUsers,
      'activeUsersGrowth': activeUsersGrowth,
      'avgSessionDuration': avgSessionDuration,
      'sessionDurationGrowth': sessionDurationGrowth,
      'systemHealth': systemHealth,
      'systemHealthStatus': systemHealthStatus,
      'isSystemHealthy': isSystemHealthy,
      'growthTrajectory': growthTrajectory.map((e) => e.toJson()).toList(),
      'engagement': engagement.toJson(),
      'placementFunnel': placementFunnel.map((e) => e.toJson()).toList(),
      'contentRoadmaps': contentRoadmaps.map((e) => e.toJson()).toList(),
      'selectedDateRange': selectedDateRange,
      'isMock': isMock,
      'isLiveAtlasConnected': isLiveAtlasConnected,
    };
  }

  AdminPlatformAnalyticsDto copyWith({
    int? totalActiveUsers,
    String? activeUsersGrowth,
    String? avgSessionDuration,
    String? sessionDurationGrowth,
    String? systemHealth,
    String? systemHealthStatus,
    bool? isSystemHealthy,
    List<GrowthTrajectoryPoint>? growthTrajectory,
    EngagementMetricsDto? engagement,
    List<PlacementFunnelStage>? placementFunnel,
    List<ContentRoadmapMetric>? contentRoadmaps,
    String? selectedDateRange,
    bool? isMock,
    bool? isLiveAtlasConnected,
  }) {
    return AdminPlatformAnalyticsDto(
      totalActiveUsers: totalActiveUsers ?? this.totalActiveUsers,
      activeUsersGrowth: activeUsersGrowth ?? this.activeUsersGrowth,
      avgSessionDuration: avgSessionDuration ?? this.avgSessionDuration,
      sessionDurationGrowth:
          sessionDurationGrowth ?? this.sessionDurationGrowth,
      systemHealth: systemHealth ?? this.systemHealth,
      systemHealthStatus: systemHealthStatus ?? this.systemHealthStatus,
      isSystemHealthy: isSystemHealthy ?? this.isSystemHealthy,
      growthTrajectory: growthTrajectory ?? this.growthTrajectory,
      engagement: engagement ?? this.engagement,
      placementFunnel: placementFunnel ?? this.placementFunnel,
      contentRoadmaps: contentRoadmaps ?? this.contentRoadmaps,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      isMock: isMock ?? this.isMock,
      isLiveAtlasConnected: isLiveAtlasConnected ?? this.isLiveAtlasConnected,
    );
  }

  @override
  List<Object?> get props => [
        totalActiveUsers,
        activeUsersGrowth,
        avgSessionDuration,
        sessionDurationGrowth,
        systemHealth,
        systemHealthStatus,
        isSystemHealthy,
        growthTrajectory,
        engagement,
        placementFunnel,
        contentRoadmaps,
        selectedDateRange,
        isMock,
        isLiveAtlasConnected,
      ];
}

/// DTO for Weekly Growth Trajectory
class GrowthTrajectoryPoint extends Equatable {
  final String week;
  final String label;
  final int count;
  final bool isMock;

  const GrowthTrajectoryPoint({
    required this.week,
    required this.label,
    required this.count,
    this.isMock = false,
  });

  factory GrowthTrajectoryPoint.fromJson(Map<String, dynamic> json) {
    return GrowthTrajectoryPoint(
      week: json['week']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'label': label,
      'count': count,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [week, label, count, isMock];
}

/// DTO for Engagement (DAU/MAU)
class EngagementMetricsDto extends Equatable {
  final int ratioPercent;
  final String headline;
  final String description;
  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final bool isMock;

  const EngagementMetricsDto({
    this.ratioPercent = 42,
    this.headline = '42%',
    this.description = 'High daily retention indicative of core platform utility.',
    this.dailyActiveUsers = 52328,
    this.monthlyActiveUsers = 124592,
    this.isMock = false,
  });

  factory EngagementMetricsDto.fromJson(Map<String, dynamic> json) {
    return EngagementMetricsDto(
      ratioPercent: (json['ratioPercent'] as num?)?.toInt() ?? 42,
      headline: json['headline']?.toString() ?? '42%',
      description: json['description']?.toString() ??
          'High daily retention indicative of core platform utility.',
      dailyActiveUsers: (json['dailyActiveUsers'] as num?)?.toInt() ?? 52328,
      monthlyActiveUsers:
          (json['monthlyActiveUsers'] as num?)?.toInt() ?? 124592,
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ratioPercent': ratioPercent,
      'headline': headline,
      'description': description,
      'dailyActiveUsers': dailyActiveUsers,
      'monthlyActiveUsers': monthlyActiveUsers,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        ratioPercent,
        headline,
        description,
        dailyActiveUsers,
        monthlyActiveUsers,
        isMock,
      ];
}

/// DTO for Placement Funnel Stages
class PlacementFunnelStage extends Equatable {
  final String stage;
  final String shortStage;
  final int percent;
  final String count;
  final int colorHex;
  final bool isMock;

  const PlacementFunnelStage({
    required this.stage,
    required this.shortStage,
    required this.percent,
    required this.count,
    required this.colorHex,
    this.isMock = false,
  });

  factory PlacementFunnelStage.fromJson(Map<String, dynamic> json) {
    return PlacementFunnelStage(
      stage: json['stage']?.toString() ?? '',
      shortStage: json['shortStage']?.toString() ?? json['stage']?.toString() ?? '',
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      count: json['count']?.toString() ?? '0',
      colorHex: (json['colorHex'] as num?)?.toInt() ?? 0xFF6D28D9,
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'shortStage': shortStage,
      'percent': percent,
      'count': count,
      'colorHex': colorHex,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        stage,
        shortStage,
        percent,
        count,
        colorHex,
        isMock,
      ];
}

/// DTO for Top Content Roadmaps
class ContentRoadmapMetric extends Equatable {
  final String label;
  final String fullLabel;
  final double heightPercent;
  final String value;
  final int enrollments;
  final bool isActive;
  final bool isMock;

  const ContentRoadmapMetric({
    required this.label,
    required this.fullLabel,
    required this.heightPercent,
    required this.value,
    required this.enrollments,
    this.isActive = false,
    this.isMock = false,
  });

  factory ContentRoadmapMetric.fromJson(Map<String, dynamic> json) {
    return ContentRoadmapMetric(
      label: json['label']?.toString() ?? '',
      fullLabel: json['fullLabel']?.toString() ?? json['label']?.toString() ?? '',
      heightPercent: (json['heightPercent'] as num?)?.toDouble() ?? 0.0,
      value: json['value']?.toString() ?? '',
      enrollments: (json['enrollments'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'fullLabel': fullLabel,
      'heightPercent': heightPercent,
      'value': value,
      'enrollments': enrollments,
      'isActive': isActive,
      'isMock': isMock,
    };
  }

  ContentRoadmapMetric copyWith({
    String? label,
    String? fullLabel,
    double? heightPercent,
    String? value,
    int? enrollments,
    bool? isActive,
    bool? isMock,
  }) {
    return ContentRoadmapMetric(
      label: label ?? this.label,
      fullLabel: fullLabel ?? this.fullLabel,
      heightPercent: heightPercent ?? this.heightPercent,
      value: value ?? this.value,
      enrollments: enrollments ?? this.enrollments,
      isActive: isActive ?? this.isActive,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        label,
        fullLabel,
        heightPercent,
        value,
        enrollments,
        isActive,
        isMock,
      ];
}
