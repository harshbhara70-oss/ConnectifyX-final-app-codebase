import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class MentorCareerRoadmapsState extends Equatable {
  const MentorCareerRoadmapsState();

  @override
  List<Object?> get props => [];
}

class MentorCareerRoadmapsInitial extends MentorCareerRoadmapsState {
  const MentorCareerRoadmapsInitial();
}

class MentorCareerRoadmapsLoading extends MentorCareerRoadmapsState {
  const MentorCareerRoadmapsLoading();
}

class MentorCareerRoadmapsLoaded extends MentorCareerRoadmapsState {
  final List<MentorStudentModel> allStudents;
  final List<MentorStudentModel> filteredStudents;
  final String selectedStage;
  final String searchQuery;
  final bool isMock;
  final int totalMilestones;
  final int completedMilestones;
  final int inProgressMilestones;
  final int placementReadyCount;
  final bool isUpdating;
  final String? updatingStudentId;

  const MentorCareerRoadmapsLoaded({
    required this.allStudents,
    required this.filteredStudents,
    this.selectedStage = 'All',
    this.searchQuery = '',
    this.isMock = false,
    this.totalMilestones = 0,
    this.completedMilestones = 0,
    this.inProgressMilestones = 0,
    this.placementReadyCount = 0,
    this.isUpdating = false,
    this.updatingStudentId,
  });

  MentorCareerRoadmapsLoaded copyWith({
    List<MentorStudentModel>? allStudents,
    List<MentorStudentModel>? filteredStudents,
    String? selectedStage,
    String? searchQuery,
    bool? isMock,
    int? totalMilestones,
    int? completedMilestones,
    int? inProgressMilestones,
    int? placementReadyCount,
    bool? isUpdating,
    String? updatingStudentId,
    bool clearUpdatingId = false,
  }) {
    return MentorCareerRoadmapsLoaded(
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      selectedStage: selectedStage ?? this.selectedStage,
      searchQuery: searchQuery ?? this.searchQuery,
      isMock: isMock ?? this.isMock,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      inProgressMilestones:
          inProgressMilestones ?? this.inProgressMilestones,
      placementReadyCount: placementReadyCount ?? this.placementReadyCount,
      isUpdating: isUpdating ?? this.isUpdating,
      updatingStudentId:
          clearUpdatingId ? null : (updatingStudentId ?? this.updatingStudentId),
    );
  }

  @override
  List<Object?> get props => [
        allStudents,
        filteredStudents,
        selectedStage,
        searchQuery,
        isMock,
        totalMilestones,
        completedMilestones,
        inProgressMilestones,
        placementReadyCount,
        isUpdating,
        updatingStudentId,
      ];
}

class MentorCareerRoadmapsError extends MentorCareerRoadmapsState {
  final String message;
  final bool isMock;

  const MentorCareerRoadmapsError({
    required this.message,
    this.isMock = false,
  });

  @override
  List<Object?> get props => [message, isMock];
}
