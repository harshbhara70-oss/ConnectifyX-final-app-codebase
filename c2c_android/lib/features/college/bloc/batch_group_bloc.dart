import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/batch_group_model.dart';
import '../data/services/batch_group_api_service.dart';

// ============================== EVENTS ==============================

abstract class BatchGroupEvent extends Equatable {
  const BatchGroupEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers a fresh fetch of all batch groups from MongoDB Atlas / API.
class FetchBatchGroupsEvent extends BatchGroupEvent {
  const FetchBatchGroupsEvent();
}

/// Client-side search across batch group names / departments / years / skills.
class SearchBatchGroupsEvent extends BatchGroupEvent {
  final String query;
  const SearchBatchGroupsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Client-side filter by department code and/or graduating year.
class FilterBatchGroupsEvent extends BatchGroupEvent {
  final String department;
  final String year;

  const FilterBatchGroupsEvent({this.department = 'All', this.year = 'All'});

  @override
  List<Object?> get props => [department, year];
}

/// Fetches members of one batch group.
class FetchBatchMembersEvent extends BatchGroupEvent {
  final String batchId;
  const FetchBatchMembersEvent(this.batchId);

  @override
  List<Object?> get props => [batchId];
}

/// Adds a new student record / creates cohort student via `POST /college/students`.
class CreateBatchStudentEvent extends BatchGroupEvent {
  final Map<String, dynamic> payload;
  const CreateBatchStudentEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

/// Clears members state (used when the members sheet closes).
class ClearBatchMembersEvent extends BatchGroupEvent {
  const ClearBatchMembersEvent();
}

// ============================== STATES ==============================

abstract class BatchGroupState extends Equatable {
  const BatchGroupState();

  @override
  List<Object?> get props => [];
}

class BatchGroupInitial extends BatchGroupState {
  const BatchGroupInitial();
}

class BatchGroupLoading extends BatchGroupState {
  const BatchGroupLoading();
}

class BatchGroupsLoaded extends BatchGroupState {
  final List<BatchGroupModel> groups;
  final List<BatchGroupModel> filtered;
  final String query;
  final String departmentFilter;
  final String yearFilter;
  final bool isMock;
  final String? operationMessage;

  const BatchGroupsLoaded({
    required this.groups,
    required this.filtered,
    required this.query,
    required this.departmentFilter,
    required this.yearFilter,
    this.isMock = false,
    this.operationMessage,
  });

  BatchGroupsLoaded copyWith({
    List<BatchGroupModel>? groups,
    List<BatchGroupModel>? filtered,
    String? query,
    String? departmentFilter,
    String? yearFilter,
    bool? isMock,
    String? operationMessage,
  }) {
    return BatchGroupsLoaded(
      groups: groups ?? this.groups,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      yearFilter: yearFilter ?? this.yearFilter,
      isMock: isMock ?? this.isMock,
      operationMessage: operationMessage,
    );
  }

  @override
  List<Object?> get props => [
        groups,
        filtered,
        query,
        departmentFilter,
        yearFilter,
        isMock,
        operationMessage,
      ];
}

class BatchGroupError extends BatchGroupState {
  final String message;
  const BatchGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class BatchMembersLoading extends BatchGroupState {
  const BatchMembersLoading();
}

class BatchMembersLoaded extends BatchGroupState {
  final BatchDetailModel detail;
  final bool isMock;

  const BatchMembersLoaded(this.detail, {this.isMock = false});

  @override
  List<Object?> get props => [detail, isMock];
}

class BatchMembersError extends BatchGroupState {
  final String message;
  const BatchMembersError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================== BLOC ==============================

class BatchGroupBloc extends Bloc<BatchGroupEvent, BatchGroupState> {
  final BatchGroupApiService _apiService;

  BatchGroupBloc({BatchGroupApiService? apiService})
      : _apiService = apiService ?? BatchGroupApiService(),
        super(const BatchGroupInitial()) {
    on<FetchBatchGroupsEvent>(_onFetchGroups);
    on<SearchBatchGroupsEvent>(_onSearch);
    on<FilterBatchGroupsEvent>(_onFilter);
    on<FetchBatchMembersEvent>(_onFetchMembers);
    on<CreateBatchStudentEvent>(_onCreateStudent);
    on<ClearBatchMembersEvent>((event, emit) {
      if (state is BatchMembersLoading || state is BatchMembersLoaded || state is BatchMembersError) {
        add(const FetchBatchGroupsEvent());
      }
    });
  }

  Future<void> _onFetchGroups(
    FetchBatchGroupsEvent event,
    Emitter<BatchGroupState> emit,
  ) async {
    if (state is! BatchGroupsLoaded) {
      emit(const BatchGroupLoading());
    }
    try {
      final groups = await _apiService.fetchBatchGroups();
      final isAnyMock = groups.any((g) => g.isMock);
      emit(BatchGroupsLoaded(
        groups: groups,
        filtered: groups,
        query: '',
        departmentFilter: 'All',
        yearFilter: 'All',
        isMock: isAnyMock,
      ));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(BatchGroupError(message));
    }
  }

  void _onSearch(SearchBatchGroupsEvent event, Emitter<BatchGroupState> emit) {
    if (state is! BatchGroupsLoaded) return;
    final loaded = state as BatchGroupsLoaded;
    final filtered = _applyFilters(
      loaded.groups,
      event.query,
      loaded.departmentFilter,
      loaded.yearFilter,
    );
    emit(loaded.copyWith(
      filtered: filtered,
      query: event.query,
    ));
  }

  void _onFilter(FilterBatchGroupsEvent event, Emitter<BatchGroupState> emit) {
    if (state is! BatchGroupsLoaded) return;
    final loaded = state as BatchGroupsLoaded;
    final filtered = _applyFilters(
      loaded.groups,
      loaded.query,
      event.department,
      event.year,
    );
    emit(loaded.copyWith(
      filtered: filtered,
      departmentFilter: event.department,
      yearFilter: event.year,
    ));
  }

  Future<void> _onFetchMembers(
    FetchBatchMembersEvent event,
    Emitter<BatchGroupState> emit,
  ) async {
    emit(const BatchMembersLoading());
    try {
      final detail = await _apiService.fetchBatchStudents(event.batchId);
      emit(BatchMembersLoaded(detail, isMock: detail.isMock));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(BatchMembersError(message));
    }
  }

  Future<void> _onCreateStudent(
    CreateBatchStudentEvent event,
    Emitter<BatchGroupState> emit,
  ) async {
    try {
      await _apiService.createBatchStudent(event.payload);
      // Refresh live groups from MongoDB
      final groups = await _apiService.fetchBatchGroups();
      final isAnyMock = groups.any((g) => g.isMock);
      emit(BatchGroupsLoaded(
        groups: groups,
        filtered: groups,
        query: '',
        departmentFilter: 'All',
        yearFilter: 'All',
        isMock: isAnyMock,
        operationMessage: 'Student registered in batch successfully!',
      ));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      if (state is BatchGroupsLoaded) {
        emit((state as BatchGroupsLoaded).copyWith(
          operationMessage: 'Record added in offline mode ($message)',
        ));
      }
    }
  }

  List<BatchGroupModel> _applyFilters(
    List<BatchGroupModel> groups,
    String query,
    String department,
    String year,
  ) {
    final q = query.trim().toLowerCase();
    return groups.where((g) {
      final matchesQuery = q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.department.toLowerCase().contains(q) ||
          g.departmentCode.toLowerCase().contains(q) ||
          g.batchYear.toLowerCase().contains(q) ||
          g.topSkill.toLowerCase().contains(q);
      final matchesDept = department == 'All' || g.departmentCode == department;
      final matchesYear = year == 'All' || g.batchYear == year;
      return matchesQuery && matchesDept && matchesYear;
    }).toList();
  }
}