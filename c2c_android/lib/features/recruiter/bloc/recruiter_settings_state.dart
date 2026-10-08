import 'package:equatable/equatable.dart';
import '../data/models/recruiter_settings_model.dart';

abstract class RecruiterSettingsState extends Equatable {
  const RecruiterSettingsState();

  @override
  List<Object?> get props => [];
}

class RecruiterSettingsInitial extends RecruiterSettingsState {
  const RecruiterSettingsInitial();
}

class RecruiterSettingsLoading extends RecruiterSettingsState {
  const RecruiterSettingsLoading();
}

class RecruiterSettingsLoaded extends RecruiterSettingsState {
  final RecruiterSettingsModel settings;
  final String activeTab; // "company" | "team" | "notifications"
  final bool isSaving;
  final String? successMessage;
  final String? errorMessage;

  const RecruiterSettingsLoaded({
    required this.settings,
    this.activeTab = 'company',
    this.isSaving = false,
    this.successMessage,
    this.errorMessage,
  });

  bool get isMock => settings.isMock;
  bool get isVerified => settings.isVerified;
  String get verificationStatus => settings.verificationStatus;

  RecruiterSettingsLoaded copyWith({
    RecruiterSettingsModel? settings,
    String? activeTab,
    bool? isSaving,
    String? successMessage,
    String? errorMessage,
  }) {
    return RecruiterSettingsLoaded(
      settings: settings ?? this.settings,
      activeTab: activeTab ?? this.activeTab,
      isSaving: isSaving ?? this.isSaving,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, activeTab, isSaving, successMessage, errorMessage];
}

class RecruiterSettingsError extends RecruiterSettingsState {
  final String message;
  const RecruiterSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
