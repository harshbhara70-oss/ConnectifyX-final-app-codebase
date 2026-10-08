import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_feedback_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_feedback_event.dart';
import 'mentor_feedback_state.dart';

class MentorFeedbackBloc extends Bloc<MentorFeedbackEvent, MentorFeedbackState> {
  final MentorRepository _repository;

  MentorFeedbackBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const FeedbackInitial()) {
    on<FetchFeedbackDataEvent>(_onFetchData);
    on<SelectCandidateEvent>(_onSelectCandidate);
    on<ChangeTechRatingEvent>(_onChangeTechRating);
    on<ChangeCommRatingEvent>(_onChangeCommRating);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
    on<SearchFeedbackHistoryEvent>(_onSearch);
    on<FilterFeedbackHistoryEvent>(_onFilter);
  }

  Future<void> _onFetchData(
    FetchFeedbackDataEvent event,
    Emitter<MentorFeedbackState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const FeedbackLoading());
    }
    try {
      final payload = await _repository.getFeedbackData();
      final initialCandidate = payload.students.isNotEmpty
          ? payload.students.first.name
          : 'Rahul Sharma';

      final filtered = _filter(
        all: payload.feedbacks,
        query: '',
        filter: 'all',
      );

      emit(FeedbackLoaded(
        data: payload,
        selectedCandidate: initialCandidate,
        selectedTechRating: 4,
        selectedCommRating: 4,
        filteredFeedbacks: filtered,
        searchQuery: '',
        selectedFilter: 'all',
      ));
    } catch (e) {
      emit(FeedbackError('Failed to load feedback records: ${e.toString()}'));
    }
  }

  void _onSelectCandidate(
    SelectCandidateEvent event,
    Emitter<MentorFeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      emit(current.copyWith(selectedCandidate: event.candidateName));
    }
  }

  void _onChangeTechRating(
    ChangeTechRatingEvent event,
    Emitter<MentorFeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      emit(current.copyWith(selectedTechRating: event.rating));
    }
  }

  void _onChangeCommRating(
    ChangeCommRatingEvent event,
    Emitter<MentorFeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      emit(current.copyWith(selectedCommRating: event.rating));
    }
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<MentorFeedbackState> emit,
  ) async {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      emit(current.copyWith(isSubmitting: true));

      // Find matching student info if available
      final student = current.data.students.cast<dynamic>().firstWhere(
            (s) => s.name.toLowerCase() == event.studentName.toLowerCase(),
            orElse: () => null,
          );

      final newEntry = await _repository.submitCandidateFeedback(
        studentName: event.studentName,
        techRating: event.techRating,
        commRating: event.commRating,
        comments: event.comments,
        college: student?.college,
        branch: student?.branch,
        role: student?.role,
      );

      final updatedList = [newEntry, ...current.data.feedbacks];
      final totalCount = updatedList.length;
      final avgTech = updatedList.map((f) => f.techRating).reduce((a, b) => a + b) / totalCount;
      final avgComm = updatedList.map((f) => f.commRating).reduce((a, b) => a + b) / totalCount;
      final pending = (current.data.students.length - totalCount).clamp(0, 99);

      final updatedPayload = current.data.copyWith(
        feedbacks: updatedList,
        totalEvaluationsCount: totalCount,
        averageTechRating: double.parse(avgTech.toStringAsFixed(1)),
        averageCommRating: double.parse(avgComm.toStringAsFixed(1)),
        pendingCandidatesCount: pending,
      );

      final filtered = _filter(
        all: updatedList,
        query: current.searchQuery,
        filter: current.selectedFilter,
      );

      emit(current.copyWith(
        data: updatedPayload,
        filteredFeedbacks: filtered,
        isSubmitting: false,
        toastMessage: 'Feedback submitted for ${event.studentName} (${event.techRating}★ Tech, ${event.commRating}★ Comm)',
      ));
    }
  }

  void _onSearch(
    SearchFeedbackHistoryEvent event,
    Emitter<MentorFeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      final filtered = _filter(
        all: current.data.feedbacks,
        query: event.query,
        filter: current.selectedFilter,
      );

      emit(current.copyWith(
        searchQuery: event.query,
        filteredFeedbacks: filtered,
      ));
    }
  }

  void _onFilter(
    FilterFeedbackHistoryEvent event,
    Emitter<MentorFeedbackState> emit,
  ) {
    if (state is FeedbackLoaded) {
      final current = state as FeedbackLoaded;
      final filtered = _filter(
        all: current.data.feedbacks,
        query: current.searchQuery,
        filter: event.filter,
      );

      emit(current.copyWith(
        selectedFilter: event.filter,
        filteredFeedbacks: filtered,
      ));
    }
  }

  List<CandidateFeedbackEntry> _filter({
    required List<CandidateFeedbackEntry> all,
    required String query,
    required String filter,
  }) {
    return all.where((item) {
      // Category / Rating filter
      if (filter == 'top' && (item.techRating < 5 && item.commRating < 5)) {
        return false;
      }
      if (filter == 'good' && (item.techRating < 4 && item.commRating < 4)) {
        return false;
      }
      if (filter == 'needs_work' && (item.techRating >= 4 && item.commRating >= 4)) {
        return false;
      }

      // Query search
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = item.studentName.toLowerCase().contains(q);
        final matchCollege = item.college.toLowerCase().contains(q);
        final matchRole = item.role.toLowerCase().contains(q);
        final matchNotes = item.comments.toLowerCase().contains(q);
        if (!matchName && !matchCollege && !matchRole && !matchNotes) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
