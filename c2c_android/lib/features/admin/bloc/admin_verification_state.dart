import 'package:equatable/equatable.dart';
import '../data/models/admin_verification_models.dart';
import '../data/services/admin_csv_exporter.dart';

abstract class AdminVerificationState extends Equatable {
  const AdminVerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state
class AdminVerificationInitial extends AdminVerificationState {
  const AdminVerificationInitial();
}

/// Loading state (shimmer matching UI)
class AdminVerificationLoading extends AdminVerificationState {
  const AdminVerificationLoading();
}

/// Fully loaded populated state
class AdminVerificationLoaded extends AdminVerificationState {
  final List<AdminVerificationCardModel> allCards;
  final List<AdminVerificationCardModel> displayedCards;
  final String activeTab; // 'colleges', 'recruiters', 'flagged'
  final AdminQueueStatusDto queueStatus;
  final AdminAutoCheckFilterDto autoCheckFilters;
  final int collegesCount;
  final int recruitersCount;
  final int flaggedCount;
  final String? actionMessage;
  final bool isExporting;
  final ExportResult? exportResult;

  const AdminVerificationLoaded({
    required this.allCards,
    required this.displayedCards,
    required this.activeTab,
    required this.queueStatus,
    required this.autoCheckFilters,
    required this.collegesCount,
    required this.recruitersCount,
    required this.flaggedCount,
    this.actionMessage,
    this.isExporting = false,
    this.exportResult,
  });

  AdminVerificationLoaded copyWith({
    List<AdminVerificationCardModel>? allCards,
    List<AdminVerificationCardModel>? displayedCards,
    String? activeTab,
    AdminQueueStatusDto? queueStatus,
    AdminAutoCheckFilterDto? autoCheckFilters,
    int? collegesCount,
    int? recruitersCount,
    int? flaggedCount,
    String? actionMessage,
    bool? isExporting,
    ExportResult? exportResult,
    bool clearExportResult = false,
  }) {
    return AdminVerificationLoaded(
      allCards: allCards ?? this.allCards,
      displayedCards: displayedCards ?? this.displayedCards,
      activeTab: activeTab ?? this.activeTab,
      queueStatus: queueStatus ?? this.queueStatus,
      autoCheckFilters: autoCheckFilters ?? this.autoCheckFilters,
      collegesCount: collegesCount ?? this.collegesCount,
      recruitersCount: recruitersCount ?? this.recruitersCount,
      flaggedCount: flaggedCount ?? this.flaggedCount,
      actionMessage: actionMessage,
      isExporting: isExporting ?? this.isExporting,
      exportResult: clearExportResult ? null : (exportResult ?? this.exportResult),
    );
  }

  @override
  List<Object?> get props => [
    allCards,
    displayedCards,
    activeTab,
    queueStatus,
    autoCheckFilters,
    collegesCount,
    recruitersCount,
    flaggedCount,
    actionMessage,
    isExporting,
    exportResult,
  ];
}

/// Error state
class AdminVerificationError extends AdminVerificationState {
  final String message;

  const AdminVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}
