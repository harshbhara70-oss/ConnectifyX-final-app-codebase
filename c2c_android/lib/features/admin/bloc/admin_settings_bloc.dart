import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/admin_api_service.dart';
import 'admin_settings_event.dart';
import 'admin_settings_state.dart';

class AdminSettingsBloc extends Bloc<AdminSettingsEvent, AdminSettingsState> {
  final AdminApiService _apiService;

  AdminSettingsBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(AdminSettingsInitial()) {
    on<FetchAdminSettingsEvent>(_onFetchSettings);
    on<ChangeSettingsCategoryEvent>(_onChangeCategory);
    on<UpdateAiWeightEvent>(_onUpdateAiWeight);
    on<SaveAiWeightsEvent>(_onSaveAiWeights);
    on<ToggleMaintenanceModeEvent>(_onToggleMaintenance);
    on<ToggleIntegrationEvent>(_onToggleIntegration);
    on<UpdateGeneralSettingsEvent>(_onUpdateGeneralSettings);
  }

  Future<void> _onFetchSettings(
    FetchAdminSettingsEvent event,
    Emitter<AdminSettingsState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(AdminSettingsLoading());
    }

    try {
      final data = await _apiService.fetchAdminSettings();
      emit(AdminSettingsLoaded(
        settings: data,
        activeCategory: 'ai',
      ));
    } catch (e) {
      emit(AdminSettingsError('Failed to load settings: ${e.toString()}'));
    }
  }

  void _onChangeCategory(
    ChangeSettingsCategoryEvent event,
    Emitter<AdminSettingsState> emit,
  ) {
    if (state is AdminSettingsLoaded) {
      final loaded = state as AdminSettingsLoaded;
      emit(loaded.copyWith(
        activeCategory: event.categoryId,
        clearToast: true,
      ));
    }
  }

  void _onUpdateAiWeight(
    UpdateAiWeightEvent event,
    Emitter<AdminSettingsState> emit,
  ) {
    if (state is AdminSettingsLoaded) {
      final loaded = state as AdminSettingsLoaded;
      final current = loaded.settings.aiWeights;

      final updated = current.copyWith(
        academicWeight: event.academic ?? current.academicWeight,
        softSkillsWeight: event.softSkills ?? current.softSkillsWeight,
        techProjectsWeight: event.techProjects ?? current.techProjectsWeight,
        extracurricularWeight: event.extracurricular ?? current.extracurricularWeight,
      );

      emit(loaded.copyWith(
        settings: loaded.settings.copyWith(aiWeights: updated),
        clearToast: true,
      ));
    }
  }

  Future<void> _onSaveAiWeights(
    SaveAiWeightsEvent event,
    Emitter<AdminSettingsState> emit,
  ) async {
    if (state is! AdminSettingsLoaded) return;
    final loaded = state as AdminSettingsLoaded;

    emit(loaded.copyWith(isSaving: true, clearToast: true));

    await _apiService.updateAiWeights(loaded.settings.aiWeights);

    emit(loaded.copyWith(
      isSaving: false,
      toastNotification: 'AI Readiness weights saved successfully.',
    ));
  }

  Future<void> _onToggleMaintenance(
    ToggleMaintenanceModeEvent event,
    Emitter<AdminSettingsState> emit,
  ) async {
    if (state is! AdminSettingsLoaded) return;
    final loaded = state as AdminSettingsLoaded;

    final newStatus = !loaded.settings.maintenanceEnabled;

    await _apiService.toggleMaintenanceMode(newStatus);

    emit(loaded.copyWith(
      settings: loaded.settings.copyWith(maintenanceEnabled: newStatus),
      toastNotification: newStatus
          ? 'Maintenance mode ACTIVATED. Non-admin sessions suspended.'
          : 'Maintenance mode DISABLED. Normal platform operations resumed.',
    ));
  }

  void _onToggleIntegration(
    ToggleIntegrationEvent event,
    Emitter<AdminSettingsState> emit,
  ) {
    if (state is! AdminSettingsLoaded) return;
    final loaded = state as AdminSettingsLoaded;

    final updated = loaded.settings.integrations.map((i) {
      if (i.id == event.integrationId) {
        final nextConnected = !i.isConnected;
        return i.copyWith(
          isConnected: nextConnected,
          status: nextConnected ? 'Connected' : 'Configure',
        );
      }
      return i;
    }).toList();

    emit(loaded.copyWith(
      settings: loaded.settings.copyWith(integrations: updated),
      toastNotification: 'Integration status updated.',
    ));
  }

  Future<void> _onUpdateGeneralSettings(
    UpdateGeneralSettingsEvent event,
    Emitter<AdminSettingsState> emit,
  ) async {
    if (state is! AdminSettingsLoaded) return;
    final loaded = state as AdminSettingsLoaded;

    emit(loaded.copyWith(isSaving: true, clearToast: true));

    await _apiService.updateGeneralSettings(event.general);

    emit(loaded.copyWith(
      settings: loaded.settings.copyWith(general: event.general),
      isSaving: false,
      toastNotification: 'Platform settings saved successfully.',
    ));
  }
}
