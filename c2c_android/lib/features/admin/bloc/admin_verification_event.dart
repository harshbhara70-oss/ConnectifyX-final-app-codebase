import 'package:equatable/equatable.dart';

abstract class AdminVerificationEvent extends Equatable {
  const AdminVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial Verification Queue data
class FetchVerificationQueueData extends AdminVerificationEvent {
  final bool isRefresh;

  const FetchVerificationQueueData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Switch active tab ('colleges', 'recruiters', 'flagged')
class ChangeVerificationTab extends AdminVerificationEvent {
  final String tab;

  const ChangeVerificationTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Toggle auto-check filter checkboxes
class ToggleAutoCheckFilter extends AdminVerificationEvent {
  final bool? domainVerified;
  final bool? docsProvided;
  final bool? flaggedByAi;

  const ToggleAutoCheckFilter({
    this.domainVerified,
    this.docsProvided,
    this.flaggedByAi,
  });

  @override
  List<Object?> get props => [domainVerified, docsProvided, flaggedByAi];
}

/// Approve / Quick Verify an item
class ApproveVerificationItem extends AdminVerificationEvent {
  final String id;

  const ApproveVerificationItem(this.id);

  @override
  List<Object?> get props => [id];
}

/// Reject an item
class RejectVerificationItem extends AdminVerificationEvent {
  final String id;

  const RejectVerificationItem(this.id);

  @override
  List<Object?> get props => [id];
}

/// Request Info from an item's submitter
class RequestVerificationInfoItem extends AdminVerificationEvent {
  final String id;
  final String query;

  const RequestVerificationInfoItem(this.id, this.query);

  @override
  List<Object?> get props => [id, query];
}

/// Export Audit Log to CSV
class ExportVerificationAuditLog extends AdminVerificationEvent {
  const ExportVerificationAuditLog();
}
