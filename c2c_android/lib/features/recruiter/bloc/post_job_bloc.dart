import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/post_job_model.dart';
import '../data/repositories/recruiter_repository.dart';

// --- Events ---
abstract class PostJobEvent extends Equatable {
  const PostJobEvent();
  @override
  List<Object?> get props => [];
}

class JobTitleChanged extends PostJobEvent {
  final String title;
  const JobTitleChanged(this.title);
  @override
  List<Object?> get props => [title];
}

class JobDescriptionChanged extends PostJobEvent {
  final String description;
  const JobDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class JobTypeChanged extends PostJobEvent {
  final String jobType;
  const JobTypeChanged(this.jobType);
  @override
  List<Object?> get props => [jobType];
}

class RemoteToggled extends PostJobEvent {
  const RemoteToggled();
}

class LocationChanged extends PostJobEvent {
  final String location;
  const LocationChanged(this.location);
  @override
  List<Object?> get props => [location];
}

class SalaryMinChanged extends PostJobEvent {
  final String salaryMin;
  const SalaryMinChanged(this.salaryMin);
  @override
  List<Object?> get props => [salaryMin];
}

class SalaryMaxChanged extends PostJobEvent {
  final String salaryMax;
  const SalaryMaxChanged(this.salaryMax);
  @override
  List<Object?> get props => [salaryMax];
}

class SalaryCurrencyChanged extends PostJobEvent {
  final String currency;
  const SalaryCurrencyChanged(this.currency);
  @override
  List<Object?> get props => [currency];
}

class SkillAdded extends PostJobEvent {
  final String skill;
  const SkillAdded(this.skill);
  @override
  List<Object?> get props => [skill];
}

class SkillRemoved extends PostJobEvent {
  final int index;
  const SkillRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class EligibilityRuleAdded extends PostJobEvent {
  const EligibilityRuleAdded();
}

class EligibilityRuleRemoved extends PostJobEvent {
  final String id;
  const EligibilityRuleRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

class EligibilityRuleUpdated extends PostJobEvent {
  final String id;
  final String? institutionTier;
  final String? department;
  final String? requirement;

  const EligibilityRuleUpdated({
    required this.id,
    this.institutionTier,
    this.department,
    this.requirement,
  });

  @override
  List<Object?> get props => [id, institutionTier, department, requirement];
}

class SubmitJobPosting extends PostJobEvent {
  final bool asDraft;
  const SubmitJobPosting({this.asDraft = false});
  @override
  List<Object?> get props => [asDraft];
}

// --- State ---
class PostJobState extends Equatable {
  final String jobTitle;
  final String jobTitleError;
  final String jobDescription;
  final String jobType;
  final bool isRemote;
  final String location;
  final String salaryMin;
  final String salaryMax;
  final String salaryCurrency;
  final List<String> skills;
  final List<EligibilityRuleItem> eligibilityRules;
  final Map<String, String> errors;
  final bool isSubmitting;
  final bool isSuccess;
  final bool asDraft;
  final bool isMock;
  final String? errorMessage;

  const PostJobState({
    this.jobTitle = '',
    this.jobTitleError = '',
    this.jobDescription = '',
    this.jobType = 'Full-time Permanent',
    this.isRemote = false,
    this.location = '',
    this.salaryMin = '',
    this.salaryMax = '',
    this.salaryCurrency = 'LPA',
    this.skills = const [],
    this.eligibilityRules = const [],
    this.errors = const {},
    this.isSubmitting = false,
    this.isSuccess = false,
    this.asDraft = false,
    this.isMock = false,
    this.errorMessage,
  });

  PostJobState copyWith({
    String? jobTitle,
    String? jobTitleError,
    String? jobDescription,
    String? jobType,
    bool? isRemote,
    String? location,
    String? salaryMin,
    String? salaryMax,
    String? salaryCurrency,
    List<String>? skills,
    List<EligibilityRuleItem>? eligibilityRules,
    Map<String, String>? errors,
    bool? isSubmitting,
    bool? isSuccess,
    bool? asDraft,
    bool? isMock,
    String? errorMessage,
  }) {
    return PostJobState(
      jobTitle: jobTitle ?? this.jobTitle,
      jobTitleError: jobTitleError ?? this.jobTitleError,
      jobDescription: jobDescription ?? this.jobDescription,
      jobType: jobType ?? this.jobType,
      isRemote: isRemote ?? this.isRemote,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      skills: skills ?? this.skills,
      eligibilityRules: eligibilityRules ?? this.eligibilityRules,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      asDraft: asDraft ?? this.asDraft,
      isMock: isMock ?? this.isMock,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        jobTitle,
        jobTitleError,
        jobDescription,
        jobType,
        isRemote,
        location,
        salaryMin,
        salaryMax,
        salaryCurrency,
        skills,
        eligibilityRules,
        errors,
        isSubmitting,
        isSuccess,
        asDraft,
        isMock,
        errorMessage,
      ];
}

// --- BLoC Implementation ---
class PostJobBloc extends Bloc<PostJobEvent, PostJobState> {
  final RecruiterRepository _repository;

  PostJobBloc({RecruiterRepository? repository})
      : _repository = repository ?? RecruiterRepository(),
        super(const PostJobState()) {
    on<JobTitleChanged>(_onJobTitleChanged);
    on<JobDescriptionChanged>(_onJobDescriptionChanged);
    on<JobTypeChanged>(_onJobTypeChanged);
    on<RemoteToggled>(_onRemoteToggled);
    on<LocationChanged>(_onLocationChanged);
    on<SalaryMinChanged>(_onSalaryMinChanged);
    on<SalaryMaxChanged>(_onSalaryMaxChanged);
    on<SalaryCurrencyChanged>(_onSalaryCurrencyChanged);
    on<SkillAdded>(_onSkillAdded);
    on<SkillRemoved>(_onSkillRemoved);
    on<EligibilityRuleAdded>(_onEligibilityRuleAdded);
    on<EligibilityRuleRemoved>(_onEligibilityRuleRemoved);
    on<EligibilityRuleUpdated>(_onEligibilityRuleUpdated);
    on<SubmitJobPosting>(_onSubmitJobPosting);
  }

  void _onJobTitleChanged(JobTitleChanged event, Emitter<PostJobState> emit) {
    final raw = event.title;
    final hasNumbers = RegExp(r'[0-9]').hasMatch(raw);
    final cleaned = raw.replaceAll(RegExp(r'[0-9]'), '');
    final newErrors = Map<String, String>.from(state.errors)..remove('jobTitle');

    emit(state.copyWith(
      jobTitle: cleaned,
      jobTitleError: hasNumbers ? 'Numbers are not allowed in Job Title' : '',
      errors: newErrors,
    ));
  }

  void _onJobDescriptionChanged(JobDescriptionChanged event, Emitter<PostJobState> emit) {
    final newErrors = Map<String, String>.from(state.errors)..remove('jobDescription');
    emit(state.copyWith(jobDescription: event.description, errors: newErrors));
  }

  void _onJobTypeChanged(JobTypeChanged event, Emitter<PostJobState> emit) {
    emit(state.copyWith(jobType: event.jobType));
  }

  void _onRemoteToggled(RemoteToggled event, Emitter<PostJobState> emit) {
    final newRemote = !state.isRemote;
    final newErrors = Map<String, String>.from(state.errors);
    if (newRemote) newErrors.remove('location');
    emit(state.copyWith(
      isRemote: newRemote,
      location: newRemote ? 'Remote' : (state.location == 'Remote' ? '' : state.location),
      errors: newErrors,
    ));
  }

  void _onLocationChanged(LocationChanged event, Emitter<PostJobState> emit) {
    final cleaned = event.location.replaceAll(RegExp(r'[0-9]'), '');
    final newErrors = Map<String, String>.from(state.errors)..remove('location');
    emit(state.copyWith(location: cleaned, errors: newErrors));
  }

  void _onSalaryMinChanged(SalaryMinChanged event, Emitter<PostJobState> emit) {
    final newErrors = Map<String, String>.from(state.errors)..remove('salaryMin');
    emit(state.copyWith(salaryMin: event.salaryMin, errors: newErrors));
  }

  void _onSalaryMaxChanged(SalaryMaxChanged event, Emitter<PostJobState> emit) {
    final newErrors = Map<String, String>.from(state.errors)..remove('salaryMax');
    emit(state.copyWith(salaryMax: event.salaryMax, errors: newErrors));
  }

  void _onSalaryCurrencyChanged(SalaryCurrencyChanged event, Emitter<PostJobState> emit) {
    emit(state.copyWith(salaryCurrency: event.currency));
  }

  void _onSkillAdded(SkillAdded event, Emitter<PostJobState> emit) {
    final trimmed = event.skill.trim();
    if (trimmed.isNotEmpty && !state.skills.contains(trimmed)) {
      final updated = List<String>.from(state.skills)..add(trimmed);
      final newErrors = Map<String, String>.from(state.errors)..remove('skills');
      emit(state.copyWith(skills: updated, errors: newErrors));
    }
  }

  void _onSkillRemoved(SkillRemoved event, Emitter<PostJobState> emit) {
    if (event.index >= 0 && event.index < state.skills.length) {
      final updated = List<String>.from(state.skills)..removeAt(event.index);
      emit(state.copyWith(skills: updated));
    }
  }

  void _onEligibilityRuleAdded(EligibilityRuleAdded event, Emitter<PostJobState> emit) {
    final newRule = EligibilityRuleItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      institutionTier: '',
      department: '',
      requirement: '',
    );
    final updated = List<EligibilityRuleItem>.from(state.eligibilityRules)..add(newRule);
    emit(state.copyWith(eligibilityRules: updated));
  }

  void _onEligibilityRuleRemoved(EligibilityRuleRemoved event, Emitter<PostJobState> emit) {
    final updated = state.eligibilityRules.where((r) => r.id != event.id).toList();
    emit(state.copyWith(eligibilityRules: updated));
  }

  void _onEligibilityRuleUpdated(EligibilityRuleUpdated event, Emitter<PostJobState> emit) {
    final updated = state.eligibilityRules.map((r) {
      if (r.id == event.id) {
        return r.copyWith(
          institutionTier: event.institutionTier ?? r.institutionTier,
          department: event.department ?? r.department,
          requirement: event.requirement ?? r.requirement,
        );
      }
      return r;
    }).toList();
    emit(state.copyWith(eligibilityRules: updated));
  }

  Future<void> _onSubmitJobPosting(SubmitJobPosting event, Emitter<PostJobState> emit) async {
    if (!event.asDraft) {
      final newErrors = <String, String>{};
      if (state.jobTitle.trim().isEmpty) newErrors['jobTitle'] = 'Job Title is required';
      if (state.jobDescription.trim().isEmpty) newErrors['jobDescription'] = 'Job Description is required';
      if (!state.isRemote && state.location.trim().isEmpty) newErrors['location'] = 'Office Location is required';
      if (state.salaryMin.trim().isEmpty) newErrors['salaryMin'] = 'Minimum salary is required';
      if (state.salaryMax.trim().isEmpty) newErrors['salaryMax'] = 'Maximum salary is required';
      if (state.skills.isEmpty) newErrors['skills'] = 'At least one required skill must be added';

      if (newErrors.isNotEmpty) {
        emit(state.copyWith(errors: newErrors));
        return;
      }
    }

    emit(state.copyWith(isSubmitting: true, errors: const {}));

    try {
      final request = PostJobRequest(
        title: state.jobTitle.trim().isEmpty ? 'Untitled Position' : state.jobTitle.trim(),
        description: state.jobDescription.trim(),
        jobType: state.jobType,
        isRemote: state.isRemote,
        location: state.isRemote ? 'Remote' : state.location.trim(),
        salaryMin: state.salaryMin.trim(),
        salaryMax: state.salaryMax.trim(),
        salaryCurrency: state.salaryCurrency,
        skills: state.skills,
        eligibilityRules: state.eligibilityRules,
        status: event.asDraft ? 'DRAFT' : 'ACTIVE',
      );

      final success = await _repository.publishJob(request);

      if (success) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true, asDraft: event.asDraft));
      } else {
        emit(state.copyWith(isSubmitting: false, errorMessage: 'Failed to submit job vacancy.'));
      }
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
