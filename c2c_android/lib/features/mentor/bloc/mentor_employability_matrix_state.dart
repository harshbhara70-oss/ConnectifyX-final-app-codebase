import 'package:equatable/equatable.dart';
import '../data/models/mentor_employability_matrix_model.dart';

abstract class MentorEmployabilityMatrixState extends Equatable {
  const MentorEmployabilityMatrixState();

  @override
  List<Object?> get props => [];
}

class MentorEmployabilityMatrixInitial extends MentorEmployabilityMatrixState {
  const MentorEmployabilityMatrixInitial();
}

class MentorEmployabilityMatrixLoading extends MentorEmployabilityMatrixState {
  const MentorEmployabilityMatrixLoading();
}

class MentorEmployabilityMatrixLoaded extends MentorEmployabilityMatrixState {
  final MentorEmployabilityMatrixData data;
  final List<MentorLeaderboardEntry> filteredLeaderboard;
  final String searchQuery;
  final String selectedBranch;

  const MentorEmployabilityMatrixLoaded({
    required this.data,
    required this.filteredLeaderboard,
    this.searchQuery = '',
    this.selectedBranch = 'All',
  });

  MentorEmployabilityMatrixLoaded copyWith({
    MentorEmployabilityMatrixData? data,
    List<MentorLeaderboardEntry>? filteredLeaderboard,
    String? searchQuery,
    String? selectedBranch,
  }) {
    return MentorEmployabilityMatrixLoaded(
      data: data ?? this.data,
      filteredLeaderboard: filteredLeaderboard ?? this.filteredLeaderboard,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBranch: selectedBranch ?? this.selectedBranch,
    );
  }

  @override
  List<Object?> get props => [
        data,
        filteredLeaderboard,
        searchQuery,
        selectedBranch,
      ];
}

class MentorEmployabilityMatrixError extends MentorEmployabilityMatrixState {
  final String message;
  const MentorEmployabilityMatrixError(this.message);

  @override
  List<Object?> get props => [message];
}
