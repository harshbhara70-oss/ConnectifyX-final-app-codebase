import 'package:equatable/equatable.dart';
import '../data/models/mentor_overview_model.dart';

abstract class StudentAnalyticsState extends Equatable {
  const StudentAnalyticsState();

  @override
  List<Object?> get props => [];
}

class StudentAnalyticsInitial extends StudentAnalyticsState {
  const StudentAnalyticsInitial();
}

class StudentAnalyticsLoading extends StudentAnalyticsState {
  const StudentAnalyticsLoading();
}

class StudentAnalyticsLoaded extends StudentAnalyticsState {
  final List<MentorStudentModel> allStudents;
  final List<MentorStudentModel> filteredStudents;
  final MentorStudentModel selectedStudent;
  final String selectedStage;
  final String searchQuery;
  final bool isMock;
  final bool isSavingNote;
  final bool isAddingStudent;
  final String? feedbackMessage;

  const StudentAnalyticsLoaded({
    required this.allStudents,
    required this.filteredStudents,
    required this.selectedStudent,
    this.selectedStage = 'All',
    this.searchQuery = '',
    this.isMock = true,
    this.isSavingNote = false,
    this.isAddingStudent = false,
    this.feedbackMessage,
  });

  StudentAnalyticsLoaded copyWith({
    List<MentorStudentModel>? allStudents,
    List<MentorStudentModel>? filteredStudents,
    MentorStudentModel? selectedStudent,
    String? selectedStage,
    String? searchQuery,
    bool? isMock,
    bool? isSavingNote,
    bool? isAddingStudent,
    String? feedbackMessage,
  }) {
    return StudentAnalyticsLoaded(
      allStudents: allStudents ?? this.allStudents,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      selectedStudent: selectedStudent ?? this.selectedStudent,
      selectedStage: selectedStage ?? this.selectedStage,
      searchQuery: searchQuery ?? this.searchQuery,
      isMock: isMock ?? this.isMock,
      isSavingNote: isSavingNote ?? this.isSavingNote,
      isAddingStudent: isAddingStudent ?? this.isAddingStudent,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
        allStudents,
        filteredStudents,
        selectedStudent,
        selectedStage,
        searchQuery,
        isMock,
        isSavingNote,
        isAddingStudent,
        feedbackMessage,
      ];
}

class StudentAnalyticsError extends StudentAnalyticsState {
  final String message;

  const StudentAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
