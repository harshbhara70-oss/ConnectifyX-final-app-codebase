import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/candidate_application_model.dart';
import '../data/repositories/applications_reports_repository.dart';

// ===================== EVENTS =====================
abstract class ApplicationsReportsEvent extends Equatable {
  const ApplicationsReportsEvent();
  @override
  List<Object?> get props => [];
}

class FetchApplicationsReports extends ApplicationsReportsEvent {
  const FetchApplicationsReports();
}

class RefreshApplicationsReports extends ApplicationsReportsEvent {
  const RefreshApplicationsReports();
}

class ChangeApplicationsFilter extends ApplicationsReportsEvent {
  final String filter; // ALL | ELIGIBLE | SHORTLISTED | CONTACTED | INTERVIEW | OFFER
  const ChangeApplicationsFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class SearchApplicationsQueryChanged extends ApplicationsReportsEvent {
  final String query;
  const SearchApplicationsQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ShortlistCandidateAction extends ApplicationsReportsEvent {
  final String candidateId;
  const ShortlistCandidateAction(this.candidateId);
  @override
  List<Object?> get props => [candidateId];
}

// ===================== STATES =====================
abstract class ApplicationsReportsState extends Equatable {
  const ApplicationsReportsState();
  @override
  List<Object?> get props => [];
}

class ApplicationsReportsInitial extends ApplicationsReportsState {
  const ApplicationsReportsInitial();
}

class ApplicationsReportsLoading extends ApplicationsReportsState {
  const ApplicationsReportsLoading();
}

class ApplicationsReportsLoaded extends ApplicationsReportsState {
  final List<CandidateAppItem> candidates;
  final String selectedFilter; // ALL | ELIGIBLE | SHORTLISTED | CONTACTED | INTERVIEW | OFFER
  final String searchQuery;
  final bool isUpdating;
  final bool isMock;

  const ApplicationsReportsLoaded({
    required this.candidates,
    this.selectedFilter = 'ALL',
    this.searchQuery = '',
    this.isUpdating = false,
    this.isMock = false,
  });

  List<CandidateAppItem> get filteredCandidates {
    return candidates.where((c) {
      // 1. Stage filter
      bool matchesStage = true;
      if (selectedFilter == 'ELIGIBLE') {
        matchesStage = c.stage == 'eligible';
      } else if (selectedFilter == 'SHORTLISTED') {
        matchesStage = c.stage == 'shortlisted';
      } else if (selectedFilter == 'CONTACTED') {
        matchesStage = c.stage == 'contacted';
      } else if (selectedFilter == 'INTERVIEW') {
        matchesStage = c.stage == 'interview';
      } else if (selectedFilter == 'OFFER') {
        matchesStage = c.stage == 'offer';
      }

      if (!matchesStage) return false;

      // 2. Search query filter
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesRole = (c.jobTitle ?? c.role).toLowerCase().contains(q);
        final matchesCollege = c.college.toLowerCase().contains(q);
        return matchesName || matchesRole || matchesCollege;
      }

      return true;
    }).toList();
  }

  int get eligibleCount => candidates.where((c) => c.stage == 'eligible').length;
  int get shortlistedCount => candidates.where((c) => c.stage == 'shortlisted').length;
  int get contactedCount => candidates.where((c) => c.stage == 'contacted').length;
  int get interviewCount => candidates.where((c) => c.stage == 'interview').length;
  int get offerCount => candidates.where((c) => c.stage == 'offer').length;

  ApplicationsReportsLoaded copyWith({
    List<CandidateAppItem>? candidates,
    String? selectedFilter,
    String? searchQuery,
    bool? isUpdating,
    bool? isMock,
  }) {
    return ApplicationsReportsLoaded(
      candidates: candidates ?? this.candidates,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isUpdating: isUpdating ?? this.isUpdating,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [candidates, selectedFilter, searchQuery, isUpdating, isMock];
}

class ApplicationsReportsEmpty extends ApplicationsReportsState {
  final String selectedFilter;
  final bool isMock;
  const ApplicationsReportsEmpty({this.selectedFilter = 'ALL', this.isMock = false});
  @override
  List<Object?> get props => [selectedFilter, isMock];
}

class ApplicationsReportsError extends ApplicationsReportsState {
  final String message;
  const ApplicationsReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===================== BLOC =====================
class ApplicationsReportsBloc extends Bloc<ApplicationsReportsEvent, ApplicationsReportsState> {
  final ApplicationsReportsRepository _repository;

  ApplicationsReportsBloc({ApplicationsReportsRepository? repository})
      : _repository = repository ?? ApplicationsReportsRepository(),
        super(const ApplicationsReportsInitial()) {
    on<FetchApplicationsReports>(_onFetch);
    on<RefreshApplicationsReports>(_onRefresh);
    on<ChangeApplicationsFilter>(_onFilterChange);
    on<SearchApplicationsQueryChanged>(_onSearchQuery);
    on<ShortlistCandidateAction>(_onShortlistCandidate);
  }

  Future<void> _onFetch(FetchApplicationsReports event, Emitter<ApplicationsReportsState> emit) async {
    emit(const ApplicationsReportsLoading());
    try {
      final list = await _repository.fetchApplications();
      final isAnyMock = list.any((c) => c.isMock);
      if (list.isEmpty) {
        emit(ApplicationsReportsEmpty(isMock: isAnyMock));
      } else {
        emit(ApplicationsReportsLoaded(candidates: list, isMock: isAnyMock));
      }
    } catch (e) {
      emit(ApplicationsReportsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshApplicationsReports event, Emitter<ApplicationsReportsState> emit) async {
    try {
      final list = await _repository.fetchApplications();
      final isAnyMock = list.any((c) => c.isMock);
      if (list.isEmpty) {
        emit(ApplicationsReportsEmpty(isMock: isAnyMock));
      } else {
        final cur = state;
        if (cur is ApplicationsReportsLoaded) {
          emit(cur.copyWith(candidates: list, isMock: isAnyMock));
        } else {
          emit(ApplicationsReportsLoaded(candidates: list, isMock: isAnyMock));
        }
      }
    } catch (e) {
      emit(ApplicationsReportsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onFilterChange(ChangeApplicationsFilter event, Emitter<ApplicationsReportsState> emit) {
    if (state is ApplicationsReportsLoaded) {
      final cur = state as ApplicationsReportsLoaded;
      emit(cur.copyWith(selectedFilter: event.filter));
    } else if (state is ApplicationsReportsEmpty) {
      final cur = state as ApplicationsReportsEmpty;
      emit(ApplicationsReportsEmpty(selectedFilter: event.filter, isMock: cur.isMock));
    }
  }

  void _onSearchQuery(SearchApplicationsQueryChanged event, Emitter<ApplicationsReportsState> emit) {
    if (state is ApplicationsReportsLoaded) {
      final cur = state as ApplicationsReportsLoaded;
      emit(cur.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onShortlistCandidate(ShortlistCandidateAction event, Emitter<ApplicationsReportsState> emit) async {
    if (state is! ApplicationsReportsLoaded) return;
    final cur = state as ApplicationsReportsLoaded;
    emit(cur.copyWith(isUpdating: true));
    try {
      await _repository.shortlistCandidate(event.candidateId);
      final updated = cur.candidates.map((c) {
        return c.id == event.candidateId ? c.copyWith(stage: 'shortlisted') : c;
      }).toList();
      emit(cur.copyWith(candidates: updated, isUpdating: false));
    } catch (e) {
      emit(ApplicationsReportsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
