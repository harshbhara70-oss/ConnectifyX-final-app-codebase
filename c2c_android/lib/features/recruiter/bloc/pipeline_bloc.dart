import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/candidate_pipeline_model.dart';
import '../data/repositories/pipeline_repository.dart';

// ===================== EVENTS =====================
abstract class PipelineEvent extends Equatable {
  const PipelineEvent();
  @override
  List<Object?> get props => [];
}

class FetchPipeline extends PipelineEvent {
  const FetchPipeline();
}

class RefreshPipeline extends PipelineEvent {
  const RefreshPipeline();
}

class SelectPipelineStageTab extends PipelineEvent {
  final String stageId; // ALL | shortlisted | contacted | interview | offer
  const SelectPipelineStageTab(this.stageId);
  @override
  List<Object?> get props => [stageId];
}

class AdvanceCandidateAction extends PipelineEvent {
  final String candidateId;
  final String currentStage;
  const AdvanceCandidateAction({required this.candidateId, required this.currentStage});
  @override
  List<Object?> get props => [candidateId, currentStage];
}

class RollbackCandidateAction extends PipelineEvent {
  final String candidateId;
  final String currentStage;
  const RollbackCandidateAction({required this.candidateId, required this.currentStage});
  @override
  List<Object?> get props => [candidateId, currentStage];
}

class AddCandidateAction extends PipelineEvent {
  final String name;
  final String role;
  final String stage;
  final String source;
  final String score;
  const AddCandidateAction({
    required this.name,
    required this.role,
    required this.stage,
    required this.source,
    required this.score,
  });
  @override
  List<Object?> get props => [name, role, stage, source, score];
}

class RemoveCandidateAction extends PipelineEvent {
  final String candidateId;
  const RemoveCandidateAction(this.candidateId);
  @override
  List<Object?> get props => [candidateId];
}

// ===================== STATES =====================
abstract class PipelineState extends Equatable {
  const PipelineState();
  @override
  List<Object?> get props => [];
}

class PipelineInitial extends PipelineState {
  const PipelineInitial();
}

class PipelineLoading extends PipelineState {
  const PipelineLoading();
}

class PipelineLoaded extends PipelineState {
  final List<CandidatePipelineItem> candidates;
  final String selectedStageTab; // ALL | shortlisted | contacted | interview | offer
  final bool isUpdating;
  final bool isAdding;
  final bool isMock;

  const PipelineLoaded({
    required this.candidates,
    this.selectedStageTab = 'ALL',
    this.isUpdating = false,
    this.isAdding = false,
    this.isMock = false,
  });

  List<CandidatePipelineItem> getCandidatesByStage(String stage) {
    return candidates.where((c) => c.stage.toLowerCase() == stage.toLowerCase()).toList();
  }

  List<CandidatePipelineItem> get currentFilteredList {
    if (selectedStageTab == 'ALL') return candidates;
    return getCandidatesByStage(selectedStageTab);
  }

  int get shortlistedCount => candidates.where((c) => c.stage == 'shortlisted').length;
  int get contactedCount => candidates.where((c) => c.stage == 'contacted').length;
  int get interviewCount => candidates.where((c) => c.stage == 'interview').length;
  int get offerCount => candidates.where((c) => c.stage == 'offer').length;

  PipelineLoaded copyWith({
    List<CandidatePipelineItem>? candidates,
    String? selectedStageTab,
    bool? isUpdating,
    bool? isAdding,
    bool? isMock,
  }) {
    return PipelineLoaded(
      candidates: candidates ?? this.candidates,
      selectedStageTab: selectedStageTab ?? this.selectedStageTab,
      isUpdating: isUpdating ?? this.isUpdating,
      isAdding: isAdding ?? this.isAdding,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [candidates, selectedStageTab, isUpdating, isAdding, isMock];
}

class PipelineEmpty extends PipelineState {
  final String selectedStageTab;
  final bool isMock;
  const PipelineEmpty({this.selectedStageTab = 'ALL', this.isMock = false});
  @override
  List<Object?> get props => [selectedStageTab, isMock];
}

class PipelineError extends PipelineState {
  final String message;
  const PipelineError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===================== BLOC =====================
class PipelineBloc extends Bloc<PipelineEvent, PipelineState> {
  final PipelineRepository _repository;

  PipelineBloc({PipelineRepository? repository})
      : _repository = repository ?? PipelineRepository(),
        super(const PipelineInitial()) {
    on<FetchPipeline>(_onFetch);
    on<RefreshPipeline>(_onRefresh);
    on<SelectPipelineStageTab>(_onStageSelect);
    on<AdvanceCandidateAction>(_onAdvance);
    on<RollbackCandidateAction>(_onRollback);
    on<AddCandidateAction>(_onAddCandidate);
    on<RemoveCandidateAction>(_onRemoveCandidate);
  }

  Future<void> _onFetch(FetchPipeline event, Emitter<PipelineState> emit) async {
    emit(const PipelineLoading());
    try {
      final list = await _repository.fetchPipelineCandidates();
      final isAnyMock = list.any((c) => c.isMock);
      if (list.isEmpty) {
        emit(PipelineEmpty(isMock: isAnyMock));
      } else {
        emit(PipelineLoaded(candidates: list, isMock: isAnyMock));
      }
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshPipeline event, Emitter<PipelineState> emit) async {
    try {
      final list = await _repository.fetchPipelineCandidates();
      final isAnyMock = list.any((c) => c.isMock);
      if (list.isEmpty) {
        emit(PipelineEmpty(isMock: isAnyMock));
      } else {
        final cur = state;
        if (cur is PipelineLoaded) {
          emit(cur.copyWith(candidates: list, isMock: isAnyMock));
        } else {
          emit(PipelineLoaded(candidates: list, isMock: isAnyMock));
        }
      }
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onStageSelect(SelectPipelineStageTab event, Emitter<PipelineState> emit) {
    if (state is PipelineLoaded) {
      final cur = state as PipelineLoaded;
      emit(cur.copyWith(selectedStageTab: event.stageId));
    } else if (state is PipelineEmpty) {
      final cur = state as PipelineEmpty;
      emit(PipelineEmpty(selectedStageTab: event.stageId, isMock: cur.isMock));
    }
  }

  Future<void> _onAdvance(AdvanceCandidateAction event, Emitter<PipelineState> emit) async {
    if (state is! PipelineLoaded) return;
    final cur = state as PipelineLoaded;
    emit(cur.copyWith(isUpdating: true));
    try {
      await _repository.advanceCandidate(event.candidateId, event.currentStage);

      String nextStage = event.currentStage;
      if (event.currentStage == 'shortlisted') {
        nextStage = 'contacted';
      } else if (event.currentStage == 'contacted') {
        nextStage = 'interview';
      } else if (event.currentStage == 'interview') {
        nextStage = 'offer';
      }

      final updated = cur.candidates.map((c) {
        return c.id == event.candidateId ? c.copyWith(stage: nextStage) : c;
      }).toList();

      emit(cur.copyWith(candidates: updated, isUpdating: false));
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRollback(RollbackCandidateAction event, Emitter<PipelineState> emit) async {
    if (state is! PipelineLoaded) return;
    final cur = state as PipelineLoaded;
    emit(cur.copyWith(isUpdating: true));
    try {
      await _repository.rollbackCandidate(event.candidateId, event.currentStage);

      String prevStage = event.currentStage;
      if (event.currentStage == 'offer') {
        prevStage = 'interview';
      } else if (event.currentStage == 'interview') {
        prevStage = 'contacted';
      } else if (event.currentStage == 'contacted') {
        prevStage = 'shortlisted';
      }

      final updated = cur.candidates.map((c) {
        return c.id == event.candidateId ? c.copyWith(stage: prevStage) : c;
      }).toList();

      emit(cur.copyWith(candidates: updated, isUpdating: false));
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddCandidate(AddCandidateAction event, Emitter<PipelineState> emit) async {
    if (state is! PipelineLoaded && state is! PipelineEmpty) return;
    try {
      final newCand = await _repository.addCandidate(
        name: event.name,
        role: event.role,
        stage: event.stage,
        source: event.source,
        score: event.score,
      );

      final currentList = state is PipelineLoaded ? (state as PipelineLoaded).candidates : <CandidatePipelineItem>[];
      final updated = [...currentList, newCand];

      if (state is PipelineLoaded) {
        final cur = state as PipelineLoaded;
        emit(cur.copyWith(candidates: updated));
      } else {
        emit(PipelineLoaded(candidates: updated));
      }
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRemoveCandidate(RemoveCandidateAction event, Emitter<PipelineState> emit) async {
    if (state is! PipelineLoaded) return;
    final cur = state as PipelineLoaded;
    try {
      await _repository.removeCandidate(event.candidateId);
      final updated = cur.candidates.where((c) => c.id != event.candidateId).toList();
      if (updated.isEmpty) {
        emit(PipelineEmpty(isMock: cur.isMock));
      } else {
        emit(cur.copyWith(candidates: updated));
      }
    } catch (e) {
      emit(PipelineError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
