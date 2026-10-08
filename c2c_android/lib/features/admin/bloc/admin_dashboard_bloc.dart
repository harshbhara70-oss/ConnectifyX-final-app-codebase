import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminApiService _apiService;

  AdminDashboardBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminDashboardInitial()) {
    on<FetchAdminDashboardData>(_onFetchAdminDashboardData);
    on<ChangePlatformFilter>(_onChangePlatformFilter);
    on<ApproveAllRequested>(_onApproveAllRequested);
    on<SendBroadcastRequested>(_onSendBroadcastRequested);
    on<ExportReportRequested>(_onExportReportRequested);
    on<DismissToastNotification>(_onDismissToastNotification);
  }

  Future<void> _onFetchAdminDashboardData(
    FetchAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AdminDashboardLoading());
    }
    try {
      final analytics = await _apiService.fetchDashboardAnalytics();
      final approvals = await _apiService.fetchPendingApprovals();
      final activities = await _apiService.fetchActivityLogs();
      final currentPlatform = state is AdminDashboardLoaded
          ? (state as AdminDashboardLoaded).selectedPlatform
          : 'All Platforms';
      final traffic = _apiService.fetchTrafficData(currentPlatform);

      emit(
        AdminDashboardLoaded(
          analytics: analytics,
          pendingApprovals: approvals,
          activities: activities,
          trafficData: traffic,
          selectedPlatform: currentPlatform,
          isApprovedAll: false,
        ),
      );
    } catch (e) {
      emit(AdminDashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onChangePlatformFilter(
    ChangePlatformFilter event,
    Emitter<AdminDashboardState> emit,
  ) {
    if (state is AdminDashboardLoaded) {
      final current = state as AdminDashboardLoaded;
      final newTraffic = _apiService.fetchTrafficData(event.platform);

      emit(
        current.copyWith(
          selectedPlatform: event.platform,
          trafficData: newTraffic,
          clearToast: true,
        ),
      );
    }
  }

  Future<void> _onApproveAllRequested(
    ApproveAllRequested event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final current = state as AdminDashboardLoaded;
      await _apiService.approveAllPending();

      emit(
        current.copyWith(
          pendingApprovals: current.pendingApprovals.copyWith(
            collegePending: 0,
            recruiterUrgent: 0,
            broadcastDrafts: 0,
          ),
          isApprovedAll: true,
          toastNotification:
              '✅ All pending onboarding requests, recruiter verifications & broadcasts approved successfully!',
        ),
      );
    }
  }

  Future<void> _onSendBroadcastRequested(
    SendBroadcastRequested event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final current = state as AdminDashboardLoaded;
      emit(current.copyWith(isBroadcasting: true, clearToast: true));

      await _apiService.dispatchBroadcast(event.message);

      final preview = event.message.length > 30
          ? '${event.message.substring(0, 30)}...'
          : event.message;

      emit(
        current.copyWith(
          isBroadcasting: false,
          toastNotification: '📢 Platform Broadcast dispatched: "$preview"',
        ),
      );
    }
  }

  Future<void> _onExportReportRequested(
    ExportReportRequested event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is AdminDashboardLoaded) {
      final current = state as AdminDashboardLoaded;
      emit(current.copyWith(isExporting: true, clearToast: true, clearExport: true));

      final result = await AdminCsvExporter.exportDashboardWeeklyReportToCsv(
        analytics: current.analytics,
        approvals: current.pendingApprovals,
        activities: current.activities,
        traffic: current.trafficData,
      );

      emit(
        current.copyWith(
          isExporting: false,
          exportResult: result,
          toastNotification:
              'Executive Weekly Report CSV generated successfully (${result.count} data rows).',
        ),
      );
    }
  }

  void _onDismissToastNotification(
    DismissToastNotification event,
    Emitter<AdminDashboardState> emit,
  ) {
    if (state is AdminDashboardLoaded) {
      final current = state as AdminDashboardLoaded;
      emit(current.copyWith(clearToast: true));
    }
  }
}
