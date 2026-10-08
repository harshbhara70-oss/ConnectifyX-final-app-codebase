import 'package:equatable/equatable.dart';
import '../data/models/admin_settings_models.dart';

abstract class AdminSettingsEvent extends Equatable {
  const AdminSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial fetch or pull-to-refresh
class FetchAdminSettingsEvent extends AdminSettingsEvent {
  final bool isRefresh;

  const FetchAdminSettingsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Switching category sub-tab ('ai', 'integrations', 'security', 'maintenance', 'general', 'policies', 'notifications')
class ChangeSettingsCategoryEvent extends AdminSettingsEvent {
  final String categoryId;

  const ChangeSettingsCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Real-time slider adjustments for AI Readiness weights
class UpdateAiWeightEvent extends AdminSettingsEvent {
  final int? academic;
  final int? softSkills;
  final int? techProjects;
  final int? extracurricular;

  const UpdateAiWeightEvent({
    this.academic,
    this.softSkills,
    this.techProjects,
    this.extracurricular,
  });

  @override
  List<Object?> get props => [academic, softSkills, techProjects, extracurricular];
}

/// Persist AI Readiness weights
class SaveAiWeightsEvent extends AdminSettingsEvent {
  const SaveAiWeightsEvent();
}

/// Toggles system-wide maintenance mode
class ToggleMaintenanceModeEvent extends AdminSettingsEvent {
  const ToggleMaintenanceModeEvent();
}

/// Configures / toggles third party integration connection
class ToggleIntegrationEvent extends AdminSettingsEvent {
  final String integrationId;

  const ToggleIntegrationEvent(this.integrationId);

  @override
  List<Object?> get props => [integrationId];
}

/// Updates general / policy settings
class UpdateGeneralSettingsEvent extends AdminSettingsEvent {
  final AdminGeneralSettingsModel general;

  const UpdateGeneralSettingsEvent(this.general);

  @override
  List<Object?> get props => [general];
}
