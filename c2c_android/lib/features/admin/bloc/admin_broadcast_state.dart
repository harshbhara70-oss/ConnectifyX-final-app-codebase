import 'package:equatable/equatable.dart';
import '../data/models/admin_broadcast_models.dart';
import '../data/services/admin_csv_exporter.dart';

abstract class AdminBroadcastState extends Equatable {
  const AdminBroadcastState();

  @override
  List<Object?> get props => [];
}

class AdminBroadcastInitial extends AdminBroadcastState {
  const AdminBroadcastInitial();
}

class AdminBroadcastLoading extends AdminBroadcastState {
  const AdminBroadcastLoading();
}

class AdminBroadcastLoaded extends AdminBroadcastState {
  final List<AdminBroadcastModel> broadcastHistory;
  final List<AdminBroadcastModel> displayedHistory;
  final List<CollegeOversightBroadcastModel> collegeOversightList;
  final AdminBroadcastSummaryStatsDto stats;
  final String searchQuery;
  final String selectedAudienceFilter;
  final bool isSending;
  final bool isDraftSaving;
  final bool sentSuccess;
  final String? actionMessage;
  final ExportResult? exportResult;

  const AdminBroadcastLoaded({
    required this.broadcastHistory,
    required this.displayedHistory,
    required this.collegeOversightList,
    required this.stats,
    this.searchQuery = '',
    this.selectedAudienceFilter = 'all',
    this.isSending = false,
    this.isDraftSaving = false,
    this.sentSuccess = false,
    this.actionMessage,
    this.exportResult,
  });

  AdminBroadcastLoaded copyWith({
    List<AdminBroadcastModel>? broadcastHistory,
    List<AdminBroadcastModel>? displayedHistory,
    List<CollegeOversightBroadcastModel>? collegeOversightList,
    AdminBroadcastSummaryStatsDto? stats,
    String? searchQuery,
    String? selectedAudienceFilter,
    bool? isSending,
    bool? isDraftSaving,
    bool? sentSuccess,
    String? actionMessage,
    ExportResult? exportResult,
  }) {
    return AdminBroadcastLoaded(
      broadcastHistory: broadcastHistory ?? this.broadcastHistory,
      displayedHistory: displayedHistory ?? this.displayedHistory,
      collegeOversightList: collegeOversightList ?? this.collegeOversightList,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedAudienceFilter: selectedAudienceFilter ?? this.selectedAudienceFilter,
      isSending: isSending ?? this.isSending,
      isDraftSaving: isDraftSaving ?? this.isDraftSaving,
      sentSuccess: sentSuccess ?? this.sentSuccess,
      actionMessage: actionMessage,
      exportResult: exportResult,
    );
  }

  @override
  List<Object?> get props => [
        broadcastHistory,
        displayedHistory,
        collegeOversightList,
        stats,
        searchQuery,
        selectedAudienceFilter,
        isSending,
        isDraftSaving,
        sentSuccess,
        actionMessage,
        exportResult,
      ];
}

class AdminBroadcastError extends AdminBroadcastState {
  final String message;

  const AdminBroadcastError(this.message);

  @override
  List<Object?> get props => [message];
}
