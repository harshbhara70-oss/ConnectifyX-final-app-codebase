import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/recruiter_settings_repository.dart';
import 'recruiter_settings_event.dart';
import 'recruiter_settings_state.dart';

class RecruiterSettingsBloc extends Bloc<RecruiterSettingsEvent, RecruiterSettingsState> {
  final RecruiterSettingsRepository _repository;

  RecruiterSettingsBloc({RecruiterSettingsRepository? repository})
      : _repository = repository ?? RecruiterSettingsRepository(),
        super(const RecruiterSettingsInitial()) {
    on<FetchRecruiterSettingsEvent>(_onFetchSettings);
    on<ChangeSettingsTabEvent>(_onChangeTab);
    on<SaveRecruiterSettingsEvent>(_onSaveSettings);
    on<RequestAdminEditEvent>(_onRequestAdminEdit);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
    on<InviteTeamMemberEvent>(_onInviteTeamMember);
  }

  Future<void> _onFetchSettings(
    FetchRecruiterSettingsEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) async {
    emit(const RecruiterSettingsLoading());
    try {
      final settings = await _repository.fetchSettings();
      emit(RecruiterSettingsLoaded(settings: settings));
    } catch (e) {
      emit(RecruiterSettingsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onChangeTab(
    ChangeSettingsTabEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) {
    if (state is RecruiterSettingsLoaded) {
      final current = state as RecruiterSettingsLoaded;
      emit(current.copyWith(activeTab: event.tab));
    }
  }

  Future<void> _onSaveSettings(
    SaveRecruiterSettingsEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) async {
    if (state is! RecruiterSettingsLoaded) return;
    final current = state as RecruiterSettingsLoaded;

    emit(current.copyWith(isSaving: true, successMessage: null, errorMessage: null));
    try {
      final updated = await _repository.saveSettings(
        repName: event.repName,
        companyName: event.companyName,
        websiteUrl: event.websiteUrl,
        aboutCompany: event.aboutCompany,
        logoUrl: event.logoUrl,
      );
      emit(current.copyWith(
        settings: updated,
        isSaving: false,
        successMessage: 'Company profile submitted for Admin Verification successfully!',
      ));
    } catch (e) {
      emit(current.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRequestAdminEdit(
    RequestAdminEditEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) async {
    if (state is! RecruiterSettingsLoaded) return;
    final current = state as RecruiterSettingsLoaded;

    emit(current.copyWith(isSaving: true, successMessage: null, errorMessage: null));
    try {
      final msg = await _repository.requestAdminEdit(companyName: event.companyName);
      emit(current.copyWith(
        isSaving: false,
        successMessage: msg,
      ));
    } catch (e) {
      emit(current.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateNotificationPreferences(
    UpdateNotificationPreferencesEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) async {
    if (state is! RecruiterSettingsLoaded) return;
    final current = state as RecruiterSettingsLoaded;

    try {
      final updated = await _repository.updateNotificationPreferences(preferences: event.preferences);
      emit(current.copyWith(
        settings: updated,
        successMessage: 'Notification preferences updated successfully!',
      ));
    } catch (e) {
      emit(current.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onInviteTeamMember(
    InviteTeamMemberEvent event,
    Emitter<RecruiterSettingsState> emit,
  ) async {
    if (state is! RecruiterSettingsLoaded) return;
    final current = state as RecruiterSettingsLoaded;

    try {
      final updated = await _repository.inviteTeamMember(
        name: event.name,
        email: event.email,
        role: event.role,
      );
      emit(current.copyWith(
        settings: updated,
        successMessage: 'Team invite dispatched to ${event.email}!',
      ));
    } catch (e) {
      emit(current.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
