import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_analytics_event.dart';
import 'admin_analytics_state.dart';

class AdminAnalyticsBloc extends Bloc<AdminAnalyticsEvent, AdminAnalyticsState> {
  final AdminApiService _apiService;

  AdminAnalyticsBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminAnalyticsState()) {
    on<FetchPlatformAnalyticsData>(_onFetchPlatformAnalyticsData);
    on<ChangeAnalyticsDateRange>(_onChangeAnalyticsDateRange);
    on<ExportAnalyticsReportEvent>(_onExportAnalyticsReport);
    on<SelectRoadmapTrackEvent>(_onSelectRoadmapTrack);
    on<SelectFunnelStageEvent>(_onSelectFunnelStage);
  }

  Future<void> _onFetchPlatformAnalyticsData(
    FetchPlatformAnalyticsData event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: AdminAnalyticsStatus.loading));
    }

    try {
      final analytics = await _apiService.fetchPlatformAnalytics(
        dateRange: event.dateRange,
      );

      // Highlight the selected track if available
      final updatedRoadmaps = analytics.contentRoadmaps.map((r) {
        final isSelected = r.label == state.selectedTrack ||
            (state.selectedTrack == null && r.isActive);
        return r.copyWith(isActive: isSelected);
      }).toList();

      final updatedAnalytics = analytics.copyWith(
        contentRoadmaps: updatedRoadmaps,
        selectedDateRange: event.dateRange,
      );

      emit(state.copyWith(
        status: AdminAnalyticsStatus.loaded,
        analytics: updatedAnalytics,
        selectedDateRange: event.dateRange,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminAnalyticsStatus.error,
        errorMessage: 'Failed to load platform analytics: ${e.toString()}',
      ));
    }
  }

  Future<void> _onChangeAnalyticsDateRange(
    ChangeAnalyticsDateRange event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(state.copyWith(
      selectedDateRange: event.dateRange,
      status: AdminAnalyticsStatus.loading,
    ));

    try {
      final analytics = await _apiService.fetchPlatformAnalytics(
        dateRange: event.dateRange,
      );

      final updatedRoadmaps = analytics.contentRoadmaps.map((r) {
        final isSelected = r.label == state.selectedTrack ||
            (state.selectedTrack == null && r.isActive);
        return r.copyWith(isActive: isSelected);
      }).toList();

      final updatedAnalytics = analytics.copyWith(
        contentRoadmaps: updatedRoadmaps,
        selectedDateRange: event.dateRange,
      );

      emit(state.copyWith(
        status: AdminAnalyticsStatus.loaded,
        analytics: updatedAnalytics,
        selectedDateRange: event.dateRange,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AdminAnalyticsStatus.loaded,
        selectedDateRange: event.dateRange,
      ));
    }
  }

  Future<void> _onExportAnalyticsReport(
    ExportAnalyticsReportEvent event,
    Emitter<AdminAnalyticsState> emit,
  ) async {
    emit(state.copyWith(isExporting: true, exportMessage: null, exportResult: null));

    try {
      final result = await AdminCsvExporter.exportPlatformAnalyticsToCsv(state.analytics);

      if (result.success) {
        emit(state.copyWith(
          isExporting: false,
          exportResult: result,
          exportMessage: 'Analytics report exported successfully (${result.fileName})',
        ));
      } else {
        emit(state.copyWith(
          isExporting: false,
          exportResult: result,
          exportMessage: result.errorMessage ?? 'Failed to export analytics report',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportMessage: 'Failed to export report: ${e.toString()}',
      ));
    }
  }

  void _onSelectRoadmapTrack(
    SelectRoadmapTrackEvent event,
    Emitter<AdminAnalyticsState> emit,
  ) {
    final updatedRoadmaps = state.analytics.contentRoadmaps.map((r) {
      return r.copyWith(isActive: r.label == event.trackLabel);
    }).toList();

    final updatedAnalytics = state.analytics.copyWith(
      contentRoadmaps: updatedRoadmaps,
    );

    emit(state.copyWith(
      selectedTrack: event.trackLabel,
      analytics: updatedAnalytics,
    ));
  }

  void _onSelectFunnelStage(
    SelectFunnelStageEvent event,
    Emitter<AdminAnalyticsState> emit,
  ) {
    emit(state.copyWith(
      selectedStage: state.selectedStage == event.stageName ? null : event.stageName,
    ));
  }
}
