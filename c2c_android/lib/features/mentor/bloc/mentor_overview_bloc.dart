import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_overview_event.dart';
import 'mentor_overview_state.dart';

class MentorOverviewBloc extends Bloc<MentorOverviewEvent, MentorOverviewState> {
  final MentorRepository _repository;

  MentorOverviewBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const MentorOverviewInitial()) {
    on<FetchMentorOverviewEvent>(_onFetchMentorOverview);
    on<RefreshMentorOverviewEvent>(_onRefreshMentorOverview);
    on<FilterMentorOverviewEvent>(_onFilterMentorOverview);
    on<CreateSessionSlotEvent>(_onCreateSessionSlot);
  }

  Future<void> _onFetchMentorOverview(
    FetchMentorOverviewEvent event,
    Emitter<MentorOverviewState> emit,
  ) async {
    emit(const MentorOverviewLoading());
    try {
      final data = await _repository.getMentorOverview();
      emit(MentorOverviewLoaded(
        data: data,
        filteredStudents: data.students,
      ));
    } catch (e) {
      emit(MentorOverviewError(e.toString()));
    }
  }

  Future<void> _onRefreshMentorOverview(
    RefreshMentorOverviewEvent event,
    Emitter<MentorOverviewState> emit,
  ) async {
    try {
      final data = await _repository.getMentorOverview();
      final currentQuery = state is MentorOverviewLoaded
          ? (state as MentorOverviewLoaded).searchQuery
          : '';

      final filtered = currentQuery.isEmpty
          ? data.students
          : data.students
              .where((s) =>
                  s.name.toLowerCase().contains(currentQuery.toLowerCase()) ||
                  s.college.toLowerCase().contains(currentQuery.toLowerCase()) ||
                  s.role.toLowerCase().contains(currentQuery.toLowerCase()))
              .toList();

      emit(MentorOverviewLoaded(
        data: data,
        searchQuery: currentQuery,
        filteredStudents: filtered,
      ));
    } catch (e) {
      emit(MentorOverviewError(e.toString()));
    }
  }

  void _onFilterMentorOverview(
    FilterMentorOverviewEvent event,
    Emitter<MentorOverviewState> emit,
  ) {
    if (state is MentorOverviewLoaded) {
      final current = state as MentorOverviewLoaded;
      final query = event.query.trim().toLowerCase();

      final filtered = query.isEmpty
          ? current.data.students
          : current.data.students
              .where((s) =>
                  s.name.toLowerCase().contains(query) ||
                  s.college.toLowerCase().contains(query) ||
                  s.role.toLowerCase().contains(query) ||
                  s.pipelineStage.toLowerCase().contains(query) ||
                  s.skills.any((sk) => sk.toLowerCase().contains(query)))
              .toList();

      emit(current.copyWith(
        searchQuery: event.query,
        filteredStudents: filtered,
      ));
    }
  }

  Future<void> _onCreateSessionSlot(
    CreateSessionSlotEvent event,
    Emitter<MentorOverviewState> emit,
  ) async {
    if (state is MentorOverviewLoaded) {
      final current = state as MentorOverviewLoaded;
      try {
        final newSession = await _repository.createSession(event.session);
        final updatedSessions = [newSession, ...current.data.sessions];
        final updatedData = current.data.copyWith(sessions: updatedSessions);

        emit(current.copyWith(data: updatedData));
      } catch (_) {
        // Optimistic local update
        final updatedSessions = [event.session, ...current.data.sessions];
        final updatedData = current.data.copyWith(sessions: updatedSessions);
        emit(current.copyWith(data: updatedData));
      }
    }
  }
}
