import 'package:equatable/equatable.dart';
import '../data/models/admin_dashboard_models.dart';
import '../data/services/admin_csv_exporter.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

class AdminDashboardLoaded extends AdminDashboardState {
  final AdminAnalyticsDto analytics;
  final PendingApprovalsDto pendingApprovals;
  final List<AdminActivityLogDto> activities;
  final List<TrafficDataPointDto> trafficData;
  final String selectedPlatform;
  final bool isApprovedAll;
  final bool isExporting;
  final bool isBroadcasting;
  final ExportResult? exportResult;
  final String? toastNotification;

  const AdminDashboardLoaded({
    required this.analytics,
    required this.pendingApprovals,
    required this.activities,
    required this.trafficData,
    this.selectedPlatform = 'All Platforms',
    this.isApprovedAll = false,
    this.isExporting = false,
    this.isBroadcasting = false,
    this.exportResult,
    this.toastNotification,
  });

  AdminDashboardLoaded copyWith({
    AdminAnalyticsDto? analytics,
    PendingApprovalsDto? pendingApprovals,
    List<AdminActivityLogDto>? activities,
    List<TrafficDataPointDto>? trafficData,
    String? selectedPlatform,
    bool? isApprovedAll,
    bool? isExporting,
    bool? isBroadcasting,
    ExportResult? exportResult,
    String? toastNotification,
    bool clearToast = false,
    bool clearExport = false,
  }) {
    return AdminDashboardLoaded(
      analytics: analytics ?? this.analytics,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      activities: activities ?? this.activities,
      trafficData: trafficData ?? this.trafficData,
      selectedPlatform: selectedPlatform ?? this.selectedPlatform,
      isApprovedAll: isApprovedAll ?? this.isApprovedAll,
      isExporting: isExporting ?? this.isExporting,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      exportResult: clearExport ? null : (exportResult ?? this.exportResult),
      toastNotification: clearToast ? null : (toastNotification ?? this.toastNotification),
    );
  }

  @override
  List<Object?> get props => [
        analytics,
        pendingApprovals,
        activities,
        trafficData,
        selectedPlatform,
        isApprovedAll,
        isExporting,
        isBroadcasting,
        exportResult,
        toastNotification,
      ];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;

  const AdminDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
