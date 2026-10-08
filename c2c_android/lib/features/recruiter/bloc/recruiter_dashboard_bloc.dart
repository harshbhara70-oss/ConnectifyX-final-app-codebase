import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/recruiter_dashboard_model.dart';
import '../data/repositories/recruiter_repository.dart';

// --- Events ---
abstract class RecruiterDashboardEvent extends Equatable {
  const RecruiterDashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecruiterDashboard extends RecruiterDashboardEvent {
  const FetchRecruiterDashboard();
}

class RefreshRecruiterDashboard extends RecruiterDashboardEvent {
  const RefreshRecruiterDashboard();
}

class FilterJobsChanged extends RecruiterDashboardEvent {
  final String filter; // 'ALL', 'ACTIVE', 'INTERNSHIP', 'FULLTIME'
  const FilterJobsChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateCandidateStageRequested extends RecruiterDashboardEvent {
  final String candidateId;
  final String newStage;

  const UpdateCandidateStageRequested({
    required this.candidateId,
    required this.newStage,
  });

  @override
  List<Object?> get props => [candidateId, newStage];
}

// --- States ---
abstract class RecruiterDashboardState extends Equatable {
  const RecruiterDashboardState();

  @override
  List<Object?> get props => [];
}

class RecruiterDashboardInitial extends RecruiterDashboardState {
  const RecruiterDashboardInitial();
}

class RecruiterDashboardLoading extends RecruiterDashboardState {
  const RecruiterDashboardLoading();
}

class RecruiterDashboardLoaded extends RecruiterDashboardState {
  final RecruiterDashboardData data;
  final String selectedFilter;

  const RecruiterDashboardLoaded({
    required this.data,
    this.selectedFilter = 'ALL',
  });

  List<RecruiterJobItem> get filteredJobs {
    if (selectedFilter == 'ACTIVE') {
      return data.activeJobs.where((j) => j.status == 'ACTIVE').toList();
    } else if (selectedFilter == 'INTERNSHIP') {
      return data.activeJobs.where((j) => j.jobType.toLowerCase().contains('intern')).toList();
    } else if (selectedFilter == 'FULLTIME') {
      return data.activeJobs.where((j) => j.jobType.toLowerCase().contains('full')).toList();
    }
    return data.activeJobs;
  }

  RecruiterDashboardLoaded copyWith({
    RecruiterDashboardData? data,
    String? selectedFilter,
  }) {
    return RecruiterDashboardLoaded(
      data: data ?? this.data,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [data, selectedFilter];
}

class RecruiterDashboardError extends RecruiterDashboardState {
  final String message;
  const RecruiterDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class RecruiterDashboardBloc extends Bloc<RecruiterDashboardEvent, RecruiterDashboardState> {
  final RecruiterRepository _repository;

  RecruiterDashboardBloc({RecruiterRepository? repository})
      : _repository = repository ?? RecruiterRepository(),
        super(const RecruiterDashboardInitial()) {
    on<FetchRecruiterDashboard>(_onFetchDashboard);
    on<RefreshRecruiterDashboard>(_onRefreshDashboard);
    on<FilterJobsChanged>(_onFilterChanged);
    on<UpdateCandidateStageRequested>(_onUpdateCandidateStage);
  }

  Future<void> _onFetchDashboard(
    FetchRecruiterDashboard event,
    Emitter<RecruiterDashboardState> emit,
  ) async {
    emit(const RecruiterDashboardLoading());
    try {
      final data = await _repository.fetchDashboardOverview();
      emit(RecruiterDashboardLoaded(data: data));
    } catch (e) {
      emit(RecruiterDashboardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshRecruiterDashboard event,
    Emitter<RecruiterDashboardState> emit,
  ) async {
    try {
      final data = await _repository.fetchDashboardOverview();
      final currentFilter = state is RecruiterDashboardLoaded
          ? (state as RecruiterDashboardLoaded).selectedFilter
          : 'ALL';
      emit(RecruiterDashboardLoaded(data: data, selectedFilter: currentFilter));
    } catch (e) {
      emit(RecruiterDashboardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onFilterChanged(
    FilterJobsChanged event,
    Emitter<RecruiterDashboardState> emit,
  ) {
    if (state is RecruiterDashboardLoaded) {
      final current = state as RecruiterDashboardLoaded;
      emit(current.copyWith(selectedFilter: event.filter));
    }
  }

  Future<void> _onUpdateCandidateStage(
    UpdateCandidateStageRequested event,
    Emitter<RecruiterDashboardState> emit,
  ) async {
    if (state is RecruiterDashboardLoaded) {
      final current = state as RecruiterDashboardLoaded;
      await _repository.updateCandidateStage(
        candidateId: event.candidateId,
        newStage: event.newStage,
      );

      final updatedRecent = current.data.recentApplications.map((c) {
        if (c.id == event.candidateId) {
          return RecruiterCandidateItem(
            id: c.id,
            name: c.name,
            email: c.email,
            college: c.college,
            branch: c.branch,
            roleApplied: c.roleApplied,
            matchScore: c.matchScore,
            stage: event.newStage,
            resumeUrl: c.resumeUrl,
            appliedAt: c.appliedAt,
          );
        }
        return c;
      }).toList();

      emit(current.copyWith(
        data: current.data.copyWith(recentApplications: updatedRecent),
      ));
    }
  }
}
