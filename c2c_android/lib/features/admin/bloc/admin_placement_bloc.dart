import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_placement_models.dart';
import '../data/services/admin_api_service.dart';
import '../data/services/admin_csv_exporter.dart';
import 'admin_placement_event.dart';
import 'admin_placement_state.dart';

class AdminPlacementBloc extends Bloc<AdminPlacementEvent, AdminPlacementState> {
  final AdminApiService _apiService;

  AdminPlacementBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminPlacementInitial()) {
    on<FetchPlacementData>(_onFetchPlacementData);
    on<SearchPlacementDrives>(_onSearchPlacementDrives);
    on<FilterPlacementDrives>(_onFilterPlacementDrives);
    on<ResetPlacementFilters>(_onResetPlacementFilters);
    on<ChangeCalendarMonth>(_onChangeCalendarMonth);
    on<CreatePlacementDrive>(_onCreatePlacementDrive);
    on<UpdatePlacementDrive>(_onUpdatePlacementDrive);
    on<DeletePlacementDrive>(_onDeletePlacementDrive);
    on<ExportPlacementReport>(_onExportPlacementReport);
  }

  Future<void> _onFetchPlacementData(
    FetchPlacementData event,
    Emitter<AdminPlacementState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const AdminPlacementLoading());
    }

    try {
      final metrics = await _apiService.fetchPlacementMetrics();
      final drives = await _apiService.fetchPlacementDrives();
      final events = await _apiService.fetchPlacementEvents();

      final collegesSet = <String>{'all'};
      final companiesSet = <String>{'all'};

      for (final d in drives) {
        if (d.college.trim().isNotEmpty) collegesSet.add(d.college.trim());
        if (d.company.trim().isNotEmpty) companiesSet.add(d.company.trim());
      }

      final filters = const AdminPlacementFilterDto();

      emit(AdminPlacementLoaded(
        metrics: metrics,
        allDrives: drives,
        filteredDrives: drives,
        events: events,
        filters: filters,
        currentMonth: DateTime.now(),
        availableColleges: collegesSet.toList(),
        availableCompanies: companiesSet.toList(),
      ));
    } catch (e) {
      emit(AdminPlacementError('Failed to load placement oversight: ${e.toString()}'));
    }
  }

  void _onSearchPlacementDrives(
    SearchPlacementDrives event,
    Emitter<AdminPlacementState> emit,
  ) {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;
    final updatedFilters = currentState.filters.copyWith(searchQuery: event.query);
    final filtered = _applyFilters(currentState.allDrives, updatedFilters);

    emit(currentState.copyWith(
      filters: updatedFilters,
      filteredDrives: filtered,
    ));
  }

  void _onFilterPlacementDrives(
    FilterPlacementDrives event,
    Emitter<AdminPlacementState> emit,
  ) {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;
    final updatedFilters = currentState.filters.copyWith(
      selectedCollege: event.college,
      selectedCompany: event.company,
      selectedType: event.type,
      selectedStatus: event.status,
      dateQuery: event.dateQuery,
    );
    final filtered = _applyFilters(currentState.allDrives, updatedFilters);

    emit(currentState.copyWith(
      filters: updatedFilters,
      filteredDrives: filtered,
    ));
  }

  void _onResetPlacementFilters(
    ResetPlacementFilters event,
    Emitter<AdminPlacementState> emit,
  ) {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;
    const defaultFilters = AdminPlacementFilterDto();

    emit(currentState.copyWith(
      filters: defaultFilters,
      filteredDrives: currentState.allDrives,
    ));
  }

  void _onChangeCalendarMonth(
    ChangeCalendarMonth event,
    Emitter<AdminPlacementState> emit,
  ) {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;
    emit(currentState.copyWith(currentMonth: event.month));
  }

  Future<void> _onCreatePlacementDrive(
    CreatePlacementDrive event,
    Emitter<AdminPlacementState> emit,
  ) async {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;

    try {
      final newDrive = await _apiService.createPlacementDrive(event.driveData);
      final updatedAll = [newDrive, ...currentState.allDrives];

      final collegesSet = Set<String>.from(currentState.availableColleges);
      final companiesSet = Set<String>.from(currentState.availableCompanies);
      if (newDrive.college.isNotEmpty) collegesSet.add(newDrive.college);
      if (newDrive.company.isNotEmpty) companiesSet.add(newDrive.company);

      final filtered = _applyFilters(updatedAll, currentState.filters);

      emit(currentState.copyWith(
        allDrives: updatedAll,
        filteredDrives: filtered,
        availableColleges: collegesSet.toList(),
        availableCompanies: companiesSet.toList(),
        actionMessage: 'Drive for ${newDrive.company} (${newDrive.role}) posted successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        actionMessage: 'Failed to create drive: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdatePlacementDrive(
    UpdatePlacementDrive event,
    Emitter<AdminPlacementState> emit,
  ) async {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;

    try {
      final updatedDrive = await _apiService.updatePlacementDrive(event.id, event.driveData);
      final updatedAll = currentState.allDrives.map((d) {
        return d.id == event.id ? updatedDrive : d;
      }).toList();

      final filtered = _applyFilters(updatedAll, currentState.filters);

      emit(currentState.copyWith(
        allDrives: updatedAll,
        filteredDrives: filtered,
        actionMessage: 'Placement drive updated successfully.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        actionMessage: 'Failed to update drive: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeletePlacementDrive(
    DeletePlacementDrive event,
    Emitter<AdminPlacementState> emit,
  ) async {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;

    try {
      await _apiService.deletePlacementDrive(event.id);
      final updatedAll = currentState.allDrives.where((d) => d.id != event.id).toList();
      final filtered = _applyFilters(updatedAll, currentState.filters);

      emit(currentState.copyWith(
        allDrives: updatedAll,
        filteredDrives: filtered,
        actionMessage: 'Drive record removed from oversight.',
      ));
    } catch (e) {
      emit(currentState.copyWith(
        actionMessage: 'Failed to delete drive: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportPlacementReport(
    ExportPlacementReport event,
    Emitter<AdminPlacementState> emit,
  ) async {
    if (state is! AdminPlacementLoaded) return;
    final currentState = state as AdminPlacementLoaded;

    emit(currentState.copyWith(isExporting: true, clearExportResult: true));

    try {
      final exportResult = await AdminCsvExporter.exportPlacementReportToCsvFile(
        drives: currentState.filteredDrives,
        metrics: currentState.metrics,
      );

      emit(currentState.copyWith(
        isExporting: false,
        exportResult: exportResult,
        actionMessage: exportResult.success
            ? 'Placement report exported (${exportResult.count} drives).'
            : (exportResult.errorMessage ?? 'Failed to export report.'),
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isExporting: false,
        actionMessage: 'Export error: ${e.toString()}',
      ));
    }
  }

  List<AdminPlacementDriveModel> _applyFilters(
    List<AdminPlacementDriveModel> list,
    AdminPlacementFilterDto filters,
  ) {
    return list.where((drive) {
      // 1. Search Query
      if (filters.searchQuery.isNotEmpty) {
        final q = filters.searchQuery.toLowerCase();
        final matchCompany = drive.company.toLowerCase().contains(q);
        final matchCollege = drive.college.toLowerCase().contains(q);
        final matchRole = drive.role.toLowerCase().contains(q);
        final matchType = drive.type.toLowerCase().contains(q);
        final matchStatus = drive.status.toLowerCase().contains(q);
        if (!matchCompany && !matchCollege && !matchRole && !matchType && !matchStatus) {
          return false;
        }
      }

      // 2. College filter
      if (filters.selectedCollege != 'all') {
        if (!drive.college.toLowerCase().contains(filters.selectedCollege.toLowerCase())) {
          return false;
        }
      }

      // 3. Company filter
      if (filters.selectedCompany != 'all') {
        if (!drive.company.toLowerCase().contains(filters.selectedCompany.toLowerCase())) {
          return false;
        }
      }

      // 4. Type filter
      if (filters.selectedType != 'all') {
        if (drive.type.toLowerCase() != filters.selectedType.toLowerCase()) {
          return false;
        }
      }

      // 5. Status filter
      if (filters.selectedStatus != 'all') {
        if (drive.status.toLowerCase() != filters.selectedStatus.toLowerCase()) {
          return false;
        }
      }

      // 6. Date Query
      if (filters.dateQuery.isNotEmpty) {
        if (!drive.deadline.toLowerCase().contains(filters.dateQuery.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
