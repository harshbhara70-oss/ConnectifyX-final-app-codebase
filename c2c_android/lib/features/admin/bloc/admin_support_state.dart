import 'package:equatable/equatable.dart';
import '../data/models/admin_support_models.dart';
import '../data/services/admin_csv_exporter.dart';

abstract class AdminSupportState extends Equatable {
  const AdminSupportState();

  @override
  List<Object?> get props => [];
}

class AdminSupportInitial extends AdminSupportState {}

class AdminSupportLoading extends AdminSupportState {}

class AdminSupportLoaded extends AdminSupportState {
  final AdminSupportStatsModel stats;
  final List<AdminSupportTicketModel> allTickets;
  final List<AdminSupportTicketModel> filteredTickets;
  final String selectedTicketId;
  final String activeFilterMode; // 'all', 'high', 'disputes'
  final String searchQuery;
  final bool isSendingReply;
  final bool isExporting;
  final ExportResult? exportResult;
  final String? toastNotification;

  const AdminSupportLoaded({
    required this.stats,
    required this.allTickets,
    required this.filteredTickets,
    required this.selectedTicketId,
    this.activeFilterMode = 'all',
    this.searchQuery = '',
    this.isSendingReply = false,
    this.isExporting = false,
    this.exportResult,
    this.toastNotification,
  });

  AdminSupportTicketModel? get selectedTicket {
    try {
      return allTickets.firstWhere((t) => t.id == selectedTicketId);
    } catch (_) {
      return allTickets.isNotEmpty ? allTickets.first : null;
    }
  }

  AdminSupportLoaded copyWith({
    AdminSupportStatsModel? stats,
    List<AdminSupportTicketModel>? allTickets,
    List<AdminSupportTicketModel>? filteredTickets,
    String? selectedTicketId,
    String? activeFilterMode,
    String? searchQuery,
    bool? isSendingReply,
    bool? isExporting,
    ExportResult? exportResult,
    String? toastNotification,
    bool clearToast = false,
    bool clearExport = false,
  }) {
    return AdminSupportLoaded(
      stats: stats ?? this.stats,
      allTickets: allTickets ?? this.allTickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      selectedTicketId: selectedTicketId ?? this.selectedTicketId,
      activeFilterMode: activeFilterMode ?? this.activeFilterMode,
      searchQuery: searchQuery ?? this.searchQuery,
      isSendingReply: isSendingReply ?? this.isSendingReply,
      isExporting: isExporting ?? this.isExporting,
      exportResult: clearExport ? null : (exportResult ?? this.exportResult),
      toastNotification: clearToast ? null : (toastNotification ?? this.toastNotification),
    );
  }

  @override
  List<Object?> get props => [
        stats,
        allTickets,
        filteredTickets,
        selectedTicketId,
        activeFilterMode,
        searchQuery,
        isSendingReply,
        isExporting,
        exportResult,
        toastNotification,
      ];
}

class AdminSupportError extends AdminSupportState {
  final String message;

  const AdminSupportError(this.message);

  @override
  List<Object?> get props => [message];
}
