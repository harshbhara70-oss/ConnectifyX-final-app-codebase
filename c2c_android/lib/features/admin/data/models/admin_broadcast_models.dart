import 'package:equatable/equatable.dart';

/// Model representing a platform-wide administrative broadcast record.
/// Fully matches web BroadcastControl.tsx table and form records.
class AdminBroadcastModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final String target;
  final String targetAudienceKey;
  final String priority;
  final String date;
  final String openRate;
  final String clickRate;
  final String status;
  final String recipientCount;
  final bool isMock;

  const AdminBroadcastModel({
    required this.id,
    required this.title,
    this.message = '',
    required this.target,
    this.targetAudienceKey = 'all_students',
    this.priority = 'standard',
    required this.date,
    required this.openRate,
    this.clickRate = '--',
    this.status = 'Delivered',
    this.recipientCount = '10.5k',
    this.isMock = false,
  });

  factory AdminBroadcastModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminBroadcastModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'bc_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Broadcast Announcement',
      message: json['message']?.toString() ?? json['content']?.toString() ?? '',
      target: json['target']?.toString() ?? json['targetAudience']?.toString() ?? 'All Users',
      targetAudienceKey: json['targetAudienceKey']?.toString() ?? 'all_students',
      priority: json['priority']?.toString() ?? 'standard',
      date: json['date']?.toString() ?? json['createdAt']?.toString() ?? 'Just now',
      openRate: json['openRate']?.toString() ?? json['open']?.toString() ?? '72%',
      clickRate: json['clickRate']?.toString() ?? json['click']?.toString() ?? '--',
      status: json['status']?.toString() ?? 'Delivered',
      recipientCount: json['recipientCount']?.toString() ?? json['vol']?.toString() ?? '5.0k',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'target': target,
      'targetAudienceKey': targetAudienceKey,
      'priority': priority,
      'date': date,
      'openRate': openRate,
      'clickRate': clickRate,
      'status': status,
      'recipientCount': recipientCount,
      'isMock': isMock,
    };
  }

  AdminBroadcastModel copyWith({
    String? id,
    String? title,
    String? message,
    String? target,
    String? targetAudienceKey,
    String? priority,
    String? date,
    String? openRate,
    String? clickRate,
    String? status,
    String? recipientCount,
    bool? isMock,
  }) {
    return AdminBroadcastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      target: target ?? this.target,
      targetAudienceKey: targetAudienceKey ?? this.targetAudienceKey,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      openRate: openRate ?? this.openRate,
      clickRate: clickRate ?? this.clickRate,
      status: status ?? this.status,
      recipientCount: recipientCount ?? this.recipientCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        target,
        targetAudienceKey,
        priority,
        date,
        openRate,
        clickRate,
        status,
        recipientCount,
        isMock,
      ];
}

/// Model representing institutional / college oversight broadcasts initiated by institutional administrators.
class CollegeOversightBroadcastModel extends Equatable {
  final String id;
  final String college;
  final String title;
  final String target;
  final String vol;
  final String sentDate;
  final String status;
  final bool isMock;

  const CollegeOversightBroadcastModel({
    required this.id,
    required this.college,
    required this.title,
    required this.target,
    required this.vol,
    this.sentDate = 'Today, 10:00 AM',
    this.status = 'Delivered',
    this.isMock = false,
  });

  factory CollegeOversightBroadcastModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return CollegeOversightBroadcastModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'col_bc_${DateTime.now().millisecondsSinceEpoch}',
      college: json['college']?.toString() ?? 'Institution',
      title: json['title']?.toString() ?? 'College Announcement',
      target: json['target']?.toString() ?? 'Target: Global',
      vol: json['vol']?.toString() ?? json['volume']?.toString() ?? '1.0k',
      sentDate: json['sentDate']?.toString() ?? json['date']?.toString() ?? 'Today',
      status: json['status']?.toString() ?? 'Delivered',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'college': college,
      'title': title,
      'target': target,
      'vol': vol,
      'sentDate': sentDate,
      'status': status,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [id, college, title, target, vol, sentDate, status, isMock];
}

/// Summary metrics for Admin Broadcast Control
class AdminBroadcastSummaryStatsDto extends Equatable {
  final int totalBroadcasts;
  final int activeAlerts;
  final String avgOpenRate;
  final String totalReach;
  final bool isMock;

  const AdminBroadcastSummaryStatsDto({
    this.totalBroadcasts = 48,
    this.activeAlerts = 3,
    this.avgOpenRate = '74.2%',
    this.totalReach = '142.5k',
    this.isMock = false,
  });

  factory AdminBroadcastSummaryStatsDto.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminBroadcastSummaryStatsDto(
      totalBroadcasts: json['totalBroadcasts'] is int
          ? json['totalBroadcasts'] as int
          : int.tryParse(json['totalBroadcasts']?.toString() ?? '48') ?? 48,
      activeAlerts: json['activeAlerts'] is int
          ? json['activeAlerts'] as int
          : int.tryParse(json['activeAlerts']?.toString() ?? '3') ?? 3,
      avgOpenRate: json['avgOpenRate']?.toString() ?? '74.2%',
      totalReach: json['totalReach']?.toString() ?? '142.5k',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBroadcasts': totalBroadcasts,
      'activeAlerts': activeAlerts,
      'avgOpenRate': avgOpenRate,
      'totalReach': totalReach,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [totalBroadcasts, activeAlerts, avgOpenRate, totalReach, isMock];
}
