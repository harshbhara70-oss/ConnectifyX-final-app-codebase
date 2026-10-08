import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class SessionTimelineState extends Equatable {
  const SessionTimelineState();

  @override
  List<Object?> get props => [];
}

class SessionTimelineInitial extends SessionTimelineState {
  const SessionTimelineInitial();
}

class SessionTimelineLoading extends SessionTimelineState {
  const SessionTimelineLoading();
}

class SessionTimelineLoaded extends SessionTimelineState {
  final List<MentorSessionModel> allSessions;
  final List<MentorSessionModel> filteredSessions;
  final List<ActionPriorityItemModel> alerts;
  final List<MentorStudentModel> availableStudents;
  final String selectedCategory;
  final String selectedDay;
  final String searchQuery;
  final bool isMock;
  final bool isCreatingSession;
  final String? feedbackMessage;

  const SessionTimelineLoaded({
    required this.allSessions,
    required this.filteredSessions,
    required this.alerts,
    required this.availableStudents,
    this.selectedCategory = 'All',
    this.selectedDay = 'All',
    this.searchQuery = '',
    this.isMock = true,
    this.isCreatingSession = false,
    this.feedbackMessage,
  });

  SessionTimelineLoaded copyWith({
    List<MentorSessionModel>? allSessions,
    List<MentorSessionModel>? filteredSessions,
    List<ActionPriorityItemModel>? alerts,
    List<MentorStudentModel>? availableStudents,
    String? selectedCategory,
    String? selectedDay,
    String? searchQuery,
    bool? isMock,
    bool? isCreatingSession,
    String? feedbackMessage,
  }) {
    return SessionTimelineLoaded(
      allSessions: allSessions ?? this.allSessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      alerts: alerts ?? this.alerts,
      availableStudents: availableStudents ?? this.availableStudents,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDay: selectedDay ?? this.selectedDay,
      searchQuery: searchQuery ?? this.searchQuery,
      isMock: isMock ?? this.isMock,
      isCreatingSession: isCreatingSession ?? this.isCreatingSession,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        allSessions,
        filteredSessions,
        alerts,
        availableStudents,
        selectedCategory,
        selectedDay,
        searchQuery,
        isMock,
        isCreatingSession,
        feedbackMessage,
      ];
}

class SessionTimelineError extends SessionTimelineState {
  final String message;

  const SessionTimelineError(this.message);

  @override
  List<Object?> get props => [message];
}
