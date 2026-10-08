import 'package:equatable/equatable.dart';
import '../data/models/admin_user_models.dart';

abstract class AdminUserManagementEvent extends Equatable {
  const AdminUserManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger fetching all students, colleges, and recruiters from MongoDB Atlas
class FetchAdminUsers extends AdminUserManagementEvent {
  final bool isRefresh;
  const FetchAdminUsers({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Switch active tab: Students | Colleges | Recruiters
class SelectRoleTab extends AdminUserManagementEvent {
  final UserRoleTab tab;
  const SelectRoleTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Update global search keyword
class UpdateSearchQuery extends AdminUserManagementEvent {
  final String query;
  const UpdateSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

/// Update college filter
class UpdateCollegeFilter extends AdminUserManagementEvent {
  final String college;
  const UpdateCollegeFilter(this.college);

  @override
  List<Object?> get props => [college];
}

/// Update year filter
class UpdateYearFilter extends AdminUserManagementEvent {
  final String year;
  const UpdateYearFilter(this.year);

  @override
  List<Object?> get props => [year];
}

/// Update status filter (all | active | suspended)
class UpdateStatusFilter extends AdminUserManagementEvent {
  final String status;
  const UpdateStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

/// Toggle selection of a single item for bulk actions
class ToggleSelectUserItem extends AdminUserManagementEvent {
  final String userId;
  const ToggleSelectUserItem(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Toggle selection of all items on current view
class ToggleSelectAllUserItems extends AdminUserManagementEvent {
  const ToggleSelectAllUserItems();
}

/// Change pagination page
class ChangeDirectoryPage extends AdminUserManagementEvent {
  final int page;
  const ChangeDirectoryPage(this.page);

  @override
  List<Object?> get props => [page];
}

/// Toggle suspension of user / institution / recruiter
class ToggleSuspendUser extends AdminUserManagementEvent {
  final String id;
  final UserRoleTab role;
  final String currentStatus;

  const ToggleSuspendUser({
    required this.id,
    required this.role,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [id, role, currentStatus];
}

/// Delete a specific user / institution / recruiter record
class DeleteUserAction extends AdminUserManagementEvent {
  final String id;
  final UserRoleTab role;

  const DeleteUserAction({
    required this.id,
    required this.role,
  });

  @override
  List<Object?> get props => [id, role];
}

/// Update Student Record
class UpdateStudentAction extends AdminUserManagementEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateStudentAction({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

/// Update College Record
class UpdateCollegeAction extends AdminUserManagementEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateCollegeAction({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

/// Update Recruiter Record
class UpdateRecruiterAction extends AdminUserManagementEvent {
  final String id;
  final Map<String, dynamic> data;

  const UpdateRecruiterAction({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

/// Create new College Record
class CreateCollegeAction extends AdminUserManagementEvent {
  final Map<String, dynamic> data;
  const CreateCollegeAction(this.data);

  @override
  List<Object?> get props => [data];
}

/// Create new Recruiter Record
class CreateRecruiterAction extends AdminUserManagementEvent {
  final Map<String, dynamic> data;
  const CreateRecruiterAction(this.data);

  @override
  List<Object?> get props => [data];
}

/// Perform bulk suspend on selected items
class BulkSuspendAction extends AdminUserManagementEvent {
  const BulkSuspendAction();
}

/// Perform bulk delete on selected items
class BulkDeleteAction extends AdminUserManagementEvent {
  const BulkDeleteAction();
}

/// Export directory records (All or Selected)
class ExportDirectoryAction extends AdminUserManagementEvent {
  final bool onlySelected;
  const ExportDirectoryAction({this.onlySelected = false});

  @override
  List<Object?> get props => [onlySelected];
}
