import 'package:equatable/equatable.dart';

abstract class AdminAnalyticsEvent extends Equatable {
  const AdminAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial or refreshed analytics data
class FetchPlatformAnalyticsData extends AdminAnalyticsEvent {
  final String dateRange;
  final bool isRefresh;

  const FetchPlatformAnalyticsData({
    this.dateRange = '30_days',
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [dateRange, isRefresh];
}

/// Change date range filter ('30_days', '7_days', '90_days')
class ChangeAnalyticsDateRange extends AdminAnalyticsEvent {
  final String dateRange;

  const ChangeAnalyticsDateRange(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

/// Export Analytics Report (CSV download/share)
class ExportAnalyticsReportEvent extends AdminAnalyticsEvent {
  const ExportAnalyticsReportEvent();
}

/// Select a Content Roadmap track to highlight
class SelectRoadmapTrackEvent extends AdminAnalyticsEvent {
  final String trackLabel;

  const SelectRoadmapTrackEvent(this.trackLabel);

  @override
  List<Object?> get props => [trackLabel];
}

/// Select a Placement Funnel stage to inspect
class SelectFunnelStageEvent extends AdminAnalyticsEvent {
  final String stageName;

  const SelectFunnelStageEvent(this.stageName);

  @override
  List<Object?> get props => [stageName];
}
