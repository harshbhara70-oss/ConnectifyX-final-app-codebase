import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class MentorOverviewState extends Equatable {
  const MentorOverviewState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class MentorOverviewInitial extends MentorOverviewState {
  const MentorOverviewInitial();
}

/// Loading State with Shimmer support
class MentorOverviewLoading extends MentorOverviewState {
  const MentorOverviewLoading();
}

/// Populated Data State with search filter capability
class MentorOverviewLoaded extends MentorOverviewState {
  final MentorOverviewData data;
  final String searchQuery;
  final List<MentorStudentModel> filteredStudents;

  const MentorOverviewLoaded({
    required this.data,
    this.searchQuery = '',
    required this.filteredStudents,
  });

  MentorOverviewLoaded copyWith({
    MentorOverviewData? data,
    String? searchQuery,
    List<MentorStudentModel>? filteredStudents,
  }) {
    return MentorOverviewLoaded(
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredStudents: filteredStudents ?? this.filteredStudents,
    );
  }

  @override
  List<Object?> get props => [data, searchQuery, filteredStudents];
}

/// Error State with retry capability
class MentorOverviewError extends MentorOverviewState {
  final String message;

  const MentorOverviewError(this.message);

  @override
  List<Object?> get props => [message];
}
