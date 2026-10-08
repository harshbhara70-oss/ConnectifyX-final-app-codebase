import 'package:equatable/equatable.dart';

abstract class MentorSettingsEvent extends Equatable {
  const MentorSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchMentorSettingsEvent extends MentorSettingsEvent {
  final bool isRefresh;

  const FetchMentorSettingsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class UpdateSettingToggleEvent extends MentorSettingsEvent {
  final String key;
  final bool value;

  const UpdateSettingToggleEvent({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class UpdateSettingValueEvent extends MentorSettingsEvent {
  final String key;
  final String value;

  const UpdateSettingValueEvent({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class ResetSettingsToDefaultsEvent extends MentorSettingsEvent {
  const ResetSettingsToDefaultsEvent();
}

class RequestPasswordResetEvent extends MentorSettingsEvent {
  final String email;

  const RequestPasswordResetEvent(this.email);

  @override
  List<Object?> get props => [email];
}
