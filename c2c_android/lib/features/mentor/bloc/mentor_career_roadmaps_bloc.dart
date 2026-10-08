import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_overview_model.dart';
import '../data/services/mentor_api_service.dart';
import 'mentor_career_roadmaps_event.dart';
import 'mentor_career_roadmaps_state.dart';

class MentorCareerRoadmapsBloc
    extends Bloc<MentorCareerRoadmapsEvent, MentorCareerRoadmapsState> {
  final MentorApiService _api;

  MentorCareerRoadmapsBloc({MentorApiService? api})
      : _api = api ?? MentorApiService(),
        super(const MentorCareerRoadmapsInitial()) {
    on<FetchCareerRoadmapsEvent>(_onFetch);
    on<RefreshCareerRoadmapsEvent>(_onRefresh);
    on<ToggleCareerMilestoneEvent>(_onToggle);
    on<AddCareerMilestoneEvent>(_onAddMilestone);
    on<FilterCareerRoadmapsByStageEvent>(_onFilter);
    on<SearchCareerRoadmapsEvent>(_onSearch);
  }

  // ── Current query state for re-filtering after data updates ───────
  String _currentQuery = '';
  String _currentStage = 'All';

  // ── Fetch ──────────────────────────────────────────────────────────
  Future<void> _onFetch(
    FetchCareerRoadmapsEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) async {
    emit(const MentorCareerRoadmapsLoading());

    _currentQuery = event.query ?? '';
    _currentStage = event.stage ?? 'All';

    final response = await _api.getStudents(
      query: _currentQuery,
      stage: _currentStage,
    );

    final students = response.students;
    final metrics = _computeMetrics(students);
    final filtered = _applyFilters(students, _currentStage, _currentQuery);

    emit(MentorCareerRoadmapsLoaded(
      allStudents: students,
      filteredStudents: filtered,
      selectedStage: _currentStage,
      searchQuery: _currentQuery,
      isMock: response.isMock,
      totalMilestones: metrics.$1,
      completedMilestones: metrics.$2,
      inProgressMilestones: metrics.$3,
      placementReadyCount: metrics.$4,
    ));
  }

  // ── Refresh ────────────────────────────────────────────────────────
  Future<void> _onRefresh(
    RefreshCareerRoadmapsEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) async {
    final currentState = state;
    final query = currentState is MentorCareerRoadmapsLoaded
        ? currentState.searchQuery
        : _currentQuery;
    final stage = currentState is MentorCareerRoadmapsLoaded
        ? currentState.selectedStage
        : _currentStage;

    add(FetchCareerRoadmapsEvent(query: query, stage: stage));
  }

  // ── Toggle Milestone ───────────────────────────────────────────────
  Future<void> _onToggle(
    ToggleCareerMilestoneEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MentorCareerRoadmapsLoaded) return;

    final studentIndex =
        currentState.allStudents.indexWhere((s) => s.id == event.studentId);
    if (studentIndex == -1) return;

    final student = currentState.allStudents[studentIndex];
    if (event.milestoneIndex < 0 ||
        event.milestoneIndex >= student.milestones.length) {
      return;
    }

    emit(currentState.copyWith(
      isUpdating: true,
      updatingStudentId: event.studentId,
    ));

    final updated = await _api.toggleMilestone(
      student: student,
      milestoneIndex: event.milestoneIndex,
    );

    final updatedAll = List<MentorStudentModel>.from(currentState.allStudents);
    updatedAll[studentIndex] = updated;
    final metrics = _computeMetrics(updatedAll);
    final filtered =
        _applyFilters(updatedAll, currentState.selectedStage, currentState.searchQuery);

    emit(currentState.copyWith(
      allStudents: updatedAll,
      filteredStudents: filtered,
      isUpdating: false,
      clearUpdatingId: true,
      totalMilestones: metrics.$1,
      completedMilestones: metrics.$2,
      inProgressMilestones: metrics.$3,
      placementReadyCount: metrics.$4,
      isMock: updated.isMock || currentState.isMock,
    ));
  }

  // ── Add Milestone ──────────────────────────────────────────────────
  Future<void> _onAddMilestone(
    AddCareerMilestoneEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MentorCareerRoadmapsLoaded) return;

    final studentIndex =
        currentState.allStudents.indexWhere((s) => s.id == event.studentId);
    if (studentIndex == -1) return;

    final student = currentState.allStudents[studentIndex];

    emit(currentState.copyWith(
      isUpdating: true,
      updatingStudentId: event.studentId,
    ));

    final updated = await _api.addMilestone(
      student: student,
      name: event.milestoneName,
      status: event.status,
    );

    final updatedAll = List<MentorStudentModel>.from(currentState.allStudents);
    updatedAll[studentIndex] = updated;
    final metrics = _computeMetrics(updatedAll);
    final filtered =
        _applyFilters(updatedAll, currentState.selectedStage, currentState.searchQuery);

    emit(currentState.copyWith(
      allStudents: updatedAll,
      filteredStudents: filtered,
      isUpdating: false,
      clearUpdatingId: true,
      totalMilestones: metrics.$1,
      completedMilestones: metrics.$2,
      inProgressMilestones: metrics.$3,
      placementReadyCount: metrics.$4,
      isMock: updated.isMock || currentState.isMock,
    ));
  }

  // ── Filter by Stage ────────────────────────────────────────────────
  void _onFilter(
    FilterCareerRoadmapsByStageEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentorCareerRoadmapsLoaded) return;

    _currentStage = event.stage;
    final filtered = _applyFilters(
        currentState.allStudents, event.stage, currentState.searchQuery);

    emit(currentState.copyWith(
      filteredStudents: filtered,
      selectedStage: event.stage,
    ));
  }

  // ── Search ─────────────────────────────────────────────────────────
  void _onSearch(
    SearchCareerRoadmapsEvent event,
    Emitter<MentorCareerRoadmapsState> emit,
  ) {
    final currentState = state;
    if (currentState is! MentorCareerRoadmapsLoaded) return;

    _currentQuery = event.query;
    final filtered = _applyFilters(
        currentState.allStudents, currentState.selectedStage, event.query);

    emit(currentState.copyWith(
      filteredStudents: filtered,
      searchQuery: event.query,
    ));
  }

  // ── Private Helpers ────────────────────────────────────────────────
  (int total, int done, int progress, int placementReady) _computeMetrics(
    List<MentorStudentModel> students,
  ) {
    int total = 0;
    int done = 0;
    int progress = 0;
    int placementReady = 0;

    for (final s in students) {
      total += s.milestones.length;
      done += s.milestones.where((m) => m.status == 'done').length;
      progress += s.milestones.where((m) => m.status == 'progress').length;
      if (s.pipelineStage == 'Placement Ready' ||
          s.pipelineStage == 'Hired') {
        placementReady++;
      }
    }

    return (total, done, progress, placementReady);
  }

  List<MentorStudentModel> _applyFilters(
    List<MentorStudentModel> students,
    String stage,
    String query,
  ) {
    var result = List<MentorStudentModel>.from(students);

    if (stage != 'All') {
      result = result.where((s) => s.pipelineStage == stage).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((s) {
        final nameMatch = s.name.toLowerCase().contains(q);
        final roleMatch = s.role.toLowerCase().contains(q);
        final collegeMatch = s.college.toLowerCase().contains(q);
        final milestoneMatch =
            s.milestones.any((m) => m.name.toLowerCase().contains(q));
        return nameMatch || roleMatch || collegeMatch || milestoneMatch;
      }).toList();
    }

    return result;
  }
}
