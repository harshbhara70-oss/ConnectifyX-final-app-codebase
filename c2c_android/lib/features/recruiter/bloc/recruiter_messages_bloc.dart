import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/recruiter_message_model.dart';
import '../data/repositories/recruiter_messages_repository.dart';

// --- Events ---
abstract class RecruiterMessagesEvent extends Equatable {
  const RecruiterMessagesEvent();
  @override
  List<Object?> get props => [];
}

class FetchMessagesEvent extends RecruiterMessagesEvent {
  const FetchMessagesEvent();
}

class SearchMessagesEvent extends RecruiterMessagesEvent {
  final String query;
  const SearchMessagesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SelectConversationEvent extends RecruiterMessagesEvent {
  final RecruiterConversationItem conversation;
  const SelectConversationEvent(this.conversation);
  @override
  List<Object?> get props => [conversation];
}

class ClearSelectedConversationEvent extends RecruiterMessagesEvent {
  const ClearSelectedConversationEvent();
}

class StartConversationEvent extends RecruiterMessagesEvent {
  final String candidateName;
  final String role;
  final String firstMessage;
  const StartConversationEvent({
    required this.candidateName,
    required this.role,
    required this.firstMessage,
  });
  @override
  List<Object?> get props => [candidateName, role, firstMessage];
}

class SendMessageEvent extends RecruiterMessagesEvent {
  final String conversationId;
  final String text;
  const SendMessageEvent({
    required this.conversationId,
    required this.text,
  });
  @override
  List<Object?> get props => [conversationId, text];
}

// --- States ---
abstract class RecruiterMessagesState extends Equatable {
  const RecruiterMessagesState();
  @override
  List<Object?> get props => [];
}

class RecruiterMessagesInitial extends RecruiterMessagesState {}

class RecruiterMessagesLoading extends RecruiterMessagesState {}

class RecruiterMessagesLoaded extends RecruiterMessagesState {
  final List<RecruiterConversationItem> conversations;
  final List<RecruiterConversationItem> filteredConversations;
  final RecruiterConversationItem? selectedConversation;
  final String searchQuery;
  final bool isMock;
  final bool isSubmitting;
  final String? successMessage;

  const RecruiterMessagesLoaded({
    required this.conversations,
    required this.filteredConversations,
    this.selectedConversation,
    this.searchQuery = '',
    this.isMock = false,
    this.isSubmitting = false,
    this.successMessage,
  });

  RecruiterMessagesLoaded copyWith({
    List<RecruiterConversationItem>? conversations,
    List<RecruiterConversationItem>? filteredConversations,
    RecruiterConversationItem? selectedConversation,
    bool clearSelected = false,
    String? searchQuery,
    bool? isMock,
    bool? isSubmitting,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return RecruiterMessagesLoaded(
      conversations: conversations ?? this.conversations,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      selectedConversation: clearSelected ? null : (selectedConversation ?? this.selectedConversation),
      searchQuery: searchQuery ?? this.searchQuery,
      isMock: isMock ?? this.isMock,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        selectedConversation,
        searchQuery,
        isMock,
        isSubmitting,
        successMessage,
      ];
}

class RecruiterMessagesError extends RecruiterMessagesState {
  final String message;
  const RecruiterMessagesError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class RecruiterMessagesBloc extends Bloc<RecruiterMessagesEvent, RecruiterMessagesState> {
  final RecruiterMessagesRepository _repository;

  RecruiterMessagesBloc({RecruiterMessagesRepository? repository})
      : _repository = repository ?? RecruiterMessagesRepository(),
        super(RecruiterMessagesInitial()) {
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SearchMessagesEvent>(_onSearchMessages);
    on<SelectConversationEvent>(_onSelectConversation);
    on<ClearSelectedConversationEvent>(_onClearSelectedConversation);
    on<StartConversationEvent>(_onStartConversation);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onFetchMessages(
    FetchMessagesEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) async {
    emit(RecruiterMessagesLoading());
    try {
      final conversations = await _repository.fetchConversations();
      final isAnyMock = conversations.any((c) => c.isMock);

      emit(RecruiterMessagesLoaded(
        conversations: conversations,
        filteredConversations: conversations,
        selectedConversation: null,
        isMock: isAnyMock,
      ));
    } catch (e) {
      emit(RecruiterMessagesError(e.toString()));
    }
  }

  void _onSearchMessages(
    SearchMessagesEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) {
    if (state is! RecruiterMessagesLoaded) return;
    final current = state as RecruiterMessagesLoaded;
    final q = event.query.trim().toLowerCase();

    if (q.isEmpty) {
      emit(current.copyWith(
        searchQuery: '',
        filteredConversations: current.conversations,
      ));
      return;
    }

    final filtered = current.conversations.where((conv) {
      return conv.candidateName.toLowerCase().contains(q) ||
          conv.role.toLowerCase().contains(q) ||
          conv.lastMessage.toLowerCase().contains(q);
    }).toList();

    emit(current.copyWith(
      searchQuery: event.query,
      filteredConversations: filtered,
    ));
  }

  void _onSelectConversation(
    SelectConversationEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) {
    if (state is! RecruiterMessagesLoaded) return;
    final current = state as RecruiterMessagesLoaded;
    emit(current.copyWith(selectedConversation: event.conversation));
  }

  void _onClearSelectedConversation(
    ClearSelectedConversationEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) {
    if (state is! RecruiterMessagesLoaded) return;
    final current = state as RecruiterMessagesLoaded;
    emit(current.copyWith(clearSelected: true));
  }

  Future<void> _onStartConversation(
    StartConversationEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) async {
    if (state is! RecruiterMessagesLoaded) return;
    final current = state as RecruiterMessagesLoaded;

    emit(current.copyWith(isSubmitting: true));
    try {
      final newConv = await _repository.startConversation(
        candidateName: event.candidateName,
        role: event.role,
        firstMessage: event.firstMessage,
      );

      final updated = List<RecruiterConversationItem>.from(current.conversations)..insert(0, newConv);
      final q = current.searchQuery.toLowerCase();
      final filtered = q.isEmpty
          ? updated
          : updated.where((c) =>
              c.candidateName.toLowerCase().contains(q) ||
              c.role.toLowerCase().contains(q) ||
              c.lastMessage.toLowerCase().contains(q)).toList();

      emit(current.copyWith(
        conversations: updated,
        filteredConversations: filtered,
        selectedConversation: newConv,
        isSubmitting: false,
        isMock: newConv.isMock,
        successMessage: '💬 Message sent to ${event.candidateName} for "${event.role}".',
      ));
    } catch (e) {
      emit(current.copyWith(isSubmitting: false));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<RecruiterMessagesState> emit,
  ) async {
    if (state is! RecruiterMessagesLoaded) return;
    final current = state as RecruiterMessagesLoaded;

    final newMsg = await _repository.sendReply(
      conversationId: event.conversationId,
      text: event.text,
    );

    final updated = current.conversations.map((c) {
      if (c.id == event.conversationId) {
        final msgs = List<ChatMessageItem>.from(c.messages)..add(newMsg);
        return c.copyWith(
          lastMessage: event.text,
          time: newMsg.time,
          messages: msgs,
        );
      }
      return c;
    }).toList();

    RecruiterConversationItem? updatedSelected = current.selectedConversation;
    if (updatedSelected != null && updatedSelected.id == event.conversationId) {
      final msgs = List<ChatMessageItem>.from(updatedSelected.messages)..add(newMsg);
      updatedSelected = updatedSelected.copyWith(
        lastMessage: event.text,
        time: newMsg.time,
        messages: msgs,
      );
    }

    final q = current.searchQuery.toLowerCase();
    final filtered = q.isEmpty
        ? updated
        : updated.where((c) =>
            c.candidateName.toLowerCase().contains(q) ||
            c.role.toLowerCase().contains(q) ||
            c.lastMessage.toLowerCase().contains(q)).toList();

    emit(current.copyWith(
      conversations: updated,
      filteredConversations: filtered,
      selectedConversation: updatedSelected,
    ));
  }
}
