import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/models/my_job_posting_model.dart';
import '../data/repositories/my_job_posting_repository.dart';

// ===================== EVENTS =====================
abstract class MyJobPostingEvent extends Equatable {
  const MyJobPostingEvent();
  @override
  List<Object?> get props => [];
}

class FetchMyPostings extends MyJobPostingEvent {
  final String? jobIdParam;
  const FetchMyPostings({this.jobIdParam});
  @override
  List<Object?> get props => [jobIdParam];
}

class RefreshMyPostings extends MyJobPostingEvent {
  const RefreshMyPostings();
}

class ChangePostingTab extends MyJobPostingEvent {
  final String tab; // ALL | ACTIVE | DRAFT
  const ChangePostingTab(this.tab);
  @override
  List<Object?> get props => [tab];
}

class SetSelectedJobFilter extends MyJobPostingEvent {
  final String? jobId; // null = show all
  const SetSelectedJobFilter(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class DeletePostingRequested extends MyJobPostingEvent {
  final String id;
  const DeletePostingRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class PublishDraftRequested extends MyJobPostingEvent {
  final String id;
  const PublishDraftRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ClearSelectedJobFilter extends MyJobPostingEvent {
  const ClearSelectedJobFilter();
}

// ===================== STATES =====================
abstract class MyJobPostingState extends Equatable {
  const MyJobPostingState();
  @override
  List<Object?> get props => [];
}

class MyJobPostingInitial extends MyJobPostingState {
  const MyJobPostingInitial();
}

class MyJobPostingLoading extends MyJobPostingState {
  const MyJobPostingLoading();
}

class MyJobPostingLoaded extends MyJobPostingState {
  final List<JobPostingItem> postings;
  final String activeTab; // ALL | ACTIVE | DRAFT
  final String? selectedJobId;
  final bool isPublishing;
  final bool isDeleting;
  final bool isMock;

  const MyJobPostingLoaded({
    required this.postings,
    this.activeTab = 'ALL',
    this.selectedJobId,
    this.isPublishing = false,
    this.isDeleting = false,
    this.isMock = false,
  });

  /// Mirrors web: if jobId param present, filter to that single id bypassing tabs.
  List<JobPostingItem> get filteredPostings {
    if (selectedJobId != null && selectedJobId!.isNotEmpty) {
      return postings.where((p) => p.id == selectedJobId).toList();
    }
    if (activeTab == 'ACTIVE') return postings.where((p) => p.status == 'ACTIVE').toList();
    if (activeTab == 'DRAFT') return postings.where((p) => p.status == 'DRAFT').toList();
    return postings;
  }

  JobPostingItem? get selectedJobInfo {
    if (selectedJobId == null) return null;
    try {
      return postings.firstWhere((p) => p.id == selectedJobId);
    } catch (_) {
      return null;
    }
  }

  int get activeCount => postings.where((p) => p.status == 'ACTIVE').length;
  int get draftCount => postings.where((p) => p.status == 'DRAFT').length;

  MyJobPostingLoaded copyWith({
    List<JobPostingItem>? postings,
    String? activeTab,
    String? selectedJobId,
    bool clearSelected = false,
    bool? isPublishing,
    bool? isDeleting,
    bool? isMock,
  }) {
    return MyJobPostingLoaded(
      postings: postings ?? this.postings,
      activeTab: activeTab ?? this.activeTab,
      selectedJobId: clearSelected ? null : (selectedJobId ?? this.selectedJobId),
      isPublishing: isPublishing ?? this.isPublishing,
      isDeleting: isDeleting ?? this.isDeleting,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [postings, activeTab, selectedJobId, isPublishing, isDeleting, isMock];
}

class MyJobPostingEmpty extends MyJobPostingState {
  final String? selectedJobId;
  final String activeTab;
  final bool isMock;
  const MyJobPostingEmpty({this.selectedJobId, this.activeTab = 'ALL', this.isMock = false});
  @override
  List<Object?> get props => [selectedJobId, activeTab, isMock];
}

class MyJobPostingError extends MyJobPostingState {
  final String message;
  const MyJobPostingError(this.message);
  @override
  List<Object?> get props => [message];
}

// ===================== BLoC =====================
class MyJobPostingBloc extends Bloc<MyJobPostingEvent, MyJobPostingState> {
  final MyJobPostingRepository _repo;

  MyJobPostingBloc({MyJobPostingRepository? repository})
      : _repo = repository ?? MyJobPostingRepository(),
        super(const MyJobPostingInitial()) {
    on<FetchMyPostings>(_onFetch);
    on<RefreshMyPostings>(_onRefresh);
    on<ChangePostingTab>(_onTabChange);
    on<SetSelectedJobFilter>(_onSetFilter);
    on<ClearSelectedJobFilter>(_onClearFilter);
    on<DeletePostingRequested>(_onDelete);
    on<PublishDraftRequested>(_onPublish);
  }

  Future<void> _onFetch(FetchMyPostings event, Emitter<MyJobPostingState> emit) async {
    emit(const MyJobPostingLoading());
    try {
      final data = await _repo.fetchMyPostings(jobIdFilter: event.jobIdParam);
      final isAnyMock = data.any((d) => d.isMock);
      if (data.isEmpty) {
        emit(MyJobPostingEmpty(selectedJobId: event.jobIdParam, isMock: isAnyMock));
        return;
      }
      emit(MyJobPostingLoaded(postings: data, selectedJobId: event.jobIdParam, isMock: isAnyMock));
    } catch (e) {
      emit(MyJobPostingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRefresh(RefreshMyPostings event, Emitter<MyJobPostingState> emit) async {
    try {
      final data = await _repo.fetchMyPostings();
      final isAnyMock = data.any((d) => d.isMock);
      if (data.isEmpty) {
        emit(MyJobPostingEmpty(isMock: isAnyMock));
        return;
      }
      final prev = state;
      if (prev is MyJobPostingLoaded) {
        emit(prev.copyWith(postings: data, isMock: isAnyMock));
      } else {
        emit(MyJobPostingLoaded(postings: data, isMock: isAnyMock));
      }
    } catch (e) {
      emit(MyJobPostingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onTabChange(ChangePostingTab event, Emitter<MyJobPostingState> emit) {
    if (state is MyJobPostingLoaded) {
      final cur = state as MyJobPostingLoaded;
      emit(cur.copyWith(activeTab: event.tab));
    } else if (state is MyJobPostingEmpty) {
      final cur = state as MyJobPostingEmpty;
      emit(MyJobPostingEmpty(selectedJobId: cur.selectedJobId, activeTab: event.tab, isMock: cur.isMock));
    }
  }

  void _onSetFilter(SetSelectedJobFilter event, Emitter<MyJobPostingState> emit) {
    if (state is MyJobPostingLoaded) {
      final cur = state as MyJobPostingLoaded;
      emit(cur.copyWith(selectedJobId: event.jobId));
    } else if (state is MyJobPostingEmpty) {
      final cur = state as MyJobPostingEmpty;
      emit(MyJobPostingEmpty(selectedJobId: event.jobId, isMock: cur.isMock));
    }
  }

  void _onClearFilter(ClearSelectedJobFilter event, Emitter<MyJobPostingState> emit) {
    if (state is MyJobPostingLoaded) {
      final cur = state as MyJobPostingLoaded;
      emit(cur.copyWith(clearSelected: true));
    } else if (state is MyJobPostingEmpty) {
      final cur = state as MyJobPostingEmpty;
      emit(MyJobPostingEmpty(isMock: cur.isMock));
    }
  }

  Future<void> _onDelete(DeletePostingRequested event, Emitter<MyJobPostingState> emit) async {
    if (state is! MyJobPostingLoaded) return;
    final cur = state as MyJobPostingLoaded;
    emit(cur.copyWith(isDeleting: true));
    try {
      await _repo.deletePosting(event.id);
      final updated = cur.postings.where((p) => p.id != event.id).toList();
      final shouldClear = cur.selectedJobId == event.id;
      if (updated.isEmpty) {
        emit(MyJobPostingEmpty(isMock: cur.isMock));
      } else {
        emit(cur.copyWith(postings: updated, isDeleting: false, clearSelected: shouldClear));
      }
    } catch (e) {
      emit(MyJobPostingError(e.toString()));
    }
  }

  Future<void> _onPublish(PublishDraftRequested event, Emitter<MyJobPostingState> emit) async {
    if (state is! MyJobPostingLoaded) return;
    final cur = state as MyJobPostingLoaded;
    emit(cur.copyWith(isPublishing: true));
    try {
      await _repo.publishDraft(event.id);
      final updated = cur.postings.map((p) => p.id == event.id ? p.copyWith(status: 'ACTIVE') : p).toList();
      emit(cur.copyWith(postings: updated, isPublishing: false));
    } catch (e) {
      emit(MyJobPostingError(e.toString()));
    }
  }
}
