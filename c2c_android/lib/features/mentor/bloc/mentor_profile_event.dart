import 'package:equatable/equatable.dart';
import '../data/models/mentor_profile_model.dart';

abstract class MentorProfileEvent extends Equatable {
  const MentorProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchMentorProfileEvent extends MentorProfileEvent {
  final bool isRefresh;

  const FetchMentorProfileEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class UpdateMentorProfileEvent extends MentorProfileEvent {
  final MentorProfileData updatedProfile;

  const UpdateMentorProfileEvent(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}

class ToggleAvailabilityEvent extends MentorProfileEvent {
  const ToggleAvailabilityEvent();
}

class AddExpertiseTagEvent extends MentorProfileEvent {
  final String tag;

  const AddExpertiseTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

class RemoveExpertiseTagEvent extends MentorProfileEvent {
  final String tag;

  const RemoveExpertiseTagEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}
