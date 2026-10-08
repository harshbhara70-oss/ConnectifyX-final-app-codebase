import 'package:equatable/equatable.dart';
import '../data/models/mentor_activity_leaderboard_model.dart';

abstract class MentorActivityLeaderboardState extends Equatable {
  const MentorActivityLeaderboardState();

  @override
  List<Object?> get props => [];
}

class ActivityLeaderboardInitial extends MentorActivityLeaderboardState {
  const ActivityLeaderboardInitial();
}

class ActivityLeaderboardLoading extends MentorActivityLeaderboardState {
  const ActivityLeaderboardLoading();
}

class ActivityLeaderboardLoaded extends MentorActivityLeaderboardState {
  final MentorActivityLeaderboardData data;
  final String searchQuery;
  final String activityFilter; // 'All', 'Done', 'Pending'
  final String leaderboardFilter; // 'All', 'Top 3', 'Elite', 'In Training'
  final List<MentorActivityModel> filteredActivities;
  final List<MentorLeaderboardCandidateModel> filteredLeaderboard;
  final bool isSubmitting;
  final String? toastMessage;

  const ActivityLeaderboardLoaded({
    required this.data,
    this.searchQuery = '',
    this.activityFilter = 'All',
    this.leaderboardFilter = 'All',
    required this.filteredActivities,
    required this.filteredLeaderboard,
    this.isSubmitting = false,
    this.toastMessage,
  });

  ActivityLeaderboardLoaded copyWith({
    MentorActivityLeaderboardData? data,
    String? searchQuery,
    String? activityFilter,
    String? leaderboardFilter,
    List<MentorActivityModel>? filteredActivities,
    List<MentorLeaderboardCandidateModel>? filteredLeaderboard,
    bool? isSubmitting,
    String? toastMessage,
  }) {
    return ActivityLeaderboardLoaded(
      data: data ?? this.data,
      searchQuery: searchQuery ?? this.searchQuery,
      activityFilter: activityFilter ?? this.activityFilter,
      leaderboardFilter: leaderboardFilter ?? this.leaderboardFilter,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      filteredLeaderboard: filteredLeaderboard ?? this.filteredLeaderboard,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        searchQuery,
        activityFilter,
        leaderboardFilter,
        filteredActivities,
        filteredLeaderboard,
        isSubmitting,
        toastMessage,
      ];
}

class ActivityLeaderboardError extends MentorActivityLeaderboardState {
  final String message;

  const ActivityLeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
