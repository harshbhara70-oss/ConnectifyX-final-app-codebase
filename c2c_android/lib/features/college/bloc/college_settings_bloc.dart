import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/services/college_settings_api_service.dart';
import '../domain/models/college_settings_model.dart';

// =============================================================================
// EVENTS
// =============================================================================
abstract class CollegeSettingsEvent extends Equatable {
  const CollegeSettingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCollegeSettingsEvent extends CollegeSettingsEvent {}

class RefreshCollegeSettingsEvent extends CollegeSettingsEvent {}

class ChangePasswordEvent extends CollegeSettingsEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class ToggleTwoFactorEvent extends CollegeSettingsEvent {
  final bool enabled;
  const ToggleTwoFactorEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateNotificationPreferenceEvent extends CollegeSettingsEvent {
  final bool? notifyEmail;
  final bool? notifySms;
  final bool? notifyRecruiter;
  final bool? notifyDigest;
  final bool? notifyDrives;

  const UpdateNotificationPreferenceEvent({
    this.notifyEmail,
    this.notifySms,
    this.notifyRecruiter,
    this.notifyDigest,
    this.notifyDrives,
  });

  @override
  List<Object?> get props => [
        notifyEmail,
        notifySms,
        notifyRecruiter,
        notifyDigest,
        notifyDrives,
      ];
}

class UpdatePlacementCycleThresholdEvent extends CollegeSettingsEvent {
  final int threshold;
  const UpdatePlacementCycleThresholdEvent(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

class ToggleAutoNotifyEligibleEvent extends CollegeSettingsEvent {
  final bool enabled;
  const ToggleAutoNotifyEligibleEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ExportInstitutionDataEvent extends CollegeSettingsEvent {}

class DeactivateCollegeAccountEvent extends CollegeSettingsEvent {}

class ClearCollegeSettingsToastEvent extends CollegeSettingsEvent {}

// =============================================================================
// STATES
// =============================================================================
abstract class CollegeSettingsState extends Equatable {
  const CollegeSettingsState();

  @override
  List<Object?> get props => [];
}

class CollegeSettingsInitial extends CollegeSettingsState {}

class CollegeSettingsLoading extends CollegeSettingsState {}

class CollegeSettingsLoaded extends CollegeSettingsState {
  final CollegeSettingsData data;
  final bool isPasswordUpdating;
  final bool passwordSaved;
  final String? passwordError;
  final String? toastMessage;
  final bool isToastSuccess;

  const CollegeSettingsLoaded({
    required this.data,
    this.isPasswordUpdating = false,
    this.passwordSaved = false,
    this.passwordError,
    this.toastMessage,
    this.isToastSuccess = true,
  });

  CollegeSettingsLoaded copyWith({
    CollegeSettingsData? data,
    bool? isPasswordUpdating,
    bool? passwordSaved,
    String? passwordError,
    bool clearPasswordError = false,
    String? toastMessage,
    bool? isToastSuccess,
    bool clearToast = false,
  }) {
    return CollegeSettingsLoaded(
      data: data ?? this.data,
      isPasswordUpdating: isPasswordUpdating ?? this.isPasswordUpdating,
      passwordSaved: passwordSaved ?? this.passwordSaved,
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isToastSuccess: isToastSuccess ?? this.isToastSuccess,
    );
  }

  @override
  List<Object?> get props => [
        data,
        isPasswordUpdating,
        passwordSaved,
        passwordError,
        toastMessage,
        isToastSuccess,
      ];
}

class CollegeSettingsError extends CollegeSettingsState {
  final String message;
  const CollegeSettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// =============================================================================
// BLOC
// =============================================================================
class CollegeSettingsBloc
    extends Bloc<CollegeSettingsEvent, CollegeSettingsState> {
  final CollegeSettingsApiService _apiService;

  CollegeSettingsBloc({CollegeSettingsApiService? apiService})
      : _apiService = apiService ?? CollegeSettingsApiService(),
        super(CollegeSettingsInitial()) {
    on<FetchCollegeSettingsEvent>(_onFetchSettings);
    on<RefreshCollegeSettingsEvent>(_onRefreshSettings);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ToggleTwoFactorEvent>(_onToggleTwoFactor);
    on<UpdateNotificationPreferenceEvent>(_onUpdateNotificationPreference);
    on<UpdatePlacementCycleThresholdEvent>(_onUpdatePlacementCycleThreshold);
    on<ToggleAutoNotifyEligibleEvent>(_onToggleAutoNotifyEligible);
    on<ExportInstitutionDataEvent>(_onExportData);
    on<DeactivateCollegeAccountEvent>(_onDeactivateAccount);
    on<ClearCollegeSettingsToastEvent>(_onClearToast);
  }

  Future<void> _onFetchSettings(
    FetchCollegeSettingsEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    emit(CollegeSettingsLoading());
    try {
      final data = await _apiService.fetchSettingsData();
      emit(CollegeSettingsLoaded(data: data));
    } catch (e) {
      emit(CollegeSettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSettings(
    RefreshCollegeSettingsEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    try {
      final data = await _apiService.fetchSettingsData();
      if (state is CollegeSettingsLoaded) {
        final current = state as CollegeSettingsLoaded;
        emit(current.copyWith(data: data));
      } else {
        emit(CollegeSettingsLoaded(data: data));
      }
    } catch (e) {
      if (state is CollegeSettingsLoaded) {
        final current = state as CollegeSettingsLoaded;
        emit(current.copyWith(
          toastMessage: 'Could not refresh from server',
          isToastSuccess: false,
        ));
      }
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    if (event.currentPassword.trim().isEmpty ||
        event.newPassword.trim().isEmpty ||
        event.confirmPassword.trim().isEmpty) {
      emit(current.copyWith(
        passwordError: 'Fill in all password fields.',
        passwordSaved: false,
      ));
      return;
    }

    if (event.newPassword != event.confirmPassword) {
      emit(current.copyWith(
        passwordError: "New password and confirmation don't match.",
        passwordSaved: false,
      ));
      return;
    }

    if (event.newPassword.length < 8) {
      emit(current.copyWith(
        passwordError: 'Password must be at least 8 characters.',
        passwordSaved: false,
      ));
      return;
    }

    emit(current.copyWith(
      isPasswordUpdating: true,
      clearPasswordError: true,
      passwordSaved: false,
    ));

    await _apiService.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    emit(current.copyWith(
      isPasswordUpdating: false,
      passwordSaved: true,
      clearPasswordError: true,
      toastMessage: 'Password updated successfully.',
      isToastSuccess: true,
    ));
  }

  Future<void> _onToggleTwoFactor(
    ToggleTwoFactorEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    final updatedSecurity = current.data.security.copyWith(
      twoFactorEnabled: event.enabled,
    );
    final updatedData = current.data.copyWith(security: updatedSecurity);

    emit(current.copyWith(
      data: updatedData,
      toastMessage: event.enabled
          ? 'Two-factor authentication enabled.'
          : 'Two-factor authentication disabled.',
      isToastSuccess: true,
    ));

    await _apiService.updateTwoFactor(event.enabled);
  }

  Future<void> _onUpdateNotificationPreference(
    UpdateNotificationPreferenceEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    final updatedNotifications = current.data.notifications.copyWith(
      notifyEmail: event.notifyEmail,
      notifySms: event.notifySms,
      notifyRecruiter: event.notifyRecruiter,
      notifyDigest: event.notifyDigest,
      notifyDrives: event.notifyDrives,
    );
    final updatedData = current.data.copyWith(notifications: updatedNotifications);

    emit(current.copyWith(
      data: updatedData,
      toastMessage: 'Notification preferences updated.',
      isToastSuccess: true,
    ));

    await _apiService.updateNotifications(updatedNotifications);
  }

  Future<void> _onUpdatePlacementCycleThreshold(
    UpdatePlacementCycleThresholdEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    final updatedCycle = current.data.placementCycle.copyWith(
      eligibilityThreshold: event.threshold,
    );
    final updatedData = current.data.copyWith(placementCycle: updatedCycle);

    emit(current.copyWith(data: updatedData));
    await _apiService.updatePlacementCycle(updatedCycle);
  }

  Future<void> _onToggleAutoNotifyEligible(
    ToggleAutoNotifyEligibleEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    final updatedCycle = current.data.placementCycle.copyWith(
      autoNotifyEligible: event.enabled,
    );
    final updatedData = current.data.copyWith(placementCycle: updatedCycle);

    emit(current.copyWith(
      data: updatedData,
      toastMessage: 'Placement cycle preferences updated.',
      isToastSuccess: true,
    ));

    await _apiService.updatePlacementCycle(updatedCycle);
  }

  Future<void> _onExportData(
    ExportInstitutionDataEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    emit(current.copyWith(
      toastMessage: 'Institution placement data CSV export initiated.',
      isToastSuccess: true,
    ));

    await _apiService.exportInstitutionData();
  }

  Future<void> _onDeactivateAccount(
    DeactivateCollegeAccountEvent event,
    Emitter<CollegeSettingsState> emit,
  ) async {
    if (state is! CollegeSettingsLoaded) return;
    final current = state as CollegeSettingsLoaded;

    emit(current.copyWith(
      toastMessage: 'Account deactivation request submitted.',
      isToastSuccess: true,
    ));

    await _apiService.deactivateAccount();
  }

  void _onClearToast(
    ClearCollegeSettingsToastEvent event,
    Emitter<CollegeSettingsState> emit,
  ) {
    if (state is CollegeSettingsLoaded) {
      final current = state as CollegeSettingsLoaded;
      emit(current.copyWith(clearToast: true));
    }
  }
}
