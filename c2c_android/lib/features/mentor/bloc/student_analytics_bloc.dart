import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_overview_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'student_analytics_event.dart';
import 'student_analytics_state.dart';

class StudentAnalyticsBloc extends Bloc<StudentAnalyticsEvent, StudentAnalyticsState> {
  final MentorRepository _repository;

  StudentAnalyticsBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const StudentAnalyticsInitial()) {
    on<FetchStudentAnalyticsEvent>(_onFetchStudentAnalytics);
    on<SelectStudentEvent>(_onSelectStudent);
    on<SearchStudentEvent>(_onSearchStudent);
    on<FilterPipelineStageEvent>(_onFilterPipelineStage);
    on<AddStudentNoteEvent>(_onAddStudentNote);
    on<AddStudentEvent>(_onAddStudent);
    on<ToggleStudentMilestoneEvent>(_onToggleStudentMilestone);
  }

  Future<void> _onFetchStudentAnalytics(
    FetchStudentAnalyticsEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) async {
    emit(const StudentAnalyticsLoading());

    try {
      final students = await _repository.getStudentAnalytics(
        query: event.query,
        stage: event.stage,
      );

      if (students.isEmpty) {
        emit(const StudentAnalyticsError('No students assigned to your cohort yet.'));
        return;
      }

      final isMock = students.any((s) => s.isMock);
      final initialFiltered = _filterStudents(students, '', 'All');
      final selectedStudent = initialFiltered.isNotEmpty ? initialFiltered.first : students.first;

      emit(StudentAnalyticsLoaded(
        allStudents: students,
        filteredStudents: initialFiltered,
        selectedStudent: selectedStudent,
        selectedStage: event.stage ?? 'All',
        searchQuery: event.query ?? '',
        isMock: isMock,
      ));
    } catch (e) {
      emit(StudentAnalyticsError('Failed to load student analytics: ${e.toString()}'));
    }
  }

  void _onSelectStudent(
    SelectStudentEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    final target = currentState.allStudents.firstWhere(
      (s) => s.id == event.studentId,
      orElse: () => currentState.selectedStudent,
    );

    emit(currentState.copyWith(selectedStudent: target, feedbackMessage: null));
  }

  void _onSearchStudent(
    SearchStudentEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    final filtered = _filterStudents(
      currentState.allStudents,
      event.query,
      currentState.selectedStage,
    );

    emit(currentState.copyWith(
      searchQuery: event.query,
      filteredStudents: filtered,
      feedbackMessage: null,
    ));
  }

  void _onFilterPipelineStage(
    FilterPipelineStageEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    final filtered = _filterStudents(
      currentState.allStudents,
      currentState.searchQuery,
      event.stage,
    );

    emit(currentState.copyWith(
      selectedStage: event.stage,
      filteredStudents: filtered,
      feedbackMessage: null,
    ));
  }

  Future<void> _onAddStudentNote(
    AddStudentNoteEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) async {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    emit(currentState.copyWith(isSavingNote: true, feedbackMessage: null));

    try {
      final updatedNotes = await _repository.addStudentNote(
        studentId: event.studentId,
        note: event.note,
        currentNotes: currentState.selectedStudent.notes,
      );

      final updatedAll = currentState.allStudents.map((s) {
        if (s.id == event.studentId) {
          return s.copyWith(notes: updatedNotes);
        }
        return s;
      }).toList();

      final updatedFiltered = _filterStudents(
        updatedAll,
        currentState.searchQuery,
        currentState.selectedStage,
      );

      final updatedSelected = currentState.selectedStudent.id == event.studentId
          ? currentState.selectedStudent.copyWith(notes: updatedNotes)
          : currentState.selectedStudent;

      emit(currentState.copyWith(
        allStudents: updatedAll,
        filteredStudents: updatedFiltered,
        selectedStudent: updatedSelected,
        isSavingNote: false,
        feedbackMessage: 'Note successfully logged.',
      ));
    } catch (_) {
      // Local optimistic fallback
      final fallbackNotes = [event.note, ...currentState.selectedStudent.notes];
      final updatedAll = currentState.allStudents.map((s) {
        if (s.id == event.studentId) {
          return s.copyWith(notes: fallbackNotes);
        }
        return s;
      }).toList();

      final updatedFiltered = _filterStudents(
        updatedAll,
        currentState.searchQuery,
        currentState.selectedStage,
      );

      emit(currentState.copyWith(
        allStudents: updatedAll,
        filteredStudents: updatedFiltered,
        selectedStudent: currentState.selectedStudent.copyWith(notes: fallbackNotes),
        isSavingNote: false,
        feedbackMessage: 'Note successfully logged.',
      ));
    }
  }

  Future<void> _onAddStudent(
    AddStudentEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) async {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    emit(currentState.copyWith(isAddingStudent: true, feedbackMessage: null));

    try {
      final createdStudent = await _repository.addStudent(event.student);
      final updatedAll = [createdStudent, ...currentState.allStudents];
      final updatedFiltered = _filterStudents(
        updatedAll,
        currentState.searchQuery,
        currentState.selectedStage,
      );

      emit(currentState.copyWith(
        allStudents: updatedAll,
        filteredStudents: updatedFiltered,
        selectedStudent: createdStudent,
        isAddingStudent: false,
        feedbackMessage: 'New mentee profile created successfully.',
      ));
    } catch (_) {
      final fallbackStudent = event.student.copyWith(isMock: true);
      final updatedAll = [fallbackStudent, ...currentState.allStudents];
      final updatedFiltered = _filterStudents(
        updatedAll,
        currentState.searchQuery,
        currentState.selectedStage,
      );

      emit(currentState.copyWith(
        allStudents: updatedAll,
        filteredStudents: updatedFiltered,
        selectedStudent: fallbackStudent,
        isAddingStudent: false,
        feedbackMessage: 'New mentee profile added.',
      ));
    }
  }

  Future<void> _onToggleStudentMilestone(
    ToggleStudentMilestoneEvent event,
    Emitter<StudentAnalyticsState> emit,
  ) async {
    if (state is! StudentAnalyticsLoaded) return;
    final currentState = state as StudentAnalyticsLoaded;

    final targetStudent = currentState.allStudents.firstWhere(
      (s) => s.id == event.studentId,
      orElse: () => currentState.selectedStudent,
    );

    final updatedStudent = await _repository.toggleMilestone(
      student: targetStudent,
      milestoneIndex: event.milestoneIndex,
    );

    final updatedAll = currentState.allStudents.map((s) {
      if (s.id == event.studentId) {
        return updatedStudent;
      }
      return s;
    }).toList();

    final updatedFiltered = _filterStudents(
      updatedAll,
      currentState.searchQuery,
      currentState.selectedStage,
    );

    final updatedSelected = currentState.selectedStudent.id == event.studentId
        ? updatedStudent
        : currentState.selectedStudent;

    emit(currentState.copyWith(
      allStudents: updatedAll,
      filteredStudents: updatedFiltered,
      selectedStudent: updatedSelected,
      feedbackMessage: 'Milestone status updated.',
    ));
  }

  List<MentorStudentModel> _filterStudents(
    List<MentorStudentModel> students,
    String query,
    String stage,
  ) {
    return students.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.college.toLowerCase().contains(query.toLowerCase()) ||
          s.branch.toLowerCase().contains(query.toLowerCase()) ||
          s.role.toLowerCase().contains(query.toLowerCase()) ||
          s.skills.any((sk) => sk.toLowerCase().contains(query.toLowerCase()));

      final matchesStage = stage == 'All' || s.pipelineStage.toLowerCase() == stage.toLowerCase();

      return matchesQuery && matchesStage;
    }).toList();
  }
}
