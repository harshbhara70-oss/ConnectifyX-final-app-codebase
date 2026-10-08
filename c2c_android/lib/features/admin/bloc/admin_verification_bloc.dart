import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_verification_models.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_verification_event.dart';
import 'admin_verification_state.dart';

class AdminVerificationBloc extends Bloc<AdminVerificationEvent, AdminVerificationState> {
  final AdminApiService _apiService;

  AdminVerificationBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminVerificationInitial()) {
    on<FetchVerificationQueueData>(_onFetchVerificationQueueData);
    on<ChangeVerificationTab>(_onChangeVerificationTab);
    on<ToggleAutoCheckFilter>(_onToggleAutoCheckFilter);
    on<ApproveVerificationItem>(_onApproveVerificationItem);
    on<RejectVerificationItem>(_onRejectVerificationItem);
    on<RequestVerificationInfoItem>(_onRequestVerificationInfoItem);
    on<ExportVerificationAuditLog>(_onExportVerificationAuditLog);
  }

  Future<void> _onFetchVerificationQueueData(
    FetchVerificationQueueData event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AdminVerificationLoading());
    }

    try {
      final allCards = await _apiService.fetchVerificationQueue();
      final queueStatus = await _apiService.fetchQueueStatus();

      final collegesCount = allCards.where((c) => c.category == 'colleges').length;
      final recruitersCount = allCards.where((c) => c.category == 'recruiters').length;
      final flaggedCount = allCards.where((c) => c.category == 'flagged').length;

      const defaultFilters = AdminAutoCheckFilterDto();
      final displayed = _filterCards(allCards, 'colleges', defaultFilters);

      emit(AdminVerificationLoaded(
        allCards: allCards,
        displayedCards: displayed,
        activeTab: 'colleges',
        queueStatus: queueStatus,
        autoCheckFilters: defaultFilters,
        collegesCount: collegesCount > 0 ? collegesCount : 12,
        recruitersCount: recruitersCount > 0 ? recruitersCount : 4,
        flaggedCount: flaggedCount > 0 ? flaggedCount : 3,
      ));
    } catch (e) {
      emit(AdminVerificationError('Failed to load verification queue: ${e.toString()}'));
    }
  }

  void _onChangeVerificationTab(
    ChangeVerificationTab event,
    Emitter<AdminVerificationState> emit,
  ) {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    final displayed = _filterCards(
      currentState.allCards,
      event.tab,
      currentState.autoCheckFilters,
    );

    emit(currentState.copyWith(
      activeTab: event.tab,
      displayedCards: displayed,
    ));
  }

  void _onToggleAutoCheckFilter(
    ToggleAutoCheckFilter event,
    Emitter<AdminVerificationState> emit,
  ) {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    final updatedFilters = currentState.autoCheckFilters.copyWith(
      domainVerifiedOnly: event.domainVerified,
      docsProvidedOnly: event.docsProvided,
      flaggedByAiOnly: event.flaggedByAi,
    );

    final displayed = _filterCards(
      currentState.allCards,
      currentState.activeTab,
      updatedFilters,
    );

    emit(currentState.copyWith(
      autoCheckFilters: updatedFilters,
      displayedCards: displayed,
    ));
  }

  Future<void> _onApproveVerificationItem(
    ApproveVerificationItem event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    try {
      await _apiService.approveVerification(event.id);

      final updatedAll = currentState.allCards.map((c) {
        return c.id == event.id ? c.copyWith(status: 'approved') : c;
      }).toList();

      final displayed = _filterCards(
        updatedAll,
        currentState.activeTab,
        currentState.autoCheckFilters,
      );

      emit(currentState.copyWith(
        allCards: updatedAll,
        displayedCards: displayed,
        actionMessage: 'Institution successfully verified and approved.',
      ));
    } catch (e) {
      emit(currentState.copyWith(actionMessage: 'Error approving item: ${e.toString()}'));
    }
  }

  Future<void> _onRejectVerificationItem(
    RejectVerificationItem event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    try {
      await _apiService.rejectVerification(event.id);

      final updatedAll = currentState.allCards.map((c) {
        return c.id == event.id ? c.copyWith(status: 'rejected') : c;
      }).toList();

      final displayed = _filterCards(
        updatedAll,
        currentState.activeTab,
        currentState.autoCheckFilters,
      );

      emit(currentState.copyWith(
        allCards: updatedAll,
        displayedCards: displayed,
        actionMessage: 'Submission marked as rejected from queue.',
      ));
    } catch (e) {
      emit(currentState.copyWith(actionMessage: 'Error rejecting item: ${e.toString()}'));
    }
  }

  Future<void> _onRequestVerificationInfoItem(
    RequestVerificationInfoItem event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    try {
      await _apiService.requestVerificationInfo(event.id, event.query);

      emit(currentState.copyWith(
        actionMessage: 'Information request inquiry sent to institution admin.',
      ));
    } catch (e) {
      emit(currentState.copyWith(actionMessage: 'Failed to send info request: ${e.toString()}'));
    }
  }

  Future<void> _onExportVerificationAuditLog(
    ExportVerificationAuditLog event,
    Emitter<AdminVerificationState> emit,
  ) async {
    if (state is! AdminVerificationLoaded) return;
    final currentState = state as AdminVerificationLoaded;

    emit(currentState.copyWith(isExporting: true, clearExportResult: true));

    try {
      final exportResult = await AdminCsvExporter.exportVerificationAuditLogToCsvFile(
        cards: currentState.displayedCards,
        status: currentState.queueStatus,
      );

      emit(currentState.copyWith(
        isExporting: false,
        exportResult: exportResult,
        actionMessage: exportResult.success
            ? 'Audit log exported (${exportResult.count} records).'
            : (exportResult.errorMessage ?? 'Failed to export audit log.'),
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isExporting: false,
        actionMessage: 'Export error: ${e.toString()}',
      ));
    }
  }

  List<AdminVerificationCardModel> _filterCards(
    List<AdminVerificationCardModel> list,
    String category,
    AdminAutoCheckFilterDto filters,
  ) {
    return list.where((card) {
      // Category Tab
      if (card.category != category) return false;

      // Auto-Check Checkboxes (if enabled in UI)
      if (filters.flaggedByAiOnly && !card.flaggedByAi) return false;

      return true;
    }).toList();
  }
}
