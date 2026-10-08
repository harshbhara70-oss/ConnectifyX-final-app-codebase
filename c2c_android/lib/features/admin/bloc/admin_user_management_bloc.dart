import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_user_models.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_user_management_event.dart';
import 'admin_user_management_state.dart';

class AdminUserManagementBloc extends Bloc<AdminUserManagementEvent, AdminUserManagementState> {
  final AdminApiService _apiService;

  AdminUserManagementBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminUserManagementState()) {
    on<FetchAdminUsers>(_onFetchAdminUsers);
    on<SelectRoleTab>(_onSelectRoleTab);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<UpdateCollegeFilter>(_onUpdateCollegeFilter);
    on<UpdateYearFilter>(_onUpdateYearFilter);
    on<UpdateStatusFilter>(_onUpdateStatusFilter);
    on<ToggleSelectUserItem>(_onToggleSelectUserItem);
    on<ToggleSelectAllUserItems>(_onToggleSelectAllUserItems);
    on<ChangeDirectoryPage>(_onChangeDirectoryPage);
    on<ToggleSuspendUser>(_onToggleSuspendUser);
    on<DeleteUserAction>(_onDeleteUserAction);
    on<UpdateStudentAction>(_onUpdateStudentAction);
    on<UpdateCollegeAction>(_onUpdateCollegeAction);
    on<UpdateRecruiterAction>(_onUpdateRecruiterAction);
    on<CreateCollegeAction>(_onCreateCollegeAction);
    on<CreateRecruiterAction>(_onCreateRecruiterAction);
    on<BulkSuspendAction>(_onBulkSuspendAction);
    on<BulkDeleteAction>(_onBulkDeleteAction);
    on<ExportDirectoryAction>(_onExportDirectoryAction);
  }

  Future<void> _onFetchAdminUsers(
    FetchAdminUsers event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: AdminUserStatus.loading));
    }

    try {
      final results = await Future.wait([
        _apiService.fetchStudents(),
        _apiService.fetchColleges(),
        _apiService.fetchRecruiters(),
      ]);

      final students = results[0] as List<AdminStudentModel>;
      final colleges = results[1] as List<AdminCollegeModel>;
      final recruiters = results[2] as List<AdminRecruiterModel>;

      // If any source had to fall back to mock data, mark as mock
      final bool isMockData = students.any((s) => s.isMock) ||
          colleges.any((c) => c.isMock) ||
          recruiters.any((r) => r.isMock);

      emit(state.copyWith(
        status: AdminUserStatus.loaded,
        students: students,
        colleges: colleges,
        recruiters: recruiters,
        isMock: isMockData,
        selectedUserIds: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminUserStatus.failure,
        errorMessage: 'Failed to fetch directory data: ${e.toString()}',
      ));
    }
  }

  void _onSelectRoleTab(
    SelectRoleTab event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(
      activeTab: event.tab,
      currentPage: 1,
      selectedUserIds: {},
    ));
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
    ));
  }

  void _onUpdateCollegeFilter(
    UpdateCollegeFilter event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(
      selectedCollegeFilter: event.college,
      currentPage: 1,
    ));
  }

  void _onUpdateYearFilter(
    UpdateYearFilter event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(
      selectedYearFilter: event.year,
      currentPage: 1,
    ));
  }

  void _onUpdateStatusFilter(
    UpdateStatusFilter event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(
      selectedStatusFilter: event.status,
      currentPage: 1,
    ));
  }

  void _onToggleSelectUserItem(
    ToggleSelectUserItem event,
    Emitter<AdminUserManagementState> emit,
  ) {
    final updated = Set<String>.from(state.selectedUserIds);
    if (updated.contains(event.userId)) {
      updated.remove(event.userId);
    } else {
      updated.add(event.userId);
    }
    emit(state.copyWith(selectedUserIds: updated));
  }

  void _onToggleSelectAllUserItems(
    ToggleSelectAllUserItems event,
    Emitter<AdminUserManagementState> emit,
  ) {
    final Set<String> visibleIds = {};
    switch (state.activeTab) {
      case UserRoleTab.students:
        for (final s in state.paginatedStudents) {
          visibleIds.add(s.id);
        }
        break;
      case UserRoleTab.colleges:
        for (final c in state.paginatedColleges) {
          visibleIds.add(c.id);
        }
        break;
      case UserRoleTab.recruiters:
        for (final r in state.paginatedRecruiters) {
          visibleIds.add(r.id);
        }
        break;
    }

    final bool allSelected = visibleIds.isNotEmpty &&
        visibleIds.every((id) => state.selectedUserIds.contains(id));

    final updated = Set<String>.from(state.selectedUserIds);
    if (allSelected) {
      updated.removeAll(visibleIds);
    } else {
      updated.addAll(visibleIds);
    }
    emit(state.copyWith(selectedUserIds: updated));
  }

  void _onChangeDirectoryPage(
    ChangeDirectoryPage event,
    Emitter<AdminUserManagementState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  Future<void> _onToggleSuspendUser(
    ToggleSuspendUser event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final bool willSuspend = event.currentStatus.toLowerCase() == 'active';
    final newStatus = willSuspend ? 'Suspended' : 'Active';

    if (event.role == UserRoleTab.students) {
      final updatedList = state.students.map((s) {
        if (s.id == event.id) {
          return s.copyWith(activeStatus: newStatus);
        }
        return s;
      }).toList();
      emit(state.copyWith(
        students: updatedList,
        feedbackMessage: 'Student status updated to $newStatus',
      ));
      _apiService.updateStudent(event.id, {'status': newStatus});
    } else if (event.role == UserRoleTab.colleges) {
      final updatedList = state.colleges.map((c) {
        if (c.id == event.id) {
          return c.copyWith(status: newStatus);
        }
        return c;
      }).toList();
      emit(state.copyWith(
        colleges: updatedList,
        feedbackMessage: 'College status updated to $newStatus',
      ));
      _apiService.updateCollege(event.id, {'status': newStatus});
    } else {
      final updatedList = state.recruiters.map((r) {
        if (r.id == event.id) {
          return r.copyWith(status: newStatus);
        }
        return r;
      }).toList();
      emit(state.copyWith(
        recruiters: updatedList,
        feedbackMessage: 'Recruiter status updated to $newStatus',
      ));
      _apiService.updateRecruiter(event.id, {'status': newStatus});
    }
  }

  Future<void> _onDeleteUserAction(
    DeleteUserAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    if (event.role == UserRoleTab.students) {
      final updated = state.students.where((s) => s.id != event.id).toList();
      emit(state.copyWith(
        students: updated,
        feedbackMessage: 'Student deleted successfully',
      ));
      _apiService.deleteStudent(event.id);
    } else if (event.role == UserRoleTab.colleges) {
      final updated = state.colleges.where((c) => c.id != event.id).toList();
      emit(state.copyWith(
        colleges: updated,
        feedbackMessage: 'College deleted successfully',
      ));
      _apiService.deleteCollege(event.id);
    } else {
      final updated = state.recruiters.where((r) => r.id != event.id).toList();
      emit(state.copyWith(
        recruiters: updated,
        feedbackMessage: 'Recruiter deleted successfully',
      ));
      _apiService.deleteRecruiter(event.id);
    }
  }

  Future<void> _onUpdateStudentAction(
    UpdateStudentAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final updatedList = state.students.map((s) {
      if (s.id == event.id) {
        return s.copyWith(
          name: event.data['name']?.toString() ?? s.name,
          email: event.data['email']?.toString() ?? s.email,
          college: event.data['college']?.toString() ?? s.college,
          branch: event.data['branch']?.toString() ?? s.branch,
          cgpa: event.data['cgpa']?.toString() ?? s.cgpa,
          placementStatus: event.data['placementStatus']?.toString() ?? s.placementStatus,
          activeStatus: event.data['status']?.toString() ?? s.activeStatus,
          phone: event.data['phone']?.toString() ?? s.phone,
        );
      }
      return s;
    }).toList();

    emit(state.copyWith(
      students: updatedList,
      feedbackMessage: 'Student record updated',
    ));
    _apiService.updateStudent(event.id, event.data);
  }

  Future<void> _onUpdateCollegeAction(
    UpdateCollegeAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final updatedList = state.colleges.map((c) {
      if (c.id == event.id) {
        return c.copyWith(
          name: event.data['name']?.toString() ?? c.name,
          email: event.data['email']?.toString() ?? c.email,
          university: event.data['university']?.toString() ?? c.university,
          city: event.data['city']?.toString() ?? c.city,
          phone: event.data['phone']?.toString() ?? c.phone,
          status: event.data['status']?.toString() ?? c.status,
          website: event.data['website']?.toString() ?? c.website,
        );
      }
      return c;
    }).toList();

    emit(state.copyWith(
      colleges: updatedList,
      feedbackMessage: 'College record updated',
    ));
    _apiService.updateCollege(event.id, event.data);
  }

  Future<void> _onUpdateRecruiterAction(
    UpdateRecruiterAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final updatedList = state.recruiters.map((r) {
      if (r.id == event.id) {
        return r.copyWith(
          name: event.data['name']?.toString() ?? r.name,
          email: event.data['email']?.toString() ?? r.email,
          company: event.data['company']?.toString() ?? r.company,
          designation: event.data['designation']?.toString() ?? r.designation,
          phone: event.data['phone']?.toString() ?? r.phone,
          status: event.data['status']?.toString() ?? r.status,
          linkedin: event.data['linkedin']?.toString() ?? r.linkedin,
        );
      }
      return r;
    }).toList();

    emit(state.copyWith(
      recruiters: updatedList,
      feedbackMessage: 'Recruiter record updated',
    ));
    _apiService.updateRecruiter(event.id, event.data);
  }

  Future<void> _onCreateCollegeAction(
    CreateCollegeAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final newCol = AdminCollegeModel(
      id: 'col_${DateTime.now().millisecondsSinceEpoch}',
      name: event.data['name']?.toString() ?? 'New College',
      email: event.data['email']?.toString() ?? '',
      university: event.data['university']?.toString() ?? 'State University',
      city: event.data['city']?.toString() ?? 'Bengaluru',
      phone: event.data['phone']?.toString() ?? '',
      status: 'Active',
      isMock: state.isMock,
    );

    emit(state.copyWith(
      colleges: [newCol, ...state.colleges],
      feedbackMessage: 'New College registered successfully',
    ));
    _apiService.createCollege(event.data);
  }

  Future<void> _onCreateRecruiterAction(
    CreateRecruiterAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    final newRec = AdminRecruiterModel(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      name: event.data['name']?.toString() ?? 'New Recruiter',
      email: event.data['email']?.toString() ?? '',
      company: event.data['company']?.toString() ?? 'Enterprise Co',
      designation: event.data['designation']?.toString() ?? 'Campus HR',
      phone: event.data['phone']?.toString() ?? '',
      status: 'Active',
      isMock: state.isMock,
    );

    emit(state.copyWith(
      recruiters: [newRec, ...state.recruiters],
      feedbackMessage: 'New Recruiter onboarded successfully',
    ));
    _apiService.createRecruiter(event.data);
  }

  void _onBulkSuspendAction(
    BulkSuspendAction event,
    Emitter<AdminUserManagementState> emit,
  ) {
    final selected = state.selectedUserIds;
    if (selected.isEmpty) return;

    if (state.activeTab == UserRoleTab.students) {
      final updated = state.students.map((s) {
        if (selected.contains(s.id)) {
          return s.copyWith(activeStatus: 'Suspended');
        }
        return s;
      }).toList();
      emit(state.copyWith(
        students: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} students suspended',
      ));
    } else if (state.activeTab == UserRoleTab.colleges) {
      final updated = state.colleges.map((c) {
        if (selected.contains(c.id)) {
          return c.copyWith(status: 'Suspended');
        }
        return c;
      }).toList();
      emit(state.copyWith(
        colleges: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} colleges suspended',
      ));
    } else {
      final updated = state.recruiters.map((r) {
        if (selected.contains(r.id)) {
          return r.copyWith(status: 'Suspended');
        }
        return r;
      }).toList();
      emit(state.copyWith(
        recruiters: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} recruiters suspended',
      ));
    }
  }

  void _onBulkDeleteAction(
    BulkDeleteAction event,
    Emitter<AdminUserManagementState> emit,
  ) {
    final selected = state.selectedUserIds;
    if (selected.isEmpty) return;

    if (state.activeTab == UserRoleTab.students) {
      final updated = state.students.where((s) => !selected.contains(s.id)).toList();
      emit(state.copyWith(
        students: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} students deleted',
      ));
    } else if (state.activeTab == UserRoleTab.colleges) {
      final updated = state.colleges.where((c) => !selected.contains(c.id)).toList();
      emit(state.copyWith(
        colleges: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} colleges deleted',
      ));
    } else {
      final updated = state.recruiters.where((r) => !selected.contains(r.id)).toList();
      emit(state.copyWith(
        recruiters: updated,
        selectedUserIds: {},
        feedbackMessage: '${selected.length} recruiters deleted',
      ));
    }
  }

  Future<void> _onExportDirectoryAction(
    ExportDirectoryAction event,
    Emitter<AdminUserManagementState> emit,
  ) async {
    List<dynamic> itemsToExport = [];
    switch (state.activeTab) {
      case UserRoleTab.students:
        itemsToExport = event.onlySelected
            ? state.filteredStudents.where((s) => state.selectedUserIds.contains(s.id)).toList()
            : state.filteredStudents;
        break;
      case UserRoleTab.colleges:
        itemsToExport = event.onlySelected
            ? state.filteredColleges.where((c) => state.selectedUserIds.contains(c.id)).toList()
            : state.filteredColleges;
        break;
      case UserRoleTab.recruiters:
        itemsToExport = event.onlySelected
            ? state.filteredRecruiters.where((r) => state.selectedUserIds.contains(r.id)).toList()
            : state.filteredRecruiters;
        break;
    }

    if (itemsToExport.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'No records available to export.',
      ));
      return;
    }

    final result = await AdminCsvExporter.exportToCsvFile(
      role: state.activeTab,
      items: itemsToExport,
      onlySelected: event.onlySelected,
    );

    if (result.success) {
      emit(state.copyWith(
        lastExportResult: result,
        feedbackMessage: 'Exported ${result.count} ${state.activeTab.label} records to ${result.fileName}',
      ));
    } else {
      emit(state.copyWith(
        errorMessage: result.errorMessage ?? 'Failed to export records.',
      ));
    }
  }
}
