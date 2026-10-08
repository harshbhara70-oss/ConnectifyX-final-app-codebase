import 'package:equatable/equatable.dart';

abstract class MentorCareerRoadmapsEvent extends Equatable {
  const MentorCareerRoadmapsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCareerRoadmapsEvent extends MentorCareerRoadmapsEvent {
  final String? query;
  final String? stage;

  const FetchCareerRoadmapsEvent({this.query, this.stage});

  @override
  List<Object?> get props => [query, stage];
}

class RefreshCareerRoadmapsEvent extends MentorCareerRoadmapsEvent {
  const RefreshCareerRoadmapsEvent();
}

class ToggleCareerMilestoneEvent extends MentorCareerRoadmapsEvent {
  final String studentId;
  final int milestoneIndex;

  const ToggleCareerMilestoneEvent({
    required this.studentId,
    required this.milestoneIndex,
  });

  @override
  List<Object?> get props => [studentId, milestoneIndex];
}

class AddCareerMilestoneEvent extends MentorCareerRoadmapsEvent {
  final String studentId;
  final String milestoneName;
  final String status;

  const AddCareerMilestoneEvent({
    required this.studentId,
    required this.milestoneName,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [studentId, milestoneName, status];
}

class FilterCareerRoadmapsByStageEvent extends MentorCareerRoadmapsEvent {
  final String stage;

  const FilterCareerRoadmapsByStageEvent(this.stage);

  @override
  List<Object?> get props => [stage];
}

class SearchCareerRoadmapsEvent extends MentorCareerRoadmapsEvent {
  final String query;

  const SearchCareerRoadmapsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
