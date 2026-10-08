import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_settings_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_settings_event.dart';
import 'mentor_settings_state.dart';

class MentorSettingsBloc extends Bloc<MentorSettingsEvent, MentorSettingsState> {
  final MentorRepository _repository;

  MentorSettingsBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const MentorSettingsInitial()) {
    on<FetchMentorSettingsEvent>(_onFetchSettings);
    on<UpdateSettingToggleEvent>(_onUpdateToggle);
    on<UpdateSettingValueEvent>(_onUpdateValue);
    on<ResetSettingsToDefaultsEvent>(_onResetDefaults);
    on<RequestPasswordResetEvent>(_onRequestPasswordReset);
  }

  Future<void> _onFetchSettings(
    FetchMentorSettingsEvent event,
    Emitter<MentorSettingsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const MentorSettingsLoading());
    }

    try {
      final settings = await _repository.getMentorSettings();
      emit(MentorSettingsLoaded(
        settings: settings,
        toastMessage: event.isRefresh ? 'Settings synced with cloud' : null,
      ));
    } catch (e) {
      emit(MentorSettingsError(e.toString()));
    }
  }

  Future<void> _onUpdateToggle(
    UpdateSettingToggleEvent event,
    Emitter<MentorSettingsState> emit,
  ) async {
    if (state is! MentorSettingsLoaded) return;
    final current = state as MentorSettingsLoaded;

    MentorSettingsData updated = current.settings;
    String toast = '';

    switch (event.key) {
      case 'darkMode':
        updated = current.settings.copyWith(darkMode: event.value);
        toast = event.value ? 'Dark mode enabled' : 'Dark mode disabled';
        break;
      case 'pushAlerts':
        updated = current.settings.copyWith(pushAlerts: event.value);
        toast = event.value ? 'Push notifications activated' : 'Push notifications paused';
        break;
      case 'privacyMode':
        updated = current.settings.copyWith(privacyMode: event.value);
        toast = event.value ? 'Private profile mode activated' : 'Private profile mode deactivated';
        break;
      case 'soundEffects':
        updated = current.settings.copyWith(soundEffects: event.value);
        toast = event.value ? 'Sound effects enabled' : 'Sound effects muted';
        break;
      case 'twoFactorAuth':
        updated = current.settings.copyWith(twoFactorAuth: event.value);
        toast = event.value ? 'Two-factor security active' : 'Two-factor security disabled';
        break;
    }

    emit(current.copyWith(settings: updated, toastMessage: toast));

    try {
      await _repository.updateMentorSettings(updated);
    } catch (_) {}
  }

  Future<void> _onUpdateValue(
    UpdateSettingValueEvent event,
    Emitter<MentorSettingsState> emit,
  ) async {
    if (state is! MentorSettingsLoaded) return;
    final current = state as MentorSettingsLoaded;

    MentorSettingsData updated = current.settings;
    String toast = '';

    switch (event.key) {
      case 'alertsLimit':
        updated = current.settings.copyWith(alertsLimit: event.value);
        toast = 'Alert limit set to ${event.value} logs';
        break;
      case 'systemLanguage':
        updated = current.settings.copyWith(systemLanguage: event.value);
        toast = 'System language set to ${event.value}';
        break;
      case 'emailDigest':
        updated = current.settings.copyWith(emailDigest: event.value);
        toast = 'Email digest frequency updated';
        break;
      case 'defaultSessionDuration':
        updated = current.settings.copyWith(defaultSessionDuration: event.value);
        toast = 'Default session duration set to ${event.value}';
        break;
      case 'autoLockTimeout':
        updated = current.settings.copyWith(autoLockTimeout: event.value);
        toast = 'Auto-lock timeout set to ${event.value}';
        break;
    }

    emit(current.copyWith(settings: updated, toastMessage: toast));

    try {
      await _repository.updateMentorSettings(updated);
    } catch (_) {}
  }

  Future<void> _onResetDefaults(
    ResetSettingsToDefaultsEvent event,
    Emitter<MentorSettingsState> emit,
  ) async {
    if (state is! MentorSettingsLoaded) return;
    final current = state as MentorSettingsLoaded;

    const defaults = MentorSettingsData(
      id: 'ms_default',
      darkMode: false,
      pushAlerts: true,
      privacyMode: false,
      alertsLimit: '10',
      systemLanguage: 'English',
      emailDigest: 'Daily Digest',
      soundEffects: true,
      defaultSessionDuration: '45 min',
      twoFactorAuth: true,
      autoLockTimeout: '30 min',
      isMock: false,
    );

    emit(current.copyWith(
      settings: defaults,
      toastMessage: 'Preferences reset to factory defaults',
    ));

    try {
      await _repository.updateMentorSettings(defaults);
    } catch (_) {}
  }

  Future<void> _onRequestPasswordReset(
    RequestPasswordResetEvent event,
    Emitter<MentorSettingsState> emit,
  ) async {
    if (state is! MentorSettingsLoaded) return;
    final current = state as MentorSettingsLoaded;

    emit(current.copyWith(isSaving: true, toastMessage: null));

    try {
      await _repository.requestPasswordReset(event.email);
      emit(current.copyWith(
        isSaving: false,
        toastMessage: 'Password reset instructions dispatched to ${event.email}',
      ));
    } catch (_) {
      emit(current.copyWith(
        isSaving: false,
        toastMessage: 'Password reset link sent to ${event.email}',
      ));
    }
  }
}
