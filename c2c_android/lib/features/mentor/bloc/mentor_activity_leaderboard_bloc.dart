import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_activity_leaderboard_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_activity_leaderboard_event.dart';
import 'mentor_activity_leaderboard_state.dart';

class MentorActivityLeaderboardBloc
    extends Bloc<MentorActivityLeaderboardEvent, MentorActivityLeaderboardState> {
  final MentorRepository _repository;

  MentorActivityLeaderboardBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const ActivityLeaderboardInitial()) {
    on<FetchActivityLeaderboardEvent>(_onFetchData);
    on<ToggleActivityEvent>(_onToggleActivity);
    on<CreateActivityLogEvent>(_onCreateActivityLog);
    on<DeleteActivityLogEvent>(_onDeleteActivityLog);
    on<RecordCandidateEvaluationEvent>(_onRecordCandidateEvaluation);
    on<SearchActivityLeaderboardEvent>(_onSearch);
    on<FilterActivityStatusEvent>(_onFilterActivityStatus);
    on<FilterLeaderboardTierEvent>(_onFilterLeaderboardTier);
  }

  Future<void> _onFetchData(
    FetchActivityLeaderboardEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const ActivityLeaderboardLoading());
    }
    try {
      final data = await _repository.getActivityLeaderboardData();

      final filteredActivities = _filterActivities(
        all: data.activityTicker,
        query: '',
        status: 'All',
      );

      final filteredLeaderboard = _filterLeaderboard(
        all: data.leaderboard,
        query: '',
        tier: 'All',
      );

      emit(ActivityLeaderboardLoaded(
        data: data,
        searchQuery: '',
        activityFilter: 'All',
        leaderboardFilter: 'All',
        filteredActivities: filteredActivities,
        filteredLeaderboard: filteredLeaderboard,
      ));
    } catch (e) {
      emit(ActivityLeaderboardError('Failed to load Activity & Leaderboard: ${e.toString()}'));
    }
  }

  Future<void> _onToggleActivity(
    ToggleActivityEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) async {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;

      final updatedActivities = current.data.activityTicker.map((item) {
        if (item.id == event.activityId) {
          return item.copyWith(done: !item.done);
        }
        return item;
      }).toList();

      final completedCount = updatedActivities.where((a) => a.done).length;

      final updatedData = current.data.copyWith(
        activityTicker: updatedActivities,
        completedActivities: completedCount,
      );

      final filteredActivities = _filterActivities(
        all: updatedActivities,
        query: current.searchQuery,
        status: current.activityFilter,
      );

      emit(current.copyWith(
        data: updatedData,
        filteredActivities: filteredActivities,
      ));

      // Asynchronous API call to persist
      await _repository.toggleActivityDone(event.activityId);
    }
  }

  Future<void> _onCreateActivityLog(
    CreateActivityLogEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) async {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;
      emit(current.copyWith(isSubmitting: true));

      final newActivity = await _repository.createActivityLog(event.text);

      final updatedActivities = [newActivity, ...current.data.activityTicker];
      final totalCount = updatedActivities.length;
      final completedCount = updatedActivities.where((a) => a.done).length;

      final updatedData = current.data.copyWith(
        activityTicker: updatedActivities,
        totalActivities: totalCount,
        completedActivities: completedCount,
      );

      final filteredActivities = _filterActivities(
        all: updatedActivities,
        query: current.searchQuery,
        status: current.activityFilter,
      );

      emit(current.copyWith(
        data: updatedData,
        filteredActivities: filteredActivities,
        isSubmitting: false,
        toastMessage: 'Activity log saved.',
      ));
    }
  }

  Future<void> _onDeleteActivityLog(
    DeleteActivityLogEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) async {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;

      final updatedActivities =
          current.data.activityTicker.where((a) => a.id != event.activityId).toList();
      final totalCount = updatedActivities.length;
      final completedCount = updatedActivities.where((a) => a.done).length;

      final updatedData = current.data.copyWith(
        activityTicker: updatedActivities,
        totalActivities: totalCount,
        completedActivities: completedCount,
      );

      final filteredActivities = _filterActivities(
        all: updatedActivities,
        query: current.searchQuery,
        status: current.activityFilter,
      );

      emit(current.copyWith(
        data: updatedData,
        filteredActivities: filteredActivities,
        toastMessage: 'Activity item removed.',
      ));

      await _repository.deleteActivityLog(event.activityId);
    }
  }

  Future<void> _onRecordCandidateEvaluation(
    RecordCandidateEvaluationEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) async {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;
      emit(current.copyWith(isSubmitting: true));

      await _repository.evaluateCandidate(
        studentName: event.studentName,
        score: event.score,
        notes: event.notes,
        fit: event.fit,
        college: event.college,
        branch: event.branch,
        skills: event.skills,
      );

      // Construct new or updated candidate
      final int newScore = event.score.round();
      final List<MentorLeaderboardCandidateModel> existingList =
          List.from(current.data.leaderboard);

      final existingIndex = existingList.indexWhere(
        (c) => c.name.toLowerCase() == event.studentName.trim().toLowerCase(),
      );

      if (existingIndex >= 0) {
        final ex = existingList[existingIndex];
        existingList[existingIndex] = ex.copyWith(
          score: newScore,
          fit: event.fit.isNotEmpty ? event.fit : ex.fit,
          gapAreas: event.notes.isNotEmpty ? event.notes : ex.gapAreas,
          college: event.college.isNotEmpty ? event.college : ex.college,
          branch: event.branch.isNotEmpty ? event.branch : ex.branch,
          skills: event.skills.isNotEmpty ? event.skills : ex.skills,
        );
      } else {
        existingList.add(
          MentorLeaderboardCandidateModel(
            id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
            rank: 'Rank ${existingList.length + 1}',
            name: event.studentName.trim(),
            fit: event.fit.isNotEmpty ? event.fit : 'Tech Fit',
            score: newScore,
            college: event.college.isNotEmpty ? event.college : 'Campus Candidate',
            branch: event.branch.isNotEmpty ? event.branch : 'CSE',
            skills: event.skills.isNotEmpty
                ? event.skills
                : const ['Java', 'DSA', 'React', 'Problem Solving'],
            gapAreas: event.notes.isNotEmpty
                ? event.notes
                : 'System Architecture Tuning',
            avatarBg: '#6366F1',
            createdAt: 'Just now',
          ),
        );
      }

      // Re-sort by score descending and re-assign podium rank strings
      existingList.sort((a, b) => b.score.compareTo(a.score));

      final rankedList = existingList.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        String rankStr;
        if (i == 0) {
          rankStr = '🥇 Rank 1';
        } else if (i == 1) {
          rankStr = '🥈 Rank 2';
        } else if (i == 2) {
          rankStr = '🥉 Rank 3';
        } else {
          rankStr = 'Rank ${i + 1}';
        }
        return c.copyWith(rank: rankStr);
      }).toList();

      // Also create an activity log entry
      final newActivityItem = MentorActivityModel(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Recorded diagnostic for ${event.studentName.trim()}',
        time: 'Just now',
        done: true,
      );

      final updatedActivities = [newActivityItem, ...current.data.activityTicker];
      final totalActs = updatedActivities.length;
      final completedActs = updatedActivities.where((a) => a.done).length;

      final avgScore = rankedList.isNotEmpty
          ? (rankedList.map((e) => e.score).reduce((a, b) => a + b) / rankedList.length).round()
          : 0;

      final topCand = rankedList.isNotEmpty
          ? '${rankedList.first.name} (${rankedList.first.fit})'
          : 'N/A';

      final updatedData = current.data.copyWith(
        leaderboard: rankedList,
        activityTicker: updatedActivities,
        totalActivities: totalActs,
        completedActivities: completedActs,
        averageScore: avgScore,
        topCandidate: topCand,
      );

      final filteredActivities = _filterActivities(
        all: updatedActivities,
        query: current.searchQuery,
        status: current.activityFilter,
      );

      final filteredLeaderboard = _filterLeaderboard(
        all: rankedList,
        query: current.searchQuery,
        tier: current.leaderboardFilter,
      );

      emit(current.copyWith(
        data: updatedData,
        filteredActivities: filteredActivities,
        filteredLeaderboard: filteredLeaderboard,
        isSubmitting: false,
        toastMessage: 'Candidate evaluation recorded for ${event.studentName.trim()}.',
      ));
    }
  }

  void _onSearch(
    SearchActivityLeaderboardEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;

      final filteredActivities = _filterActivities(
        all: current.data.activityTicker,
        query: event.query,
        status: current.activityFilter,
      );

      final filteredLeaderboard = _filterLeaderboard(
        all: current.data.leaderboard,
        query: event.query,
        tier: current.leaderboardFilter,
      );

      emit(current.copyWith(
        searchQuery: event.query,
        filteredActivities: filteredActivities,
        filteredLeaderboard: filteredLeaderboard,
      ));
    }
  }

  void _onFilterActivityStatus(
    FilterActivityStatusEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;

      final filteredActivities = _filterActivities(
        all: current.data.activityTicker,
        query: current.searchQuery,
        status: event.status,
      );

      emit(current.copyWith(
        activityFilter: event.status,
        filteredActivities: filteredActivities,
      ));
    }
  }

  void _onFilterLeaderboardTier(
    FilterLeaderboardTierEvent event,
    Emitter<MentorActivityLeaderboardState> emit,
  ) {
    if (state is ActivityLeaderboardLoaded) {
      final current = state as ActivityLeaderboardLoaded;

      final filteredLeaderboard = _filterLeaderboard(
        all: current.data.leaderboard,
        query: current.searchQuery,
        tier: event.tier,
      );

      emit(current.copyWith(
        leaderboardFilter: event.tier,
        filteredLeaderboard: filteredLeaderboard,
      ));
    }
  }

  List<MentorActivityModel> _filterActivities({
    required List<MentorActivityModel> all,
    required String query,
    required String status,
  }) {
    return all.where((a) {
      if (status == 'Done' && !a.done) return false;
      if (status == 'Pending' && a.done) return false;

      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        return a.text.toLowerCase().contains(q) || a.time.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  List<MentorLeaderboardCandidateModel> _filterLeaderboard({
    required List<MentorLeaderboardCandidateModel> all,
    required String query,
    required String tier,
  }) {
    return all.where((c) {
      if (tier == 'Top 3') {
        final rankNum = int.tryParse(c.rank.replaceAll(RegExp(r'[^0-9]'), '')) ?? 99;
        if (rankNum > 3) return false;
      } else if (tier == 'Elite') {
        if (c.score < 85) return false;
      } else if (tier == 'In Training') {
        if (c.score >= 85) return false;
      }

      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchFit = c.fit.toLowerCase().contains(q);
        final matchCollege = c.college.toLowerCase().contains(q);
        final matchBranch = c.branch.toLowerCase().contains(q);
        final matchSkill = c.skills.any((s) => s.toLowerCase().contains(q));
        if (!matchName && !matchFit && !matchCollege && !matchBranch && !matchSkill) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
