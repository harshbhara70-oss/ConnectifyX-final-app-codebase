import 'package:equatable/equatable.dart';
import '../data/models/mentor_settings_model.dart';

abstract class MentorSettingsState extends Equatable {
  const MentorSettingsState();

  @override
  List<Object?> get props => [];
}

class MentorSettingsInitial extends MentorSettingsState {
  const MentorSettingsInitial();
}

class MentorSettingsLoading extends MentorSettingsState {
  const MentorSettingsLoading();
}

class MentorSettingsLoaded extends MentorSettingsState {
  final MentorSettingsData settings;
  final bool isSaving;
  final String? toastMessage;

  const MentorSettingsLoaded({
    required this.settings,
    this.isSaving = false,
    this.toastMessage,
  });

  MentorSettingsLoaded copyWith({
    MentorSettingsData? settings,
    bool? isSaving,
    String? toastMessage,
  }) {
    return MentorSettingsLoaded(
      settings: settings ?? this.settings,
      isSaving: isSaving ?? this.isSaving,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [settings, isSaving, toastMessage];
}

class MentorSettingsError extends MentorSettingsState {
  final String message;

  const MentorSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
