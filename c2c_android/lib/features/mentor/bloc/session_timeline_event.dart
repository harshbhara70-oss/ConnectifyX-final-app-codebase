import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class SessionTimelineEvent extends Equatable {
  const SessionTimelineEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches sequential sessions and action priority queue
class FetchSessionTimelineEvent extends SessionTimelineEvent {
  const FetchSessionTimelineEvent();
}

/// Filters sessions by category ('All', 'Resume Review', 'Mock Interview', etc.)
class FilterSessionCategoryEvent extends SessionTimelineEvent {
  final String category;

  const FilterSessionCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filters sessions by day or date ('All', 'Today', 'Tomorrow')
class FilterSessionDayEvent extends SessionTimelineEvent {
  final String day;

  const FilterSessionDayEvent(this.day);

  @override
  List<Object?> get props => [day];
}

/// Searches sessions by student name, session type, or time
class SearchSessionsEvent extends SessionTimelineEvent {
  final String query;

  const SearchSessionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Creates a new session slot
class CreateSessionSlotEvent extends SessionTimelineEvent {
  final MentorSessionModel session;

  const CreateSessionSlotEvent(this.session);

  @override
  List<Object?> get props => [session];
}

/// Cancels/deletes a session slot
class CancelSessionSlotEvent extends SessionTimelineEvent {
  final String sessionId;

  const CancelSessionSlotEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

/// Resolves an action priority queue alert
class ResolveAlertEvent extends SessionTimelineEvent {
  final String alertId;

  const ResolveAlertEvent(this.alertId);

  @override
  List<Object?> get props => [alertId];
}
