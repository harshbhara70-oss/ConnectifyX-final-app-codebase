import 'package:equatable/equatable.dart';

abstract class MentorEmployabilityMatrixEvent extends Equatable {
  const MentorEmployabilityMatrixEvent();

  @override
  List<Object?> get props => [];
}

class FetchMentorEmployabilityMatrixEvent extends MentorEmployabilityMatrixEvent {
  const FetchMentorEmployabilityMatrixEvent();
}

class ToggleActivityTickerEvent extends MentorEmployabilityMatrixEvent {
  final String tickerId;
  const ToggleActivityTickerEvent(this.tickerId);

  @override
  List<Object?> get props => [tickerId];
}

class SearchLeaderboardEvent extends MentorEmployabilityMatrixEvent {
  final String query;
  const SearchLeaderboardEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterLeaderboardBranchEvent extends MentorEmployabilityMatrixEvent {
  final String branch;
  const FilterLeaderboardBranchEvent(this.branch);

  @override
  List<Object?> get props => [branch];
}

class RecordEvaluationEvent extends MentorEmployabilityMatrixEvent {
  final String studentName;
  final double score;
  final String notes;

  const RecordEvaluationEvent({
    required this.studentName,
    required this.score,
    required this.notes,
  });

  @override
  List<Object?> get props => [studentName, score, notes];
}
