import 'package:equatable/equatable.dart';
import '../data/models/mentor_feedback_model.dart';

abstract class MentorFeedbackState extends Equatable {
  const MentorFeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends MentorFeedbackState {
  const FeedbackInitial();
}

class FeedbackLoading extends MentorFeedbackState {
  const FeedbackLoading();
}

class FeedbackLoaded extends MentorFeedbackState {
  final MentorFeedbackData data;
  final String selectedCandidate;
  final int selectedTechRating;
  final int selectedCommRating;
  final bool isSubmitting;
  final String? toastMessage;
  final String searchQuery;
  final String selectedFilter; // 'all' | 'top' | 'good' | 'needs_work'
  final List<CandidateFeedbackEntry> filteredFeedbacks;

  const FeedbackLoaded({
    required this.data,
    required this.selectedCandidate,
    this.selectedTechRating = 4,
    this.selectedCommRating = 4,
    this.isSubmitting = false,
    this.toastMessage,
    this.searchQuery = '',
    this.selectedFilter = 'all',
    required this.filteredFeedbacks,
  });

  FeedbackLoaded copyWith({
    MentorFeedbackData? data,
    String? selectedCandidate,
    int? selectedTechRating,
    int? selectedCommRating,
    bool? isSubmitting,
    String? toastMessage,
    String? searchQuery,
    String? selectedFilter,
    List<CandidateFeedbackEntry>? filteredFeedbacks,
  }) {
    return FeedbackLoaded(
      data: data ?? this.data,
      selectedCandidate: selectedCandidate ?? this.selectedCandidate,
      selectedTechRating: selectedTechRating ?? this.selectedTechRating,
      selectedCommRating: selectedCommRating ?? this.selectedCommRating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastMessage: toastMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      filteredFeedbacks: filteredFeedbacks ?? this.filteredFeedbacks,
    );
  }

  @override
  List<Object?> get props => [
        data,
        selectedCandidate,
        selectedTechRating,
        selectedCommRating,
        isSubmitting,
        toastMessage,
        searchQuery,
        selectedFilter,
        filteredFeedbacks,
      ];
}

class FeedbackError extends MentorFeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}
