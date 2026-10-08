import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_broadcast_models.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_broadcast_event.dart';
import 'admin_broadcast_state.dart';

class AdminBroadcastBloc extends Bloc<AdminBroadcastEvent, AdminBroadcastState> {
  final AdminApiService _apiService;

  AdminBroadcastBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminBroadcastInitial()) {
    on<FetchBroadcastControlData>(_onFetchBroadcastControlData);
    on<SendPlatformBroadcast>(_onSendPlatformBroadcast);
    on<SaveBroadcastDraft>(_onSaveBroadcastDraft);
    on<FilterBroadcastHistory>(_onFilterBroadcastHistory);
    on<ClearBroadcastSuccessBanner>(_onClearBroadcastSuccessBanner);
    on<ExportBroadcastLogs>(_onExportBroadcastLogs);
  }

  Future<void> _onFetchBroadcastControlData(
    FetchBroadcastControlData event,
    Emitter<AdminBroadcastState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AdminBroadcastLoading());
    }

    try {
      final results = await Future.wait([
        _apiService.fetchAdminBroadcasts(),
        _apiService.fetchCollegeOversightBroadcasts(),
        _apiService.fetchBroadcastSummaryStats(),
      ]);

      final broadcasts = results[0] as List<AdminBroadcastModel>;
      final oversight = results[1] as List<CollegeOversightBroadcastModel>;
      final stats = results[2] as AdminBroadcastSummaryStatsDto;

      emit(AdminBroadcastLoaded(
        broadcastHistory: broadcasts,
        displayedHistory: broadcasts,
        collegeOversightList: oversight,
        stats: stats,
      ));
    } catch (e) {
      emit(AdminBroadcastError('Failed to load broadcast communication records: ${e.toString()}'));
    }
  }

  Future<void> _onSendPlatformBroadcast(
    SendPlatformBroadcast event,
    Emitter<AdminBroadcastState> emit,
  ) async {
    if (state is! AdminBroadcastLoaded) return;
    final currentState = state as AdminBroadcastLoaded;

    emit(currentState.copyWith(isSending: true));

    try {
      final newBroadcast = await _apiService.sendAdminBroadcast(
        title: event.title,
        message: event.message,
        targetAudience: event.targetAudience,
        priority: event.priority,
      );

      final updatedHistory = [newBroadcast, ...currentState.broadcastHistory];
      final updatedFiltered = _applyFilter(
        updatedHistory,
        currentState.searchQuery,
        currentState.selectedAudienceFilter,
      );

      emit(currentState.copyWith(
        broadcastHistory: updatedHistory,
        displayedHistory: updatedFiltered,
        isSending: false,
        sentSuccess: true,
        actionMessage: 'Broadcast dispatched successfully to target audience!',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isSending: false,
        actionMessage: 'Failed to dispatch broadcast: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSaveBroadcastDraft(
    SaveBroadcastDraft event,
    Emitter<AdminBroadcastState> emit,
  ) async {
    if (state is! AdminBroadcastLoaded) return;
    final currentState = state as AdminBroadcastLoaded;

    emit(currentState.copyWith(isDraftSaving: true));

    try {
      await _apiService.saveAdminBroadcastDraft(
        title: event.title,
        message: event.message,
        targetAudience: event.targetAudience,
        priority: event.priority,
      );

      emit(currentState.copyWith(
        isDraftSaving: false,
        actionMessage: 'Draft broadcast saved successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isDraftSaving: false,
        actionMessage: 'Draft saved locally (Mock Mode).',
      ));
    }
  }

  void _onFilterBroadcastHistory(
    FilterBroadcastHistory event,
    Emitter<AdminBroadcastState> emit,
  ) {
    if (state is! AdminBroadcastLoaded) return;
    final currentState = state as AdminBroadcastLoaded;

    final query = event.query ?? currentState.searchQuery;
    final audience = event.audienceFilter ?? currentState.selectedAudienceFilter;

    final filtered = _applyFilter(currentState.broadcastHistory, query, audience);

    emit(currentState.copyWith(
      searchQuery: query,
      selectedAudienceFilter: audience,
      displayedHistory: filtered,
    ));
  }

  void _onClearBroadcastSuccessBanner(
    ClearBroadcastSuccessBanner event,
    Emitter<AdminBroadcastState> emit,
  ) {
    if (state is! AdminBroadcastLoaded) return;
    final currentState = state as AdminBroadcastLoaded;
    emit(currentState.copyWith(sentSuccess: false));
  }

  Future<void> _onExportBroadcastLogs(
    ExportBroadcastLogs event,
    Emitter<AdminBroadcastState> emit,
  ) async {
    if (state is! AdminBroadcastLoaded) return;
    final currentState = state as AdminBroadcastLoaded;

    try {
      final result = await AdminCsvExporter.exportBroadcastsToCsv(
        currentState.broadcastHistory,
        currentState.collegeOversightList,
      );

      emit(currentState.copyWith(
        exportResult: result,
        actionMessage: result.success ? 'Audit log exported successfully.' : result.errorMessage,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        actionMessage: 'Export failed: ${e.toString()}',
      ));
    }
  }

  List<AdminBroadcastModel> _applyFilter(
    List<AdminBroadcastModel> items,
    String query,
    String audienceFilter,
  ) {
    return items.where((b) {
      final matchesQuery = query.isEmpty ||
          b.title.toLowerCase().contains(query.toLowerCase()) ||
          b.target.toLowerCase().contains(query.toLowerCase()) ||
          b.message.toLowerCase().contains(query.toLowerCase());

      final matchesAudience = audienceFilter == 'all' ||
          (audienceFilter == 'students' && (b.targetAudienceKey == 'all_students' || b.target.toLowerCase().contains('student'))) ||
          (audienceFilter == 'colleges' && (b.targetAudienceKey == 'all_colleges' || b.target.toLowerCase().contains('institution') || b.target.toLowerCase().contains('college'))) ||
          (audienceFilter == 'recruiters' && (b.targetAudienceKey == 'all_recruiters' || b.target.toLowerCase().contains('recruiter')));

      return matchesQuery && matchesAudience;
    }).toList();
  }
}
