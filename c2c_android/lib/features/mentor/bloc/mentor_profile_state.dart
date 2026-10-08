import 'package:equatable/equatable.dart';
import '../data/models/mentor_profile_model.dart';

abstract class MentorProfileState extends Equatable {
  const MentorProfileState();

  @override
  List<Object?> get props => [];
}

class MentorProfileInitial extends MentorProfileState {
  const MentorProfileInitial();
}

class MentorProfileLoading extends MentorProfileState {
  const MentorProfileLoading();
}

class MentorProfileLoaded extends MentorProfileState {
  final MentorProfileData profile;
  final bool isSaving;
  final String? toastMessage;

  const MentorProfileLoaded({
    required this.profile,
    this.isSaving = false,
    this.toastMessage,
  });

  MentorProfileLoaded copyWith({
    MentorProfileData? profile,
    bool? isSaving,
    String? toastMessage,
  }) {
    return MentorProfileLoaded(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [profile, isSaving, toastMessage];
}

class MentorProfileError extends MentorProfileState {
  final String message;

  const MentorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
