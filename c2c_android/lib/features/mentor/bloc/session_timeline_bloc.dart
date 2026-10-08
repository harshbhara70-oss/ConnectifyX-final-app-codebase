import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_overview_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'session_timeline_event.dart';
import 'session_timeline_state.dart';

class SessionTimelineBloc extends Bloc<SessionTimelineEvent, SessionTimelineState> {
  final MentorRepository _mentorRepository;

  SessionTimelineBloc({MentorRepository? mentorRepository})
      : _mentorRepository = mentorRepository ?? MentorRepository(),
        super(const SessionTimelineInitial()) {
    on<FetchSessionTimelineEvent>(_onFetchSessionTimeline);
    on<FilterSessionCategoryEvent>(_onFilterCategory);
    on<FilterSessionDayEvent>(_onFilterDay);
    on<SearchSessionsEvent>(_onSearchSessions);
    on<CreateSessionSlotEvent>(_onCreateSessionSlot);
    on<CancelSessionSlotEvent>(_onCancelSessionSlot);
    on<ResolveAlertEvent>(_onResolveAlert);
  }

  Future<void> _onFetchSessionTimeline(
    FetchSessionTimelineEvent event,
    Emitter<SessionTimelineState> emit,
  ) async {
    emit(const SessionTimelineLoading());

    try {
      final results = await _mentorRepository.getSessionTimelineData();
      final students = await _mentorRepository.getStudentAnalytics();

      emit(SessionTimelineLoaded(
        allSessions: results.sessions,
        filteredSessions: results.sessions,
        alerts: results.alerts,
        availableStudents: students,
        isMock: results.isMock,
      ));
    } catch (e) {
      emit(SessionTimelineError('Failed to load session timeline: ${e.toString()}'));
    }
  }

  void _onFilterCategory(
    FilterSessionCategoryEvent event,
    Emitter<SessionTimelineState> emit,
  ) {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    final filtered = _applyFilters(
      all: current.allSessions,
      category: event.category,
      day: current.selectedDay,
      query: current.searchQuery,
    );

    emit(current.copyWith(
      selectedCategory: event.category,
      filteredSessions: filtered,
    ));
  }

  void _onFilterDay(
    FilterSessionDayEvent event,
    Emitter<SessionTimelineState> emit,
  ) {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    final filtered = _applyFilters(
      all: current.allSessions,
      category: current.selectedCategory,
      day: event.day,
      query: current.searchQuery,
    );

    emit(current.copyWith(
      selectedDay: event.day,
      filteredSessions: filtered,
    ));
  }

  void _onSearchSessions(
    SearchSessionsEvent event,
    Emitter<SessionTimelineState> emit,
  ) {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    final filtered = _applyFilters(
      all: current.allSessions,
      category: current.selectedCategory,
      day: current.selectedDay,
      query: event.query,
    );

    emit(current.copyWith(
      searchQuery: event.query,
      filteredSessions: filtered,
    ));
  }

  Future<void> _onCreateSessionSlot(
    CreateSessionSlotEvent event,
    Emitter<SessionTimelineState> emit,
  ) async {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    emit(current.copyWith(isCreatingSession: true));

    final savedSession = await _mentorRepository.createSession(event.session);
    final updatedAll = [savedSession, ...current.allSessions];

    final filtered = _applyFilters(
      all: updatedAll,
      category: current.selectedCategory,
      day: current.selectedDay,
      query: current.searchQuery,
    );

    emit(current.copyWith(
      allSessions: updatedAll,
      filteredSessions: filtered,
      isCreatingSession: false,
      feedbackMessage: 'Session slot scheduled with ${event.session.studentName}',
    ));
  }

  Future<void> _onCancelSessionSlot(
    CancelSessionSlotEvent event,
    Emitter<SessionTimelineState> emit,
  ) async {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    await _mentorRepository.deleteSession(event.sessionId);

    final updatedAll = current.allSessions.where((s) => s.id != event.sessionId).toList();
    final filtered = _applyFilters(
      all: updatedAll,
      category: current.selectedCategory,
      day: current.selectedDay,
      query: current.searchQuery,
    );

    emit(current.copyWith(
      allSessions: updatedAll,
      filteredSessions: filtered,
      feedbackMessage: 'Session booking slot cancelled',
    ));
  }

  Future<void> _onResolveAlert(
    ResolveAlertEvent event,
    Emitter<SessionTimelineState> emit,
  ) async {
    if (state is! SessionTimelineLoaded) return;
    final current = state as SessionTimelineLoaded;

    await _mentorRepository.resolveActionPriorityItem(event.alertId);

    final updatedAlerts = current.alerts.map((a) {
      if (a.id == event.alertId) {
        return a.copyWith(isResolved: true);
      }
      return a;
    }).toList();

    emit(current.copyWith(
      alerts: updatedAlerts,
      feedbackMessage: 'Operational alert marked as resolved',
    ));
  }

  List<MentorSessionModel> _applyFilters({
    required List<MentorSessionModel> all,
    required String category,
    required String day,
    required String query,
  }) {
    return all.where((session) {
      final matchesCategory = category == 'All' ||
          session.type.toLowerCase().trim() == category.toLowerCase().trim();

      final matchesDay = day == 'All' ||
          session.date.toLowerCase().contains(day.toLowerCase()) ||
          session.day.toLowerCase() == day.toLowerCase();

      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          session.studentName.toLowerCase().contains(q) ||
          session.type.toLowerCase().contains(q) ||
          session.time.toLowerCase().contains(q) ||
          session.date.toLowerCase().contains(q);

      return matchesCategory && matchesDay && matchesQuery;
    }).toList();
  }
}
