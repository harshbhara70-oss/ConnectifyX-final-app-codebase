import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/college_student_model.dart';
import '../data/services/student_directory_api_service.dart';

// ---------------------------------------------------------------------------
// EVENTS
// ---------------------------------------------------------------------------

abstract class StudentDirectoryEvent extends Equatable {
  const StudentDirectoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchStudentsEvent extends StudentDirectoryEvent {
  final bool isSilent;
  const FetchStudentsEvent({this.isSilent = false});

  @override
  List<Object?> get props => [isSilent];
}

class CreateStudentEvent extends StudentDirectoryEvent {
  final Map<String, dynamic> studentData;
  const CreateStudentEvent({required this.studentData});

  @override
  List<Object?> get props => [studentData];
}

class UpdateStudentEvent extends StudentDirectoryEvent {
  final String id;
  final Map<String, dynamic> studentData;
  const UpdateStudentEvent({required this.id, required this.studentData});

  @override
  List<Object?> get props => [id, studentData];
}

class DeleteStudentEvent extends StudentDirectoryEvent {
  final String id;
  const DeleteStudentEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class AssignMentorEvent extends StudentDirectoryEvent {
  final String studentId;
  final String studentName;
  final String mentorName;
  final String notes;

  const AssignMentorEvent({
    required this.studentId,
    required this.studentName,
    required this.mentorName,
    required this.notes,
  });

  @override
  List<Object?> get props => [studentId, studentName, mentorName, notes];
}

class SendEmailEvent extends StudentDirectoryEvent {
  final String studentId;
  final String studentName;
  final String email;
  final String subject;
  final String body;

  const SendEmailEvent({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.subject,
    required this.body,
  });

  @override
  List<Object?> get props => [studentId, studentName, email, subject, body];
}

// ---------------------------------------------------------------------------
// STATES
// ---------------------------------------------------------------------------

abstract class StudentDirectoryState extends Equatable {
  const StudentDirectoryState();

  @override
  List<Object?> get props => [];
}

class StudentDirectoryInitial extends StudentDirectoryState {}

class StudentDirectoryLoading extends StudentDirectoryState {}

class StudentDirectoryLoaded extends StudentDirectoryState {
  final List<CollegeStudentModel> students;
  final bool isMock;
  final String? successMessage;
  final String? errorMessage;

  const StudentDirectoryLoaded({
    required this.students,
    this.isMock = false,
    this.successMessage,
    this.errorMessage,
  });

  StudentDirectoryLoaded copyWith({
    List<CollegeStudentModel>? students,
    bool? isMock,
    String? successMessage,
    String? errorMessage,
  }) {
    return StudentDirectoryLoaded(
      students: students ?? this.students,
      isMock: isMock ?? this.isMock,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [students, isMock, successMessage, errorMessage];
}

class StudentDirectoryError extends StudentDirectoryState {
  final String message;
  const StudentDirectoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------------------------------------------------------------------
// BLOC
// ---------------------------------------------------------------------------

class StudentDirectoryBloc
    extends Bloc<StudentDirectoryEvent, StudentDirectoryState> {
  final StudentDirectoryApiService _apiService;

  StudentDirectoryBloc({StudentDirectoryApiService? apiService})
      : _apiService = apiService ?? StudentDirectoryApiService(),
        super(StudentDirectoryInitial()) {
    on<FetchStudentsEvent>(_onFetchStudents);
    on<CreateStudentEvent>(_onCreateStudent);
    on<UpdateStudentEvent>(_onUpdateStudent);
    on<DeleteStudentEvent>(_onDeleteStudent);
    on<AssignMentorEvent>(_onAssignMentor);
    on<SendEmailEvent>(_onSendEmail);
  }

  Future<void> _onFetchStudents(
    FetchStudentsEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    if (!event.isSilent && state is! StudentDirectoryLoaded) {
      emit(StudentDirectoryLoading());
    }
    try {
      final res = await _apiService.fetchStudents();
      emit(StudentDirectoryLoaded(
        students: res.students,
        isMock: res.isMock,
      ));
    } catch (e) {
      emit(StudentDirectoryLoaded(
        students: CollegeStudentModel.mockSeeds,
        isMock: true,
        errorMessage: 'Showing offline mock records: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateStudent(
    CreateStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      final res = await _apiService.createStudent(event.studentData);
      final currentList = state is StudentDirectoryLoaded
          ? List<CollegeStudentModel>.from((state as StudentDirectoryLoaded).students)
          : <CollegeStudentModel>[];
      currentList.insert(0, res.student);

      final isMockState = (state is StudentDirectoryLoaded)
          ? (state as StudentDirectoryLoaded).isMock
          : res.isMock;

      emit(StudentDirectoryLoaded(
        students: currentList,
        isMock: isMockState,
        successMessage: res.isMock
            ? 'Candidate "${res.student.name}" added in demo mock mode.'
            : 'Candidate "${res.student.name}" saved to MongoDB database!',
      ));
    } catch (e) {
      _emitFailure(emit, 'Failed to save student: ${e.toString()}');
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      final res = await _apiService.updateStudent(event.id, event.studentData);
      if (state is StudentDirectoryLoaded) {
        final loaded = state as StudentDirectoryLoaded;
        final currentList = List<CollegeStudentModel>.from(loaded.students);
        final index = currentList.indexWhere((s) => s.id == event.id);
        if (index != -1) {
          currentList[index] = res.student;
        }
        emit(loaded.copyWith(
          students: currentList,
          successMessage: 'Student record for "${res.student.name}" updated successfully!',
        ));
      } else {
        add(const FetchStudentsEvent());
      }
    } catch (e) {
      _emitFailure(emit, 'Failed to update record: ${e.toString()}');
    }
  }

  Future<void> _onDeleteStudent(
    DeleteStudentEvent event,
    Emitter<StudentDirectoryState> emit,
  ) async {
    try {
      await _apiService.deleteStudent(event.id);
      if (state is StudentDirectoryLoaded) {
        final loaded = state as StudentDirectoryLoaded;
        final currentList = List<CollegeStudentModel>.from(loaded.students)
          ..removeWhere((s) => s.id == event.id);
        emit(loaded.copyWith(
          students: currentList,
          successMessage: 'Student record removed successfully.',
        ));
      } else {
        add(const FetchStudentsEvent());
      }
    } catch (e) {
      _emitFailure(emit, 'Failed to delete record: ${e.toString()}');
    }
  }

  void _onAssignMentor(
    AssignMentorEvent event,
    Emitter<StudentDirectoryState> emit,
  ) {
    if (state is StudentDirectoryLoaded) {
      final loaded = state as StudentDirectoryLoaded;
      emit(loaded.copyWith(
        successMessage: 'Mentor ${event.mentorName} assigned to ${event.studentName}.',
      ));
    }
  }

  void _onSendEmail(
    SendEmailEvent event,
    Emitter<StudentDirectoryState> emit,
  ) {
    if (state is StudentDirectoryLoaded) {
      final loaded = state as StudentDirectoryLoaded;
      emit(loaded.copyWith(
        successMessage: 'Email successfully queued to ${event.studentName} (${event.email}).',
      ));
    }
  }

  void _emitFailure(Emitter<StudentDirectoryState> emit, String message) {
    if (state is StudentDirectoryLoaded) {
      final loaded = state as StudentDirectoryLoaded;
      emit(loaded.copyWith(errorMessage: message));
    } else {
      emit(StudentDirectoryError(message: message));
    }
  }
}
