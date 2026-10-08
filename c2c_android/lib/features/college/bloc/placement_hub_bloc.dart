import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/placement_drive_model.dart';
import '../domain/models/placement_hub_dashboard_data.dart';
import '../domain/models/college_application_model.dart';
import '../domain/models/eligible_student_model.dart';
import '../data/services/placement_hub_api_service.dart';

// --- Events ---
abstract class PlacementHubEvent extends Equatable {
  const PlacementHubEvent();

  @override
  List<Object?> get props => [];
}

class FetchDrivesEvent extends PlacementHubEvent {
  final String query;
  final String status;
  final String mode;
  final String selectedTab;
  final bool isSilent;

  const FetchDrivesEvent({
    this.query = '',
    this.status = 'All',
    this.mode = 'All',
    this.selectedTab = 'active',
    this.isSilent = false,
  });

  @override
  List<Object?> get props => [query, status, mode, selectedTab, isSilent];
}

class ChangeTabEvent extends PlacementHubEvent {
  final String tab; // 'active' | 'calendar'

  const ChangeTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class CreateDriveEvent extends PlacementHubEvent {
  final Map<String, dynamic> driveData;

  const CreateDriveEvent(this.driveData);

  @override
  List<Object?> get props => [driveData];
}

class UpdateDriveEvent extends PlacementHubEvent {
  final String driveId;
  final Map<String, dynamic> driveData;

  const UpdateDriveEvent({required this.driveId, required this.driveData});

  @override
  List<Object?> get props => [driveId, driveData];
}

class DeleteDriveEvent extends PlacementHubEvent {
  final String driveId;

  const DeleteDriveEvent(this.driveId);

  @override
  List<Object?> get props => [driveId];
}

class NotifyStudentsEvent extends PlacementHubEvent {
  final String message;

  const NotifyStudentsEvent({this.message = 'Broadcast notifications dispatched to eligible candidates!'});

  @override
  List<Object?> get props => [message];
}

class UpdateApplicationStatusEvent extends PlacementHubEvent {
  final String applicationId;
  final String newStatus;

  const UpdateApplicationStatusEvent({
    required this.applicationId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [applicationId, newStatus];
}

class AssignRecruiterEvent extends PlacementHubEvent {
  final String coordinatorName;
  final String driveCycle;

  const AssignRecruiterEvent({
    required this.coordinatorName,
    required this.driveCycle,
  });

  @override
  List<Object?> get props => [coordinatorName, driveCycle];
}

class SearchFilterApplicationsEvent extends PlacementHubEvent {
  final String query;
  final String status;

  const SearchFilterApplicationsEvent({
    required this.query,
    required this.status,
  });

  @override
  List<Object?> get props => [query, status];
}

class SearchFilterEligiblesEvent extends PlacementHubEvent {
  final String query;

  const SearchFilterEligiblesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

// --- States ---
abstract class PlacementHubState extends Equatable {
  const PlacementHubState();

  @override
  List<Object?> get props => [];
}

class PlacementHubInitial extends PlacementHubState {}

class PlacementHubLoading extends PlacementHubState {}

class PlacementHubLoaded extends PlacementHubState {
  final List<PlacementDriveModel> drives;
  final List<CollegeApplicationModel> applications;
  final List<EligibleStudentModel> eligibleStudents;
  final PlacementHubDashboardData dashboardData;
  final String selectedStatus;
  final String selectedMode;
  final String searchQuery;
  final String selectedTab; // 'active' | 'calendar'
  final bool isSubmitting;
  final bool isMock;
  final String? successMessage;
  final String? errorMessage;

  const PlacementHubLoaded({
    required this.drives,
    this.applications = const [],
    this.eligibleStudents = const [],
    required this.dashboardData,
    this.selectedStatus = 'All',
    this.selectedMode = 'All',
    this.searchQuery = '',
    this.selectedTab = 'active',
    this.isSubmitting = false,
    this.isMock = false,
    this.successMessage,
    this.errorMessage,
  });

  PlacementHubLoaded copyWith({
    List<PlacementDriveModel>? drives,
    List<CollegeApplicationModel>? applications,
    List<EligibleStudentModel>? eligibleStudents,
    PlacementHubDashboardData? dashboardData,
    String? selectedStatus,
    String? selectedMode,
    String? searchQuery,
    String? selectedTab,
    bool? isSubmitting,
    bool? isMock,
    String? successMessage,
    String? errorMessage,
  }) {
    return PlacementHubLoaded(
      drives: drives ?? this.drives,
      applications: applications ?? this.applications,
      eligibleStudents: eligibleStudents ?? this.eligibleStudents,
      dashboardData: dashboardData ?? this.dashboardData,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedMode: selectedMode ?? this.selectedMode,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTab: selectedTab ?? this.selectedTab,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isMock: isMock ?? this.isMock,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    drives,
    applications,
    eligibleStudents,
    dashboardData,
    selectedStatus,
    selectedMode,
    searchQuery,
    selectedTab,
    isSubmitting,
    isMock,
    successMessage,
    errorMessage,
  ];
}

class PlacementHubError extends PlacementHubState {
  final String message;

  const PlacementHubError({required this.message});

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class PlacementHubBloc extends Bloc<PlacementHubEvent, PlacementHubState> {
  final PlacementHubApiService _apiService;

  PlacementHubBloc({PlacementHubApiService? apiService})
      : _apiService = apiService ?? PlacementHubApiService(),
        super(PlacementHubInitial()) {
    on<FetchDrivesEvent>(_onFetchDrives);
    on<ChangeTabEvent>(_onChangeTab);
    on<CreateDriveEvent>(_onCreateDrive);
    on<UpdateDriveEvent>(_onUpdateDrive);
    on<DeleteDriveEvent>(_onDeleteDrive);
    on<NotifyStudentsEvent>(_onNotifyStudents);
    on<UpdateApplicationStatusEvent>(_onUpdateApplicationStatus);
    on<AssignRecruiterEvent>(_onAssignRecruiter);
    on<SearchFilterApplicationsEvent>(_onSearchFilterApplications);
    on<SearchFilterEligiblesEvent>(_onSearchFilterEligibles);
  }

  Future<void> _onFetchDrives(
    FetchDrivesEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (!event.isSilent && state is! PlacementHubLoaded) {
      emit(PlacementHubLoading());
    }
    try {
      final dashboardData = await _apiService.fetchDashboardData(tab: event.selectedTab);
      final drives = await _apiService.fetchPlacementDrives(
        query: event.query,
        status: event.status,
      );
      final applications = await _apiService.fetchApplications();
      final eligibleStudents = await _apiService.fetchEligibleStudents();

      final bool isAnyMock = drives.isNotEmpty && drives.any((d) => d.isMock);

      emit(PlacementHubLoaded(
        drives: drives,
        applications: applications,
        eligibleStudents: eligibleStudents,
        dashboardData: dashboardData,
        selectedStatus: event.status,
        selectedMode: event.mode,
        searchQuery: event.query,
        selectedTab: event.selectedTab,
        isMock: isAnyMock,
      ));
    } catch (e) {
      emit(PlacementHubLoaded(
        drives: PlacementDriveModel.mockDrives,
        dashboardData: PlacementHubDashboardData.mockData,
        isMock: true,
        errorMessage: 'Using offline drive roster: ${e.toString().replaceAll("Exception: ", "")}',
      ));
    }
  }

  Future<void> _onChangeTab(
    ChangeTabEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(selectedTab: event.tab));
    }
  }

  Future<void> _onCreateDrive(
    CreateDriveEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));
      try {
        final created = await _apiService.createPlacementDrive(event.driveData);
        final updatedList = [created, ...currentState.drives];
        emit(currentState.copyWith(
          drives: updatedList,
          isSubmitting: false,
          successMessage: 'Recruitment Drive for "${created.companyName}" scheduled successfully!',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onUpdateDrive(
    UpdateDriveEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));
      try {
        await _apiService.updatePlacementDrive(event.driveId, event.driveData);
        final drives = await _apiService.fetchPlacementDrives(
          query: currentState.searchQuery,
          status: currentState.selectedStatus,
        );
        emit(currentState.copyWith(
          drives: drives,
          isSubmitting: false,
          successMessage: 'Placement drive updated in database successfully!',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onDeleteDrive(
    DeleteDriveEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));
      try {
        await _apiService.deletePlacementDrive(event.driveId);
        final updatedDrives = currentState.drives.where((d) => d.id != event.driveId).toList();
        emit(currentState.copyWith(
          drives: updatedDrives,
          isSubmitting: false,
          successMessage: 'Placement drive deleted successfully.',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to remove placement drive.',
        ));
      }
    }
  }

  Future<void> _onNotifyStudents(
    NotifyStudentsEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(
        successMessage: event.message,
      ));
    }
  }

  Future<void> _onUpdateApplicationStatus(
    UpdateApplicationStatusEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));
      try {
        await _apiService.updateApplicationStatus(event.applicationId, event.newStatus);
        final updatedApps = await _apiService.fetchApplications();
        emit(currentState.copyWith(
          applications: updatedApps,
          isSubmitting: false,
          successMessage: 'Candidate status updated to "${event.newStatus}".',
        ));
      } catch (e) {
        emit(currentState.copyWith(
          isSubmitting: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onAssignRecruiter(
    AssignRecruiterEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      emit(currentState.copyWith(isSubmitting: true));

      await _apiService.assignRecruiter(
        coordinatorName: event.coordinatorName,
        driveCycle: event.driveCycle,
      );

      final updatedRecruiters = List<RecruiterAllocationModel>.from(currentState.dashboardData.recruiters)
        ..add(RecruiterAllocationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          companyId: 'c_new',
          initials: event.coordinatorName.isNotEmpty
              ? event.coordinatorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : 'RC',
          name: event.coordinatorName,
          title: 'Assigned Coordinator (${event.driveCycle})',
          activeCount: 1,
        ));

      final newDashboard = PlacementHubDashboardData(
        calendarEvents: currentState.dashboardData.calendarEvents,
        offerPipelines: currentState.dashboardData.offerPipelines,
        recruiters: updatedRecruiters,
        todaysLineup: currentState.dashboardData.todaysLineup,
        activeCyclesCount: currentState.dashboardData.activeCyclesCount + 1,
        totalCandidatesCount: currentState.dashboardData.totalCandidatesCount,
        totalApplicationsCount: currentState.dashboardData.totalApplicationsCount,
        placedCount: currentState.dashboardData.placedCount,
        avgPackage: currentState.dashboardData.avgPackage,
        highestPackage: currentState.dashboardData.highestPackage,
        placementRate: currentState.dashboardData.placementRate,
      );

      emit(currentState.copyWith(
        dashboardData: newDashboard,
        isSubmitting: false,
        successMessage: 'Coordinator assigned to ${event.driveCycle}.',
      ));
    }
  }

  Future<void> _onSearchFilterApplications(
    SearchFilterApplicationsEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      final filteredApps = await _apiService.fetchApplications(
        query: event.query,
        status: event.status,
      );
      emit(currentState.copyWith(applications: filteredApps));
    }
  }

  Future<void> _onSearchFilterEligibles(
    SearchFilterEligiblesEvent event,
    Emitter<PlacementHubState> emit,
  ) async {
    if (state is PlacementHubLoaded) {
      final currentState = state as PlacementHubLoaded;
      final filteredEligibles = await _apiService.fetchEligibleStudents(
        query: event.query,
      );
      emit(currentState.copyWith(eligibleStudents: filteredEligibles));
    }
  }
}
