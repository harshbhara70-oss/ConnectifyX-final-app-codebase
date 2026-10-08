import 'package:equatable/equatable.dart';

abstract class AdminBroadcastEvent extends Equatable {
  const AdminBroadcastEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial broadcast control state & logs
class FetchBroadcastControlData extends AdminBroadcastEvent {
  final bool isRefresh;

  const FetchBroadcastControlData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Dispatches a platform-wide broadcast announcement
class SendPlatformBroadcast extends AdminBroadcastEvent {
  final String title;
  final String message;
  final String targetAudience;
  final String priority;

  const SendPlatformBroadcast({
    required this.title,
    required this.message,
    required this.targetAudience,
    required this.priority,
  });

  @override
  List<Object?> get props => [title, message, targetAudience, priority];
}

/// Saves broadcast draft locally and to backend
class SaveBroadcastDraft extends AdminBroadcastEvent {
  final String title;
  final String message;
  final String targetAudience;
  final String priority;

  const SaveBroadcastDraft({
    required this.title,
    required this.message,
    required this.targetAudience,
    required this.priority,
  });

  @override
  List<Object?> get props => [title, message, targetAudience, priority];
}

/// Filter broadcast history by search query or audience
class FilterBroadcastHistory extends AdminBroadcastEvent {
  final String? query;
  final String? audienceFilter;

  const FilterBroadcastHistory({this.query, this.audienceFilter});

  @override
  List<Object?> get props => [query, audienceFilter];
}

/// Clear the success banner alert
class ClearBroadcastSuccessBanner extends AdminBroadcastEvent {
  const ClearBroadcastSuccessBanner();
}

/// Export institutional / broadcast logs
class ExportBroadcastLogs extends AdminBroadcastEvent {
  const ExportBroadcastLogs();
}
