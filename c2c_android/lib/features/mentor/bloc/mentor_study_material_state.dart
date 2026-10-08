import 'package:equatable/equatable.dart';
import '../data/models/mentor_study_material_model.dart';

abstract class MentorStudyMaterialState extends Equatable {
  const MentorStudyMaterialState();

  @override
  List<Object?> get props => [];
}

class StudyMaterialInitial extends MentorStudyMaterialState {
  const StudyMaterialInitial();
}

class StudyMaterialLoading extends MentorStudyMaterialState {
  const StudyMaterialLoading();
}

class StudyMaterialLoaded extends MentorStudyMaterialState {
  final MentorStudyMaterialPayload data;
  final String selectedCategory; // 'All', 'Interview Questions', 'Coding Sheets', 'PDFs', 'Resume Templates', 'Company Experiences', 'Videos'
  final String searchQuery;
  final List<MentorStudyMaterialModel> filteredResources;
  final bool isSubmitting;
  final String? toastMessage;

  const StudyMaterialLoaded({
    required this.data,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    required this.filteredResources,
    this.isSubmitting = false,
    this.toastMessage,
  });

  StudyMaterialLoaded copyWith({
    MentorStudyMaterialPayload? data,
    String? selectedCategory,
    String? searchQuery,
    List<MentorStudyMaterialModel>? filteredResources,
    bool? isSubmitting,
    String? toastMessage,
  }) {
    return StudyMaterialLoaded(
      data: data ?? this.data,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredResources: filteredResources ?? this.filteredResources,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        data,
        selectedCategory,
        searchQuery,
        filteredResources,
        isSubmitting,
        toastMessage,
      ];
}

class StudyMaterialError extends MentorStudyMaterialState {
  final String message;

  const StudyMaterialError(this.message);

  @override
  List<Object?> get props => [message];
}
