import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_study_material_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_study_material_event.dart';
import 'mentor_study_material_state.dart';

class MentorStudyMaterialBloc
    extends Bloc<MentorStudyMaterialEvent, MentorStudyMaterialState> {
  final MentorRepository _repository;

  MentorStudyMaterialBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const StudyMaterialInitial()) {
    on<FetchStudyMaterialsEvent>(_onFetchData);
    on<FilterStudyMaterialCategoryEvent>(_onFilterCategory);
    on<SearchStudyMaterialsEvent>(_onSearch);
    on<UploadStudyMaterialEvent>(_onUpload);
    on<DeleteStudyMaterialEvent>(_onDelete);
    on<DownloadStudyMaterialEvent>(_onDownload);
  }

  Future<void> _onFetchData(
    FetchStudyMaterialsEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const StudyMaterialLoading());
    }
    try {
      final payload = await _repository.getStudyMaterials();
      final filtered = _filter(
        all: payload.resources,
        category: 'All',
        query: '',
      );

      emit(StudyMaterialLoaded(
        data: payload,
        selectedCategory: 'All',
        searchQuery: '',
        filteredResources: filtered,
      ));
    } catch (e) {
      emit(StudyMaterialError('Failed to load study materials: ${e.toString()}'));
    }
  }

  void _onFilterCategory(
    FilterStudyMaterialCategoryEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) {
    if (state is StudyMaterialLoaded) {
      final current = state as StudyMaterialLoaded;
      final filtered = _filter(
        all: current.data.resources,
        category: event.category,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        selectedCategory: event.category,
        filteredResources: filtered,
      ));
    }
  }

  void _onSearch(
    SearchStudyMaterialsEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) {
    if (state is StudyMaterialLoaded) {
      final current = state as StudyMaterialLoaded;
      final filtered = _filter(
        all: current.data.resources,
        category: current.selectedCategory,
        query: event.query,
      );

      emit(current.copyWith(
        searchQuery: event.query,
        filteredResources: filtered,
      ));
    }
  }

  Future<void> _onUpload(
    UploadStudyMaterialEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) async {
    if (state is StudyMaterialLoaded) {
      final current = state as StudyMaterialLoaded;
      emit(current.copyWith(isSubmitting: true));

      final newMaterial = MentorStudyMaterialModel(
        id: 'r_${DateTime.now().millisecondsSinceEpoch}',
        title: event.title.trim(),
        category: event.category,
        uploadedAt: DateTime.now().toISOString().split('T')[0],
        size: event.size.isNotEmpty ? event.size : '1.5 MB',
        fileUrl: event.fileUrl.trim(),
        description: event.description.trim(),
        downloadCount: 0,
        isMock: false,
      );

      final uploaded = await _repository.createStudyMaterial(newMaterial);

      final updatedList = [uploaded, ...current.data.resources];
      final uniqueCategories = Set<String>.from(updatedList.map((e) => e.category)).length;
      final totalCount = updatedList.length;

      final updatedPayload = current.data.copyWith(
        resources: updatedList,
        totalCount: totalCount,
        categoriesCount: uniqueCategories,
      );

      final filtered = _filter(
        all: updatedList,
        category: current.selectedCategory,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        data: updatedPayload,
        filteredResources: filtered,
        isSubmitting: false,
        toastMessage: 'Material uploaded: ${uploaded.title}',
      ));
    }
  }

  Future<void> _onDelete(
    DeleteStudyMaterialEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) async {
    if (state is StudyMaterialLoaded) {
      final current = state as StudyMaterialLoaded;

      final updatedList =
          current.data.resources.where((r) => r.id != event.materialId).toList();
      final uniqueCategories = Set<String>.from(updatedList.map((e) => e.category)).length;

      final updatedPayload = current.data.copyWith(
        resources: updatedList,
        totalCount: updatedList.length,
        categoriesCount: uniqueCategories,
      );

      final filtered = _filter(
        all: updatedList,
        category: current.selectedCategory,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        data: updatedPayload,
        filteredResources: filtered,
        toastMessage: 'Resource deleted from library.',
      ));

      await _repository.deleteStudyMaterial(event.materialId);
    }
  }

  Future<void> _onDownload(
    DownloadStudyMaterialEvent event,
    Emitter<MentorStudyMaterialState> emit,
  ) async {
    if (state is StudyMaterialLoaded) {
      final current = state as StudyMaterialLoaded;

      final updatedList = current.data.resources.map((r) {
        if (r.id == event.material.id) {
          return r.copyWith(downloadCount: r.downloadCount + 1);
        }
        return r;
      }).toList();

      final totalDownloads = current.data.totalDownloads + 1;

      final updatedPayload = current.data.copyWith(
        resources: updatedList,
        totalDownloads: totalDownloads,
      );

      final filtered = _filter(
        all: updatedList,
        category: current.selectedCategory,
        query: current.searchQuery,
      );

      emit(current.copyWith(
        data: updatedPayload,
        filteredResources: filtered,
        toastMessage: 'Downloading ${event.material.title} (${event.material.size})',
      ));

      await _repository.downloadStudyMaterial(event.material.id);
    }
  }

  List<MentorStudyMaterialModel> _filter({
    required List<MentorStudyMaterialModel> all,
    required String category,
    required String query,
  }) {
    return all.where((r) {
      if (category != 'All' && r.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchTitle = r.title.toLowerCase().contains(q);
        final matchCat = r.category.toLowerCase().contains(q);
        final matchDesc = r.description.toLowerCase().contains(q);
        if (!matchTitle && !matchCat && !matchDesc) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

extension on DateTime {
  String toISOString() => toIso8601String();
}
