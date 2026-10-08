import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or pull-to-refresh
class FetchAdminDashboardData extends AdminDashboardEvent {
  final bool isRefresh;

  const FetchAdminDashboardData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Filter traffic dataset by platform ('All Platforms', 'Web', 'Mobile')
class ChangePlatformFilter extends AdminDashboardEvent {
  final String platform;

  const ChangePlatformFilter(this.platform);

  @override
  List<Object?> get props => [platform];
}

/// Approve all pending approvals
class ApproveAllRequested extends AdminDashboardEvent {
  const ApproveAllRequested();
}

/// Send system-wide broadcast message
class SendBroadcastRequested extends AdminDashboardEvent {
  final String message;

  const SendBroadcastRequested(this.message);

  @override
  List<Object?> get props => [message];
}

/// Export Executive Weekly Report CSV
class ExportReportRequested extends AdminDashboardEvent {
  const ExportReportRequested();
}

/// Dismiss current active toast / notification
class DismissToastNotification extends AdminDashboardEvent {
  const DismissToastNotification();
}
