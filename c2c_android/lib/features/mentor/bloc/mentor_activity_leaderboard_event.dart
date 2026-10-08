import 'package:equatable/equatable.dart';

abstract class MentorActivityLeaderboardEvent extends Equatable {
  const MentorActivityLeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial or refreshed Activity & Leaderboard data
class FetchActivityLeaderboardEvent extends MentorActivityLeaderboardEvent {
  final bool isRefresh;

  const FetchActivityLeaderboardEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Toggle done/pending checkbox on an activity item
class ToggleActivityEvent extends MentorActivityLeaderboardEvent {
  final String activityId;

  const ToggleActivityEvent(this.activityId);

  @override
  List<Object?> get props => [activityId];
}

/// Add new activity log
class CreateActivityLogEvent extends MentorActivityLeaderboardEvent {
  final String text;

  const CreateActivityLogEvent(this.text);

  @override
  List<Object?> get props => [text];
}

/// Delete an activity log
class DeleteActivityLogEvent extends MentorActivityLeaderboardEvent {
  final String activityId;

  const DeleteActivityLogEvent(this.activityId);

  @override
  List<Object?> get props => [activityId];
}

/// Evaluate candidate and add/update on the leaderboard
class RecordCandidateEvaluationEvent extends MentorActivityLeaderboardEvent {
  final String studentName;
  final double score;
  final String fit;
  final String notes;
  final String college;
  final String branch;
  final List<String> skills;

  const RecordCandidateEvaluationEvent({
    required this.studentName,
    required this.score,
    required this.fit,
    required this.notes,
    this.college = 'Campus Candidate',
    this.branch = 'CSE',
    this.skills = const ['Java', 'DSA', 'React', 'Problem Solving'],
  });

  @override
  List<Object?> get props => [
        studentName,
        score,
        fit,
        notes,
        college,
        branch,
        skills,
      ];
}

/// Search across Activity Feed and Leaderboard
class SearchActivityLeaderboardEvent extends MentorActivityLeaderboardEvent {
  final String query;

  const SearchActivityLeaderboardEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter Activity Ticker by status: 'All', 'Done', 'Pending'
class FilterActivityStatusEvent extends MentorActivityLeaderboardEvent {
  final String status;

  const FilterActivityStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter Leaderboard by tier: 'All', 'Top 3', 'Elite', 'In Training'
class FilterLeaderboardTierEvent extends MentorActivityLeaderboardEvent {
  final String tier;

  const FilterLeaderboardTierEvent(this.tier);

  @override
  List<Object?> get props => [tier];
}
