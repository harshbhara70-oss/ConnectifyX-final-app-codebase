import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/admin_content_models.dart';
import '../data/services/admin_api_service.dart';
import 'admin_content_hub_event.dart';
import 'admin_content_hub_state.dart';

class AdminContentHubBloc extends Bloc<AdminContentHubEvent, AdminContentHubState> {
  final AdminApiService _apiService;

  AdminContentHubBloc({AdminApiService? apiService})
      : _apiService = apiService ?? AdminApiService(),
        super(const AdminContentHubState()) {
    on<FetchContentHubData>(_onFetchContentHubData);
    on<SelectContentTab>(_onSelectContentTab);
    on<UpdateRoadmapCategoryFilter>(_onUpdateRoadmapCategoryFilter);
    on<UpdateRoadmapStatusFilter>(_onUpdateRoadmapStatusFilter);
    on<UpdateResourceCategoryFilter>(_onUpdateResourceCategoryFilter);
    on<UpdateResourceTypeFilter>(_onUpdateResourceTypeFilter);
    on<UpdateContentSearchQuery>(_onUpdateContentSearchQuery);
    on<ToggleRoadmapStarAction>(_onToggleRoadmapStarAction);
    on<CreateRoadmapAction>(_onCreateRoadmapAction);
    on<UpdateRoadmapAction>(_onUpdateRoadmapAction);
    on<DeleteRoadmapAction>(_onDeleteRoadmapAction);
    on<CreateResourceAction>(_onCreateResourceAction);
    on<DeleteResourceAction>(_onDeleteResourceAction);
    on<ToggleResourceStarAction>(_onToggleResourceStarAction);
    on<ToggleSelectRoadmapItem>(_onToggleSelectRoadmapItem);
    on<ToggleSelectAllRoadmaps>(_onToggleSelectAllRoadmaps);
    on<ChangeContentPage>(_onChangeContentPage);
  }

  Future<void> _onFetchContentHubData(
    FetchContentHubData event,
    Emitter<AdminContentHubState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(state.copyWith(status: ContentHubStatus.loading));
    }

    try {
      final results = await Future.wait([
        _apiService.fetchRoadmaps(),
        _apiService.fetchResources(),
      ]);

      final roadmaps = results[0] as List<AdminRoadmapModel>;
      final resources = results[1] as List<AdminResourceModel>;

      final isMockData = roadmaps.any((r) => r.isMock) || resources.any((res) => res.isMock);

      emit(state.copyWith(
        status: ContentHubStatus.loaded,
        roadmaps: roadmaps,
        resources: resources,
        isMock: isMockData,
        selectedRoadmapIds: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ContentHubStatus.failure,
        errorMessage: 'Failed to load content hub data: ${e.toString()}',
      ));
    }
  }

  void _onSelectContentTab(
    SelectContentTab event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      activeTab: event.tab,
      currentPage: 1,
      selectedRoadmapIds: {},
      searchQuery: '',
    ));
  }

  void _onUpdateRoadmapCategoryFilter(
    UpdateRoadmapCategoryFilter event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      roadmapCategoryFilter: event.category,
      currentPage: 1,
    ));
  }

  void _onUpdateRoadmapStatusFilter(
    UpdateRoadmapStatusFilter event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      roadmapStatusFilter: event.status,
      currentPage: 1,
    ));
  }

  void _onUpdateResourceCategoryFilter(
    UpdateResourceCategoryFilter event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      resourceCategoryFilter: event.category,
      currentPage: 1,
    ));
  }

  void _onUpdateResourceTypeFilter(
    UpdateResourceTypeFilter event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      resourceTypeFilter: event.type,
      currentPage: 1,
    ));
  }

  void _onUpdateContentSearchQuery(
    UpdateContentSearchQuery event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: event.query,
      currentPage: 1,
    ));
  }

  Future<void> _onToggleRoadmapStarAction(
    ToggleRoadmapStarAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    final updatedRoadmaps = state.roadmaps.map((r) {
      if (r.id == event.roadmapId) {
        return r.copyWith(starred: !r.starred);
      }
      return r;
    }).toList();

    emit(state.copyWith(roadmaps: updatedRoadmaps));

    try {
      final target = updatedRoadmaps.firstWhere((r) => r.id == event.roadmapId);
      await _apiService.updateRoadmap(event.roadmapId, {'starred': target.starred});
    } catch (_) {}
  }

  Future<void> _onCreateRoadmapAction(
    CreateRoadmapAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    try {
      final newRoadmap = await _apiService.createRoadmap({
        'title': event.title,
        'category': event.category,
        'status': event.status,
      });

      final updatedRoadmaps = [newRoadmap, ...state.roadmaps];
      emit(state.copyWith(
        roadmaps: updatedRoadmaps,
        actionMessage: 'Roadmap "${event.title}" created successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to create roadmap: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateRoadmapAction(
    UpdateRoadmapAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    try {
      final updated = await _apiService.updateRoadmap(event.roadmap.id, event.roadmap.toJson());
      final updatedList = state.roadmaps.map((r) => r.id == event.roadmap.id ? updated : r).toList();
      emit(state.copyWith(
        roadmaps: updatedList,
        actionMessage: 'Roadmap "${event.roadmap.title}" updated successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to update roadmap: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteRoadmapAction(
    DeleteRoadmapAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    final target = state.roadmaps.firstWhere((r) => r.id == event.roadmapId, orElse: () => const AdminRoadmapModel(id: '', title: '', lastUpdated: ''));
    final updatedList = state.roadmaps.where((r) => r.id != event.roadmapId).toList();
    final updatedSelected = Set<String>.from(state.selectedRoadmapIds)..remove(event.roadmapId);

    emit(state.copyWith(
      roadmaps: updatedList,
      selectedRoadmapIds: updatedSelected,
      actionMessage: 'Roadmap "${target.title}" deleted.',
    ));

    try {
      await _apiService.deleteRoadmap(event.roadmapId);
    } catch (_) {}
  }

  Future<void> _onCreateResourceAction(
    CreateResourceAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    try {
      final newResource = await _apiService.createResource({
        'title': event.title,
        'category': event.category,
        'type': event.type,
        'description': event.description,
        'url': event.url,
        'fileSize': event.fileSize,
      });

      final updatedResources = [newResource, ...state.resources];
      emit(state.copyWith(
        resources: updatedResources,
        actionMessage: 'Resource "${event.title}" added to library!',
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to add resource: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteResourceAction(
    DeleteResourceAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    final target = state.resources.firstWhere((r) => r.id == event.resourceId, orElse: () => const AdminResourceModel(id: '', title: '', lastUpdated: ''));
    final updatedList = state.resources.where((r) => r.id != event.resourceId).toList();

    emit(state.copyWith(
      resources: updatedList,
      actionMessage: 'Resource "${target.title}" deleted.',
    ));

    try {
      await _apiService.deleteResource(event.resourceId);
    } catch (_) {}
  }

  Future<void> _onToggleResourceStarAction(
    ToggleResourceStarAction event,
    Emitter<AdminContentHubState> emit,
  ) async {
    final updatedResources = state.resources.map((r) {
      if (r.id == event.resourceId) {
        return r.copyWith(starred: !r.starred);
      }
      return r;
    }).toList();

    emit(state.copyWith(resources: updatedResources));
  }

  void _onToggleSelectRoadmapItem(
    ToggleSelectRoadmapItem event,
    Emitter<AdminContentHubState> emit,
  ) {
    final updated = Set<String>.from(state.selectedRoadmapIds);
    if (updated.contains(event.roadmapId)) {
      updated.remove(event.roadmapId);
    } else {
      updated.add(event.roadmapId);
    }
    emit(state.copyWith(selectedRoadmapIds: updated));
  }

  void _onToggleSelectAllRoadmaps(
    ToggleSelectAllRoadmaps event,
    Emitter<AdminContentHubState> emit,
  ) {
    final Set<String> visibleIds = {};
    for (final rm in state.paginatedRoadmaps) {
      visibleIds.add(rm.id);
    }

    final bool allSelected = visibleIds.isNotEmpty && visibleIds.every(state.selectedRoadmapIds.contains);

    final updated = Set<String>.from(state.selectedRoadmapIds);
    if (allSelected) {
      updated.removeAll(visibleIds);
    } else {
      updated.addAll(visibleIds);
    }

    emit(state.copyWith(selectedRoadmapIds: updated));
  }

  void _onChangeContentPage(
    ChangeContentPage event,
    Emitter<AdminContentHubState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }
}
