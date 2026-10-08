import 'package:equatable/equatable.dart';
import '../data/models/mentor_study_material_model.dart';

abstract class MentorStudyMaterialEvent extends Equatable {
  const MentorStudyMaterialEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial or refreshed Study Material Library items
class FetchStudyMaterialsEvent extends MentorStudyMaterialEvent {
  final bool isRefresh;

  const FetchStudyMaterialsEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Filter by document category (All, Interview Questions, Coding Sheets, PDFs, Resume Templates, Company Experiences, Videos)
class FilterStudyMaterialCategoryEvent extends MentorStudyMaterialEvent {
  final String category;

  const FilterStudyMaterialCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Search by title, keyword, or format
class SearchStudyMaterialsEvent extends MentorStudyMaterialEvent {
  final String query;

  const SearchStudyMaterialsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Upload a new study material
class UploadStudyMaterialEvent extends MentorStudyMaterialEvent {
  final String title;
  final String category;
  final String size;
  final String description;
  final String fileUrl;

  const UploadStudyMaterialEvent({
    required this.title,
    required this.category,
    this.size = '1.5 MB',
    this.description = '',
    this.fileUrl = '',
  });

  @override
  List<Object?> get props => [title, category, size, description, fileUrl];
}

/// Delete a study material
class DeleteStudyMaterialEvent extends MentorStudyMaterialEvent {
  final String materialId;

  const DeleteStudyMaterialEvent(this.materialId);

  @override
  List<Object?> get props => [materialId];
}

/// Download / Trigger download for a study material
class DownloadStudyMaterialEvent extends MentorStudyMaterialEvent {
  final MentorStudyMaterialModel material;

  const DownloadStudyMaterialEvent(this.material);

  @override
  List<Object?> get props => [material];
}
