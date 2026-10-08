import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class MentorOverviewEvent extends Equatable {
  const MentorOverviewEvent();

  @override
  List<Object?> get props => [];
}

/// Initial and reload event
class FetchMentorOverviewEvent extends MentorOverviewEvent {
  const FetchMentorOverviewEvent();
}

/// Pull-to-refresh event
class RefreshMentorOverviewEvent extends MentorOverviewEvent {
  const RefreshMentorOverviewEvent();
}

/// Filter / Search event
class FilterMentorOverviewEvent extends MentorOverviewEvent {
  final String query;

  const FilterMentorOverviewEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Create new session slot event
class CreateSessionSlotEvent extends MentorOverviewEvent {
  final MentorSessionModel session;

  const CreateSessionSlotEvent(this.session);

  @override
  List<Object?> get props => [session];
}
