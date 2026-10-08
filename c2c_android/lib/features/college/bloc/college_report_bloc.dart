import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/models/reports_analytics_model.dart';
import '../data/services/reports_analytics_api_service.dart';

// ============================== EVENTS ==============================

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers a fetch of reports dataset for the specified academic session.
class FetchReportsEvent extends ReportEvent {
  final String session;
  const FetchReportsEvent({this.session = '2023-24'});

  @override
  List<Object?> get props => [session];
}

/// Changes the academic session ('2023-24' | '2024-25' | '2025-26')
class ChangeSessionEvent extends ReportEvent {
  final String session;
  const ChangeSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

/// Realtime client-side search query across drives, company names, roles, and status
class SearchReportsEvent extends ReportEvent {
  final String query;
  const SearchReportsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filters drives by status ('ALL' | 'CLOSED' | 'IN PROGRESS' | 'UPCOMING')
class FilterDriveStatusEvent extends ReportEvent {
  final String status;
  const FilterDriveStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Triggers generation and export of the Executive Placement Intelligence Report
class GenerateExecutiveReportEvent extends ReportEvent {
  final String session;
  final String format; // 'pdf' | 'excel'
  final List<String> departments;
  final bool includeAiScores;

  const GenerateExecutiveReportEvent({
    required this.session,
    required this.format,
    required this.departments,
    required this.includeAiScores,
  });

  @override
  List<Object?> get props => [session, format, departments, includeAiScores];
}

/// Exports the currently filtered drives to CSV
class ExportDrivesCsvEvent extends ReportEvent {
  const ExportDrivesCsvEvent();
}

// ============================== STATES ==============================

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportsAnalyticsDataModel data;
  final String selectedSession;
  final String searchQuery;
  final String statusFilter;
  final List<DrivePerformanceRow> filteredDrives;
  final bool isGeneratingReport;
  final String? toastMessage;
  final String? exportedCsv;

  const ReportLoaded({
    required this.data,
    this.selectedSession = '2023-24',
    this.searchQuery = '',
    this.statusFilter = 'ALL',
    required this.filteredDrives,
    this.isGeneratingReport = false,
    this.toastMessage,
    this.exportedCsv,
  });

  ReportLoaded copyWith({
    ReportsAnalyticsDataModel? data,
    String? selectedSession,
    String? searchQuery,
    String? statusFilter,
    List<DrivePerformanceRow>? filteredDrives,
    bool? isGeneratingReport,
    String? toastMessage,
    String? exportedCsv,
    bool clearToast = false,
    bool clearExportedCsv = false,
  }) {
    return ReportLoaded(
      data: data ?? this.data,
      selectedSession: selectedSession ?? this.selectedSession,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      filteredDrives: filteredDrives ?? this.filteredDrives,
      isGeneratingReport: isGeneratingReport ?? this.isGeneratingReport,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      exportedCsv: clearExportedCsv ? null : (exportedCsv ?? this.exportedCsv),
    );
  }

  @override
  List<Object?> get props => [
        data,
        selectedSession,
        searchQuery,
        statusFilter,
        filteredDrives,
        isGeneratingReport,
        toastMessage,
        exportedCsv,
      ];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================== BLOC ==============================

class CollegeReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportsAnalyticsApiService _apiService;

  CollegeReportBloc({ReportsAnalyticsApiService? apiService})
      : _apiService = apiService ?? ReportsAnalyticsApiService(),
        super(ReportInitial()) {
    on<FetchReportsEvent>(_onFetch);
    on<ChangeSessionEvent>(_onChangeSession);
    on<SearchReportsEvent>(_onSearch);
    on<FilterDriveStatusEvent>(_onFilterStatus);
    on<GenerateExecutiveReportEvent>(_onGenerateReport);
    on<ExportDrivesCsvEvent>(_onExportCsv);
  }

  Future<void> _onFetch(
    FetchReportsEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) {
      emit(ReportLoading());
    }
    try {
      final data = await _apiService.fetchReportsData(session: event.session);
      final filtered = _applyFilters(data.drives, '', 'ALL');
      emit(ReportLoaded(
        data: data,
        selectedSession: event.session,
        searchQuery: '',
        statusFilter: 'ALL',
        filteredDrives: filtered,
      ));
    } catch (e) {
      emit(ReportError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onChangeSession(
    ChangeSessionEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentQuery = (state is ReportLoaded) ? (state as ReportLoaded).searchQuery : '';
    final currentFilter = (state is ReportLoaded) ? (state as ReportLoaded).statusFilter : 'ALL';

    emit(ReportLoading());
    try {
      final data = await _apiService.fetchReportsData(session: event.session);
      final filtered = _applyFilters(data.drives, currentQuery, currentFilter);
      emit(ReportLoaded(
        data: data,
        selectedSession: event.session,
        searchQuery: currentQuery,
        statusFilter: currentFilter,
        filteredDrives: filtered,
        toastMessage: 'Loaded dataset for Academic Session ${event.session}.',
      ));
    } catch (e) {
      emit(ReportError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onSearch(SearchReportsEvent event, Emitter<ReportState> emit) {
    if (state is! ReportLoaded) return;
    final loaded = state as ReportLoaded;
    final filtered = _applyFilters(loaded.data.drives, event.query, loaded.statusFilter);
    emit(loaded.copyWith(
      searchQuery: event.query,
      filteredDrives: filtered,
    ));
  }

  void _onFilterStatus(FilterDriveStatusEvent event, Emitter<ReportState> emit) {
    if (state is! ReportLoaded) return;
    final loaded = state as ReportLoaded;
    final filtered = _applyFilters(loaded.data.drives, loaded.searchQuery, event.status);
    emit(loaded.copyWith(
      statusFilter: event.status,
      filteredDrives: filtered,
    ));
  }

  Future<void> _onGenerateReport(
    GenerateExecutiveReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (state is! ReportLoaded) return;
    final loaded = state as ReportLoaded;
    emit(loaded.copyWith(isGeneratingReport: true));

    final res = await _apiService.exportReport(
      session: event.session,
      format: event.format,
      departments: event.departments,
      includeAiScores: event.includeAiScores,
    );

    final msg = res['message'] ??
        'Executive Placement Intelligence Report (${event.session}) generated as ${event.format.toUpperCase()}.';

    emit(loaded.copyWith(
      isGeneratingReport: false,
      toastMessage: msg,
    ));
  }

  void _onExportCsv(ExportDrivesCsvEvent event, Emitter<ReportState> emit) {
    if (state is! ReportLoaded) return;
    final loaded = state as ReportLoaded;
    final csv = _apiService.generateDrivesCsv(loaded.filteredDrives, loaded.selectedSession);
    emit(loaded.copyWith(
      exportedCsv: csv,
      toastMessage: 'Exported hiring drive performance dataset for ${loaded.selectedSession} to CSV.',
    ));
  }

  List<DrivePerformanceRow> _applyFilters(
    List<DrivePerformanceRow> drives,
    String query,
    String status,
  ) {
    final q = query.trim().toLowerCase();
    final s = status.trim().toUpperCase();

    return drives.filter((d) {
      final matchesQuery = q.isEmpty ||
          d.companyName.toLowerCase().contains(q) ||
          d.role.toLowerCase().contains(q) ||
          d.status.toLowerCase().contains(q);

      final matchesStatus = s == 'ALL' || d.status.toUpperCase() == s;

      return matchesQuery && matchesStatus;
    }).toList();
  }
}

extension _IterableExt<T> on Iterable<T> {
  List<T> filter(bool Function(T) test) {
    return where(test).toList();
  }
}