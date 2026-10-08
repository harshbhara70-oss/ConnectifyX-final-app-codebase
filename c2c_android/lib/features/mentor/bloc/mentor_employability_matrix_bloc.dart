import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_employability_matrix_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_employability_matrix_event.dart';
import 'mentor_employability_matrix_state.dart';

class MentorEmployabilityMatrixBloc extends Bloc<
    MentorEmployabilityMatrixEvent, MentorEmployabilityMatrixState> {
  final MentorRepository _repository;

  MentorEmployabilityMatrixBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const MentorEmployabilityMatrixInitial()) {
    on<FetchMentorEmployabilityMatrixEvent>(_onFetchData);
    on<ToggleActivityTickerEvent>(_onToggleTicker);
    on<SearchLeaderboardEvent>(_onSearchLeaderboard);
    on<FilterLeaderboardBranchEvent>(_onFilterBranch);
    on<RecordEvaluationEvent>(_onRecordEvaluation);
  }

  Future<void> _onFetchData(
    FetchMentorEmployabilityMatrixEvent event,
    Emitter<MentorEmployabilityMatrixState> emit,
  ) async {
    emit(const MentorEmployabilityMatrixLoading());
    try {
      final matrixData = await _repository.getEmployabilityMatrix();

      emit(MentorEmployabilityMatrixLoaded(
        data: matrixData,
        filteredLeaderboard: matrixData.leaderboard,
      ));
    } catch (e) {
      emit(MentorEmployabilityMatrixError('Failed to load matrix: ${e.toString()}'));
    }
  }

  Future<void> _onRecordEvaluation(
    RecordEvaluationEvent event,
    Emitter<MentorEmployabilityMatrixState> emit,
  ) async {
    if (state is MentorEmployabilityMatrixLoaded) {
      final current = state as MentorEmployabilityMatrixLoaded;
      
      await _repository.recordMenteeEvaluation(
        studentName: event.studentName,
        score: event.score,
        notes: event.notes,
      );

      // Optimistically add to leaderboard if not present
      final existingIndex = current.data.leaderboard.indexWhere(
        (s) => s.name.toLowerCase() == event.studentName.trim().toLowerCase(),
      );

      List<MentorLeaderboardEntry> updatedList = List.from(current.data.leaderboard);
      if (existingIndex >= 0) {
        final existing = updatedList[existingIndex];
        updatedList[existingIndex] = MentorLeaderboardEntry(
          rank: existing.rank,
          name: existing.name,
          fit: existing.fit,
          score: event.score.round(),
          college: existing.college,
          branch: existing.branch,
          skills: existing.skills,
          gapAreas: event.notes.isNotEmpty ? event.notes : existing.gapAreas,
          avatarBg: existing.avatarBg,
        );
      } else {
        updatedList.insert(
          0,
          MentorLeaderboardEntry(
            rank: 'Rank ${updatedList.length + 1}',
            name: event.studentName.trim(),
            fit: 'Stripe (React) Fit',
            score: event.score.round(),
            college: 'Campus Candidate',
            branch: 'CSE',
            skills: const ['Java', 'DSA', 'React', 'Problem Solving'],
            gapAreas: event.notes.isNotEmpty ? event.notes : 'System Architecture Tuning',
            avatarBg: '#6366F1',
          ),
        );
      }

      // Add ticker activity
      final updatedTicker = [
        MentorActivityTickerItem(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Recorded diagnostic evaluation for ${event.studentName.trim()}',
          time: 'Just now',
          done: true,
        ),
        ...current.data.activityTicker,
      ];

      final updatedData = current.data.copyWith(
        leaderboard: updatedList,
        activityTicker: updatedTicker,
        totalMenteesEvaluated: updatedList.length,
        eliteReadyCount: updatedList.where((e) => e.score >= 85).length,
        criticalGapsCount: updatedList.where((e) => e.score < 70).length,
      );

      final filtered = _filter(
        all: updatedList,
        query: current.searchQuery,
        branch: current.selectedBranch,
      );

      emit(current.copyWith(
        data: updatedData,
        filteredLeaderboard: filtered,
      ));
    }
  }

  void _onToggleTicker(
    ToggleActivityTickerEvent event,
    Emitter<MentorEmployabilityMatrixState> emit,
  ) {
    if (state is MentorEmployabilityMatrixLoaded) {
      final current = state as MentorEmployabilityMatrixLoaded;
      final updatedTicker = current.data.activityTicker.map((item) {
        if (item.id == event.tickerId) {
          return item.copyWith(done: !item.done);
        }
        return item;
      }).toList();

      final updatedData = current.data.copyWith(activityTicker: updatedTicker);
      emit(current.copyWith(data: updatedData));
    }
  }

  void _onSearchLeaderboard(
    SearchLeaderboardEvent event,
    Emitter<MentorEmployabilityMatrixState> emit,
  ) {
    if (state is MentorEmployabilityMatrixLoaded) {
      final current = state as MentorEmployabilityMatrixLoaded;
      final filtered = _filter(
        all: current.data.leaderboard,
        query: event.query,
        branch: current.selectedBranch,
      );
      emit(current.copyWith(
        searchQuery: event.query,
        filteredLeaderboard: filtered,
      ));
    }
  }

  void _onFilterBranch(
    FilterLeaderboardBranchEvent event,
    Emitter<MentorEmployabilityMatrixState> emit,
  ) {
    if (state is MentorEmployabilityMatrixLoaded) {
      final current = state as MentorEmployabilityMatrixLoaded;
      final filtered = _filter(
        all: current.data.leaderboard,
        query: current.searchQuery,
        branch: event.branch,
      );
      emit(current.copyWith(
        selectedBranch: event.branch,
        filteredLeaderboard: filtered,
      ));
    }
  }

  List<MentorLeaderboardEntry> _filter({
    required List<MentorLeaderboardEntry> all,
    required String query,
    required String branch,
  }) {
    return all.where((e) {
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = e.name.toLowerCase().contains(q);
        final matchFit = e.fit.toLowerCase().contains(q);
        final matchCollege = e.college.toLowerCase().contains(q);
        final matchSkill = e.skills.any((s) => s.toLowerCase().contains(q));
        if (!matchName && !matchFit && !matchCollege && !matchSkill) {
          return false;
        }
      }

      if (branch != 'All' && e.branch.toUpperCase() != branch.toUpperCase()) {
        return false;
      }

      return true;
    }).toList();
  }
}
