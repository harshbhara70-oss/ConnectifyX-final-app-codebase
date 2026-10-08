import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class StudentAnalyticsEvent extends Equatable {
  const StudentAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial student list and analytics metrics
class FetchStudentAnalyticsEvent extends StudentAnalyticsEvent {
  final String? query;
  final String? stage;

  const FetchStudentAnalyticsEvent({this.query, this.stage});

  @override
  List<Object?> get props => [query, stage];
}

/// Select a student from the roster to inspect their deep metrics
class SelectStudentEvent extends StudentAnalyticsEvent {
  final String studentId;

  const SelectStudentEvent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

/// Realtime text search across student names, college, branch, role, skills
class SearchStudentEvent extends StudentAnalyticsEvent {
  final String query;

  const SearchStudentEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter students by pipeline stage (e.g. All, Enrolled, Skill Assessment, etc.)
class FilterPipelineStageEvent extends StudentAnalyticsEvent {
  final String stage;

  const FilterPipelineStageEvent(this.stage);

  @override
  List<Object?> get props => [stage];
}

/// Log a private memo / note to the selected student
class AddStudentNoteEvent extends StudentAnalyticsEvent {
  final String studentId;
  final String note;

  const AddStudentNoteEvent({
    required this.studentId,
    required this.note,
  });

  @override
  List<Object?> get props => [studentId, note];
}

/// Register a new mentee record
class AddStudentEvent extends StudentAnalyticsEvent {
  final MentorStudentModel student;

  const AddStudentEvent(this.student);

  @override
  List<Object?> get props => [student];
}

/// Toggle completion status of a milestone item
class ToggleStudentMilestoneEvent extends StudentAnalyticsEvent {
  final String studentId;
  final int milestoneIndex;

  const ToggleStudentMilestoneEvent({
    required this.studentId,
    required this.milestoneIndex,
  });

  @override
  List<Object?> get props => [studentId, milestoneIndex];
}
