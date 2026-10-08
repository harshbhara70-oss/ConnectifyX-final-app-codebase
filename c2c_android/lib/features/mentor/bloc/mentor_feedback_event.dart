import 'package:equatable/equatable.dart';

abstract class MentorFeedbackEvent extends Equatable {
  const MentorFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class FetchFeedbackDataEvent extends MentorFeedbackEvent {
  final bool isRefresh;

  const FetchFeedbackDataEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SelectCandidateEvent extends MentorFeedbackEvent {
  final String candidateName;

  const SelectCandidateEvent(this.candidateName);

  @override
  List<Object?> get props => [candidateName];
}

class ChangeTechRatingEvent extends MentorFeedbackEvent {
  final int rating;

  const ChangeTechRatingEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class ChangeCommRatingEvent extends MentorFeedbackEvent {
  final int rating;

  const ChangeCommRatingEvent(this.rating);

  @override
  List<Object?> get props => [rating];
}

class SubmitFeedbackEvent extends MentorFeedbackEvent {
  final String studentName;
  final int techRating;
  final int commRating;
  final String comments;
  final String? college;
  final String? branch;
  final String? role;

  const SubmitFeedbackEvent({
    required this.studentName,
    required this.techRating,
    required this.commRating,
    required this.comments,
    this.college,
    this.branch,
    this.role,
  });

  @override
  List<Object?> get props => [
        studentName,
        techRating,
        commRating,
        comments,
        college,
        branch,
        role,
      ];
}

class SearchFeedbackHistoryEvent extends MentorFeedbackEvent {
  final String query;

  const SearchFeedbackHistoryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterFeedbackHistoryEvent extends MentorFeedbackEvent {
  final String filter; // 'all' | 'top' | 'good' | 'needs_work'

  const FilterFeedbackHistoryEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}
