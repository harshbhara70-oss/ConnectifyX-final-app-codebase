import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/broadcast_center_api_service.dart';
import '../domain/models/broadcast_center_model.dart';

// ============================================================================
// EVENTS
// ============================================================================
abstract class CollegeBroadcastEvent extends Equatable {
  const CollegeBroadcastEvent();

  @override
  List<Object?> get props => [];
}

class FetchBroadcastCenterEvent extends CollegeBroadcastEvent {
  final String? tab;
  final String? searchQuery;

  const FetchBroadcastCenterEvent({this.tab, this.searchQuery});

  @override
  List<Object?> get props => [tab, searchQuery];
}

class SearchBroadcastEvent extends CollegeBroadcastEvent {
  final String query;

  const SearchBroadcastEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ChangeBroadcastTabEvent extends CollegeBroadcastEvent {
  final String tab; // 'all', 'drafts', 'batches'

  const ChangeBroadcastTabEvent(this.tab);

  @override
  List<Object?> get props => [tab];
}

class SendBroadcastEvent extends CollegeBroadcastEvent {
  final String title;
  final String body;
  final String targetAudience;
  final bool isUrgent;
  final int recipientCount;

  const SendBroadcastEvent({
    required this.title,
    required this.body,
    required this.targetAudience,
    required this.isUrgent,
    required this.recipientCount,
  });

  @override
  List<Object?> get props => [title, body, targetAudience, isUrgent, recipientCount];
}

class SaveDraftEvent extends CollegeBroadcastEvent {
  final String title;
  final String body;
  final String targetAudience;
  final bool isUrgent;
  final int recipientCount;

  const SaveDraftEvent({
    required this.title,
    required this.body,
    required this.targetAudience,
    required this.isUrgent,
    required this.recipientCount,
  });

  @override
  List<Object?> get props => [title, body, targetAudience, isUrgent, recipientCount];
}

class PublishDraftEvent extends CollegeBroadcastEvent {
  final BroadcastLogItem draft;

  const PublishDraftEvent(this.draft);

  @override
  List<Object?> get props => [draft];
}

class DeleteDraftEvent extends CollegeBroadcastEvent {
  final String draftId;

  const DeleteDraftEvent(this.draftId);

  @override
  List<Object?> get props => [draftId];
}

class SelectBroadcastDetailEvent extends CollegeBroadcastEvent {
  final BroadcastLogItem? item;

  const SelectBroadcastDetailEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class ClearBroadcastToastEvent extends CollegeBroadcastEvent {}

// ============================================================================
// STATES
// ============================================================================
abstract class CollegeBroadcastState extends Equatable {
  const CollegeBroadcastState();

  @override
  List<Object?> get props => [];
}

class CollegeBroadcastInitial extends CollegeBroadcastState {}

class CollegeBroadcastLoading extends CollegeBroadcastState {}

class CollegeBroadcastLoaded extends CollegeBroadcastState {
  final BroadcastCenterData data;
  final String activeTab; // 'all', 'drafts', 'batches'
  final String searchQuery;
  final bool isSubmitting;
  final String? toastMessage;
  final bool isToastError;
  final BroadcastLogItem? viewingBroadcast;

  const CollegeBroadcastLoaded({
    required this.data,
    this.activeTab = 'all',
    this.searchQuery = '',
    this.isSubmitting = false,
    this.toastMessage,
    this.isToastError = false,
    this.viewingBroadcast,
  });

  List<BroadcastLogItem> get filteredBroadcasts {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) return data.broadcasts;
    if (q == 'urgent' || q.contains('urgent')) {
      return data.broadcasts.where((b) => b.isUrgent || b.title.toLowerCase().contains(q) || b.snippet.toLowerCase().contains(q)).toList();
    }
    return data.broadcasts.where((b) {
      return b.title.toLowerCase().contains(q) ||
          b.targetAudience.toLowerCase().contains(q) ||
          b.snippet.toLowerCase().contains(q) ||
          b.dateSent.toLowerCase().contains(q);
    }).toList();
  }

  List<BroadcastLogItem> get filteredDrafts {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) return data.drafts;
    if (q == 'urgent' || q.contains('urgent')) {
      return data.drafts.where((d) => d.isUrgent || d.title.toLowerCase().contains(q) || d.snippet.toLowerCase().contains(q)).toList();
    }
    return data.drafts.where((d) {
      return d.title.toLowerCase().contains(q) ||
          d.targetAudience.toLowerCase().contains(q) ||
          d.snippet.toLowerCase().contains(q) ||
          d.dateSent.toLowerCase().contains(q);
    }).toList();
  }

  List<BatchGroupItem> get filteredBatchGroups {
    final q = searchQuery.toLowerCase().trim();
    if (q.isEmpty) return data.batchGroups;
    return data.batchGroups.where((g) {
      return g.name.toLowerCase().contains(q) ||
          g.description.toLowerCase().contains(q) ||
          g.coordinator.toLowerCase().contains(q);
    }).toList();
  }

  CollegeBroadcastLoaded copyWith({
    BroadcastCenterData? data,
    String? activeTab,
    String? searchQuery,
    bool? isSubmitting,
    String? toastMessage,
    bool? isToastError,
    BroadcastLogItem? viewingBroadcast,
    bool clearViewingBroadcast = false,
    bool clearToast = false,
  }) {
    return CollegeBroadcastLoaded(
      data: data ?? this.data,
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isToastError: clearToast ? false : (isToastError ?? this.isToastError),
      viewingBroadcast: clearViewingBroadcast
          ? null
          : (viewingBroadcast ?? this.viewingBroadcast),
    );
  }

  @override
  List<Object?> get props => [
        data,
        activeTab,
        searchQuery,
        isSubmitting,
        toastMessage,
        isToastError,
        viewingBroadcast,
      ];
}

class CollegeBroadcastError extends CollegeBroadcastState {
  final String message;

  const CollegeBroadcastError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// BLOC
// ============================================================================
class CollegeBroadcastBloc
    extends Bloc<CollegeBroadcastEvent, CollegeBroadcastState> {
  final BroadcastCenterApiService _apiService;

  CollegeBroadcastBloc({BroadcastCenterApiService? apiService})
      : _apiService = apiService ?? BroadcastCenterApiService(),
        super(CollegeBroadcastInitial()) {
    on<FetchBroadcastCenterEvent>(_onFetchBroadcastCenter);
    on<SearchBroadcastEvent>(_onSearchBroadcast);
    on<ChangeBroadcastTabEvent>(_onChangeBroadcastTab);
    on<SendBroadcastEvent>(_onSendBroadcast);
    on<SaveDraftEvent>(_onSaveDraft);
    on<PublishDraftEvent>(_onPublishDraft);
    on<DeleteDraftEvent>(_onDeleteDraft);
    on<SelectBroadcastDetailEvent>(_onSelectBroadcastDetail);
    on<ClearBroadcastToastEvent>(_onClearBroadcastToast);
  }

  Future<void> _onFetchBroadcastCenter(
    FetchBroadcastCenterEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) async {
    emit(CollegeBroadcastLoading());
    try {
      final data = await _apiService.fetchBroadcastCenter(
        tab: event.tab,
        searchQuery: event.searchQuery,
      );
      emit(CollegeBroadcastLoaded(
        data: data,
        activeTab: event.tab ?? 'all',
        searchQuery: event.searchQuery ?? '',
      ));
    } catch (e) {
      // Graceful fallback to mock seed with isMock = true
      emit(CollegeBroadcastLoaded(data: BroadcastCenterData.mockSeed()));
    }
  }

  void _onSearchBroadcast(
    SearchBroadcastEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(searchQuery: event.query));
    }
  }

  void _onChangeBroadcastTab(
    ChangeBroadcastTabEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(activeTab: event.tab));
    }
  }

  Future<void> _onSendBroadcast(
    SendBroadcastEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) async {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(isSubmitting: true));

      final newItem = await _apiService.sendBroadcast(
        title: event.title,
        body: event.body,
        targetAudience: event.targetAudience,
        isUrgent: event.isUrgent,
        recipientCount: event.recipientCount,
      );

      final updatedBroadcasts = [newItem, ...loaded.data.broadcasts];
      final updatedData = loaded.data.copyWith(
        totalSent: loaded.data.totalSent + 1,
        broadcasts: updatedBroadcasts,
      );

      emit(loaded.copyWith(
        data: updatedData,
        isSubmitting: false,
        toastMessage: 'Broadcast "" dispatched to  recipients!',
        isToastError: false,
      ));
    }
  }

  void _onSaveDraft(
    SaveDraftEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      final newDraft = BroadcastLogItem(
        id: 'draft-',
        type: BroadcastType.document,
        title: event.title.startsWith('Draft:') ? event.title : 'Draft: ',
        snippet: event.body.isEmpty
            ? 'No message body written...'
            : (event.body.length > 80 ? '...' : event.body),
        fullBody: event.body,
        isUrgent: event.isUrgent,
        targetAudience: event.targetAudience,
        dateSent: 'Draft (Saved just now)',
        readCount: 0,
        totalCount: event.recipientCount,
        status: BroadcastStatus.draft,
        isMock: loaded.data.isMock,
      );

      final updatedDrafts = [newDraft, ...loaded.data.drafts];
      final updatedData = loaded.data.copyWith(drafts: updatedDrafts);

      emit(loaded.copyWith(
        data: updatedData,
        toastMessage: 'Broadcast message saved to Drafts.',
        isToastError: false,
      ));
    }
  }

  Future<void> _onPublishDraft(
    PublishDraftEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) async {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(isSubmitting: true));

      await _apiService.publishDraft(event.draft.id);

      final published = event.draft.copyWith(
        title: event.draft.title.replaceFirst(RegExp(r'^Draft:\s*', caseSensitive: false), ''),
        dateSent: 'Just now',
        readCount: 1,
        status: BroadcastStatus.sent,
      );

      final updatedDrafts = loaded.data.drafts.where((d) => d.id != event.draft.id).toList();
      final updatedBroadcasts = [published, ...loaded.data.broadcasts];
      final updatedData = loaded.data.copyWith(
        totalSent: loaded.data.totalSent + 1,
        broadcasts: updatedBroadcasts,
        drafts: updatedDrafts,
      );

      emit(loaded.copyWith(
        data: updatedData,
        isSubmitting: false,
        toastMessage: 'Draft "" published and sent successfully!',
        isToastError: false,
      ));
    }
  }

  Future<void> _onDeleteDraft(
    DeleteDraftEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) async {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      await _apiService.deleteDraft(event.draftId);

      final updatedDrafts = loaded.data.drafts.where((d) => d.id != event.draftId).toList();
      final updatedData = loaded.data.copyWith(drafts: updatedDrafts);

      emit(loaded.copyWith(
        data: updatedData,
        toastMessage: 'Draft deleted.',
        isToastError: false,
      ));
    }
  }

  void _onSelectBroadcastDetail(
    SelectBroadcastDetailEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(
        viewingBroadcast: event.item,
        clearViewingBroadcast: event.item == null,
      ));
    }
  }

  void _onClearBroadcastToast(
    ClearBroadcastToastEvent event,
    Emitter<CollegeBroadcastState> emit,
  ) {
    if (state is CollegeBroadcastLoaded) {
      final loaded = state as CollegeBroadcastLoaded;
      emit(loaded.copyWith(clearToast: true));
    }
  }
}
