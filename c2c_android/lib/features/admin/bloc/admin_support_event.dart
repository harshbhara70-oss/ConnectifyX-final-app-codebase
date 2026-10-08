import 'package:equatable/equatable.dart';

abstract class AdminSupportEvent extends Equatable {
  const AdminSupportEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or pull-to-refresh
class FetchSupportDataEvent extends AdminSupportEvent {
  final bool isRefresh;

  const FetchSupportDataEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Selects active ticket for inspector view
class SelectSupportTicketEvent extends AdminSupportEvent {
  final String ticketId;

  const SelectSupportTicketEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Filter mode ('all', 'high', 'disputes') and search query change
class FilterSupportTicketsEvent extends AdminSupportEvent {
  final String? filterMode;
  final String? searchQuery;

  const FilterSupportTicketsEvent({this.filterMode, this.searchQuery});

  @override
  List<Object?> get props => [filterMode, searchQuery];
}

/// Dispatches a reply to the selected ticket
class SendTicketReplyEvent extends AdminSupportEvent {
  final String ticketId;
  final String text;
  final bool isInternalNote;

  const SendTicketReplyEvent({
    required this.ticketId,
    required this.text,
    required this.isInternalNote,
  });

  @override
  List<Object?> get props => [ticketId, text, isInternalNote];
}

/// Toggles ticket resolution status
class ToggleTicketResolutionEvent extends AdminSupportEvent {
  final String ticketId;

  const ToggleTicketResolutionEvent(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Assigns ticket to support personnel
class AssignTicketEvent extends AdminSupportEvent {
  final String ticketId;
  final String assignee;

  const AssignTicketEvent({
    required this.ticketId,
    required this.assignee,
  });

  @override
  List<Object?> get props => [ticketId, assignee];
}

/// Creates a new support inquiry / dispute ticket
class CreateSupportTicketEvent extends AdminSupportEvent {
  final Map<String, dynamic> ticketData;

  const CreateSupportTicketEvent(this.ticketData);

  @override
  List<Object?> get props => [ticketData];
}

/// Exports support tickets audit log
class ExportSupportTicketsEvent extends AdminSupportEvent {
  const ExportSupportTicketsEvent();
}
