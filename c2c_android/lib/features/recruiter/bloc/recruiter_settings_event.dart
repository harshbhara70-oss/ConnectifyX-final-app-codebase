import 'package:equatable/equatable.dart';
import '../data/models/recruiter_settings_model.dart';

abstract class RecruiterSettingsEvent extends Equatable {
  const RecruiterSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecruiterSettingsEvent extends RecruiterSettingsEvent {
  const FetchRecruiterSettingsEvent();
}

class ChangeSettingsTabEvent extends RecruiterSettingsEvent {
  final String tab; // "company" | "team" | "notifications"
  const ChangeSettingsTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SaveRecruiterSettingsEvent extends RecruiterSettingsEvent {
  final String repName;
  final String companyName;
  final String websiteUrl;
  final String aboutCompany;
  final String? logoUrl;

  const SaveRecruiterSettingsEvent({
    required this.repName,
    required this.companyName,
    required this.websiteUrl,
    required this.aboutCompany,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [repName, companyName, websiteUrl, aboutCompany, logoUrl];
}

class RequestAdminEditEvent extends RecruiterSettingsEvent {
  final String companyName;
  const RequestAdminEditEvent(this.companyName);

  @override
  List<Object?> get props => [companyName];
}

class UpdateNotificationPreferencesEvent extends RecruiterSettingsEvent {
  final RecruiterNotificationPreferences preferences;
  const UpdateNotificationPreferencesEvent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class InviteTeamMemberEvent extends RecruiterSettingsEvent {
  final String name;
  final String email;
  final String role;

  const InviteTeamMemberEvent({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, role];
}
