import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_support_models.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_support_event.dart';
import 'admin_support_state.dart';

class AdminSupportBloc extends Bloc<AdminSupportEvent, AdminSupportState> {
  final AdminApiService _apiService;

  AdminSupportBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(AdminSupportInitial()) {
    on<FetchSupportDataEvent>(_onFetchSupportData);
    on<SelectSupportTicketEvent>(_onSelectTicket);
    on<FilterSupportTicketsEvent>(_onFilterTickets);
    on<SendTicketReplyEvent>(_onSendReply);
    on<ToggleTicketResolutionEvent>(_onToggleResolution);
    on<AssignTicketEvent>(_onAssignTicket);
    on<CreateSupportTicketEvent>(_onCreateTicket);
    on<ExportSupportTicketsEvent>(_onExportTickets);
  }

  List<AdminSupportTicketModel> _applyFilters(
    List<AdminSupportTicketModel> tickets,
    String filterMode,
    String query,
  ) {
    var result = tickets;

    // Filter mode
    if (filterMode == 'high') {
      result = result.where((t) => t.priority == 'Critical Priority' || t.priority == 'Escalated').toList();
    } else if (filterMode == 'disputes') {
      result = result.where((t) => t.type.toLowerCase().contains('dispute')).toList();
    }

    // Search query
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((t) {
        return t.id.toLowerCase().contains(q) ||
            t.title.toLowerCase().contains(q) ||
            t.requester.toLowerCase().contains(q) ||
            t.organization.toLowerCase().contains(q) ||
            t.type.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  Future<void> _onFetchSupportData(
    FetchSupportDataEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(AdminSupportLoading());
    }

    try {
      final data = await _apiService.fetchSupportData();
      final defaultSelectedId = data.tickets.isNotEmpty ? data.tickets.first.id : '';
      final filtered = _applyFilters(data.tickets, 'all', '');

      emit(AdminSupportLoaded(
        stats: data.stats,
        allTickets: data.tickets,
        filteredTickets: filtered,
        selectedTicketId: defaultSelectedId,
        activeFilterMode: 'all',
        searchQuery: '',
      ));
    } catch (e) {
      emit(AdminSupportError('Failed to load support tickets: ${e.toString()}'));
    }
  }

  void _onSelectTicket(
    SelectSupportTicketEvent event,
    Emitter<AdminSupportState> emit,
  ) {
    if (state is AdminSupportLoaded) {
      final loaded = state as AdminSupportLoaded;
      emit(loaded.copyWith(
        selectedTicketId: event.ticketId,
        clearToast: true,
      ));
    }
  }

  void _onFilterTickets(
    FilterSupportTicketsEvent event,
    Emitter<AdminSupportState> emit,
  ) {
    if (state is AdminSupportLoaded) {
      final loaded = state as AdminSupportLoaded;
      final mode = event.filterMode ?? loaded.activeFilterMode;
      final query = event.searchQuery ?? loaded.searchQuery;
      final filtered = _applyFilters(loaded.allTickets, mode, query);

      emit(loaded.copyWith(
        activeFilterMode: mode,
        searchQuery: query,
        filteredTickets: filtered,
        clearToast: true,
      ));
    }
  }

  Future<void> _onSendReply(
    SendTicketReplyEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (state is! AdminSupportLoaded) return;
    final loaded = state as AdminSupportLoaded;

    emit(loaded.copyWith(isSendingReply: true, clearToast: true));

    final newMsg = AdminSupportMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'Admin Staff',
      senderRole: 'Administrator',
      timestamp: 'Just now',
      content: event.text.trim(),
      isInternalNote: event.isInternalNote,
    );

    final updatedTickets = loaded.allTickets.map((t) {
      if (t.id == event.ticketId) {
        return t.copyWith(
          messages: [...t.messages, newMsg],
          status: 'in_progress',
        );
      }
      return t;
    }).toList();

    await _apiService.sendTicketReply(
      ticketId: event.ticketId,
      message: event.text,
      isInternalNote: event.isInternalNote,
    );

    final filtered = _applyFilters(updatedTickets, loaded.activeFilterMode, loaded.searchQuery);

    emit(loaded.copyWith(
      allTickets: updatedTickets,
      filteredTickets: filtered,
      isSendingReply: false,
      toastNotification: event.isInternalNote ? 'Internal note appended to ticket.' : 'Response sent successfully to user.',
    ));
  }

  Future<void> _onToggleResolution(
    ToggleTicketResolutionEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (state is! AdminSupportLoaded) return;
    final loaded = state as AdminSupportLoaded;

    var newStatus = 'resolved';
    final target = loaded.allTickets.firstWhere((t) => t.id == event.ticketId, orElse: () => loaded.allTickets.first);
    final isCurrentlyResolved = target.status == 'resolved';
    if (isCurrentlyResolved) {
      newStatus = 'open';
    }

    final updatedTickets = loaded.allTickets.map((t) {
      if (t.id == event.ticketId) {
        return t.copyWith(status: newStatus);
      }
      return t;
    }).toList();

    await _apiService.toggleTicketResolution(
      ticketId: event.ticketId,
      isResolved: !isCurrentlyResolved,
    );

    // Recalculate stats counters
    final openCount = updatedTickets.where((t) => t.status == 'open').length;
    final inProgCount = updatedTickets.where((t) => t.status == 'in_progress').length;
    final resCount = updatedTickets.where((t) => t.status == 'resolved').length;

    final updatedStats = AdminSupportStatsModel(
      openCount: loaded.stats.isMock ? (isCurrentlyResolved ? loaded.stats.openCount + 1 : loaded.stats.openCount - 1) : openCount,
      inProgressCount: inProgCount,
      resolvedCount: loaded.stats.isMock ? (isCurrentlyResolved ? loaded.stats.resolvedCount - 1 : loaded.stats.resolvedCount + 1) : resCount,
      isMock: loaded.stats.isMock,
    );

    final filtered = _applyFilters(updatedTickets, loaded.activeFilterMode, loaded.searchQuery);

    emit(loaded.copyWith(
      stats: updatedStats,
      allTickets: updatedTickets,
      filteredTickets: filtered,
      toastNotification: isCurrentlyResolved ? 'Ticket #${target.id} re-opened.' : 'Ticket #${target.id} marked as Resolved.',
    ));
  }

  Future<void> _onAssignTicket(
    AssignTicketEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (state is! AdminSupportLoaded) return;
    final loaded = state as AdminSupportLoaded;

    final updatedTickets = loaded.allTickets.map((t) {
      if (t.id == event.ticketId) {
        return t.copyWith(assignedTo: event.assignee);
      }
      return t;
    }).toList();

    await _apiService.assignTicket(
      ticketId: event.ticketId,
      assignee: event.assignee,
    );

    final filtered = _applyFilters(updatedTickets, loaded.activeFilterMode, loaded.searchQuery);

    emit(loaded.copyWith(
      allTickets: updatedTickets,
      filteredTickets: filtered,
      toastNotification: 'Ticket assigned to ${event.assignee}.',
    ));
  }

  Future<void> _onCreateTicket(
    CreateSupportTicketEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (state is! AdminSupportLoaded) return;
    final loaded = state as AdminSupportLoaded;

    emit(loaded.copyWith(isSendingReply: true, clearToast: true));

    final newTicket = await _apiService.createSupportTicket(event.ticketData);
    if (newTicket != null) {
      final updatedTickets = [newTicket, ...loaded.allTickets];
      final filtered = _applyFilters(updatedTickets, loaded.activeFilterMode, loaded.searchQuery);

      emit(loaded.copyWith(
        allTickets: updatedTickets,
        filteredTickets: filtered,
        selectedTicketId: newTicket.id,
        isSendingReply: false,
        stats: AdminSupportStatsModel(
          openCount: loaded.stats.openCount + 1,
          inProgressCount: loaded.stats.inProgressCount,
          resolvedCount: loaded.stats.resolvedCount,
          isMock: loaded.stats.isMock,
        ),
        toastNotification: 'Ticket #${newTicket.id} created successfully.',
      ));
    }
  }

  Future<void> _onExportTickets(
    ExportSupportTicketsEvent event,
    Emitter<AdminSupportState> emit,
  ) async {
    if (state is! AdminSupportLoaded) return;
    final loaded = state as AdminSupportLoaded;

    emit(loaded.copyWith(isExporting: true, clearToast: true, clearExport: true));

    final result = await AdminCsvExporter.exportSupportTicketsToCsvFile(loaded.allTickets);

    emit(loaded.copyWith(
      isExporting: false,
      exportResult: result,
      toastNotification: 'Support report exported (${result.count} tickets).',
    ));
  }
}
