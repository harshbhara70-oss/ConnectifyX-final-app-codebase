import 'package:equatable/equatable.dart';
import '../data/models/admin_analytics_models.dart';
import '../data/services/admin_csv_exporter.dart';

enum AdminAnalyticsStatus { initial, loading, loaded, error }

class AdminAnalyticsState extends Equatable {
  final AdminAnalyticsStatus status;
  final AdminPlatformAnalyticsDto analytics;
  final String selectedDateRange;
  final String? selectedTrack;
  final String? selectedStage;
  final String? errorMessage;
  final String? exportMessage;
  final ExportResult? exportResult;
  final bool isExporting;

  const AdminAnalyticsState({
    this.status = AdminAnalyticsStatus.initial,
    this.analytics = const AdminPlatformAnalyticsDto(),
    this.selectedDateRange = '30_days',
    this.selectedTrack = 'Software Eng.',
    this.selectedStage,
    this.errorMessage,
    this.exportMessage,
    this.exportResult,
    this.isExporting = false,
  });

  AdminAnalyticsState copyWith({
    AdminAnalyticsStatus? status,
    AdminPlatformAnalyticsDto? analytics,
    String? selectedDateRange,
    String? selectedTrack,
    String? selectedStage,
    String? errorMessage,
    String? exportMessage,
    ExportResult? exportResult,
    bool? isExporting,
  }) {
    return AdminAnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      selectedStage: selectedStage ?? this.selectedStage,
      errorMessage: errorMessage,
      exportMessage: exportMessage,
      exportResult: exportResult ?? this.exportResult,
      isExporting: isExporting ?? this.isExporting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        analytics,
        selectedDateRange,
        selectedTrack,
        selectedStage,
        errorMessage,
        exportMessage,
        exportResult,
        isExporting,
      ];
}
