import 'package:equatable/equatable.dart';
import '../data/models/admin_settings_models.dart';

abstract class AdminSettingsState extends Equatable {
  const AdminSettingsState();

  @override
  List<Object?> get props => [];
}

class AdminSettingsInitial extends AdminSettingsState {}

class AdminSettingsLoading extends AdminSettingsState {}

class AdminSettingsLoaded extends AdminSettingsState {
  final AdminSettingsDto settings;
  final String activeCategory; // 'ai', 'integrations', 'security', 'maintenance', 'general', 'policies', 'notifications'
  final bool isSaving;
  final String? toastNotification;

  const AdminSettingsLoaded({
    required this.settings,
    this.activeCategory = 'ai',
    this.isSaving = false,
    this.toastNotification,
  });

  AdminSettingsLoaded copyWith({
    AdminSettingsDto? settings,
    String? activeCategory,
    bool? isSaving,
    String? toastNotification,
    bool clearToast = false,
  }) {
    return AdminSettingsLoaded(
      settings: settings ?? this.settings,
      activeCategory: activeCategory ?? this.activeCategory,
      isSaving: isSaving ?? this.isSaving,
      toastNotification: clearToast ? null : (toastNotification ?? this.toastNotification),
    );
  }

  @override
  List<Object?> get props => [
        settings,
        activeCategory,
        isSaving,
        toastNotification,
      ];
}

class AdminSettingsError extends AdminSettingsState {
  final String message;

  const AdminSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}
