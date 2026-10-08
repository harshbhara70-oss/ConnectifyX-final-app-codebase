import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_communication_model.dart';
import '../data/models/mentor_overview_model.dart';
import '../data/repositories/mentor_repository.dart';
import 'mentor_communication_event.dart';
import 'mentor_communication_state.dart';

class MentorCommunicationBloc
    extends Bloc<MentorCommunicationEvent, MentorCommunicationState> {
  final MentorRepository _repository;

  MentorCommunicationBloc({MentorRepository? repository})
      : _repository = repository ?? MentorRepository(),
        super(const CommunicationInitial()) {
    on<FetchCommunicationDataEvent>(_onFetchData);
    on<SelectChatTargetEvent>(_onSelectTarget);
    on<SendChatMessageEvent>(_onSendMessage);
    on<FilterChannelTypeEvent>(_onFilterChannelType);
    on<SearchCommunicationEvent>(_onSearch);
    on<CreateAnnouncementEvent>(_onCreateAnnouncement);
    on<StartDirectChatEvent>(_onStartDirectChat);
  }

  Future<void> _onFetchData(
    FetchCommunicationDataEvent event,
    Emitter<MentorCommunicationState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const CommunicationLoading());
    }
    try {
      final payload = await _repository.getCommunicationData();

      final activeTarget = payload.contacts.isNotEmpty
          ? payload.contacts.first.name
          : '#stripe-frontend';

      final filteredContacts = _filterContacts(payload.contacts, '');
      final filteredChannels = _filterChannels(payload.channels, '');
      final filteredAnnouncements = _filterAnnouncements(payload.announcements, '');

      emit(CommunicationLoaded(
        data: payload,
        activeTarget: activeTarget,
        isGroupChannel: activeTarget.startsWith('#'),
        activeFilter: 'all',
        searchQuery: '',
        filteredContacts: filteredContacts,
        filteredChannels: filteredChannels,
        filteredAnnouncements: filteredAnnouncements,
      ));
    } catch (e) {
      emit(CommunicationError('Failed to load communication hub: ${e.toString()}'));
    }
  }

  void _onSelectTarget(
    SelectChatTargetEvent event,
    Emitter<MentorCommunicationState> emit,
  ) {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      emit(current.copyWith(
        activeTarget: event.targetName,
        isGroupChannel: event.isGroup,
      ));
    }
  }

  Future<void> _onSendMessage(
    SendChatMessageEvent event,
    Emitter<MentorCommunicationState> emit,
  ) async {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      final text = event.text.trim();
      if (text.isEmpty) return;

      final target = event.targetName;
      final currentHistory = Map<String, List<ChatMessageModel>>.from(current.data.chatHistory);
      final targetList = List<ChatMessageModel>.from(currentHistory[target] ?? []);

      final now = DateTime.now();
      final timeStr = '${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

      final newMsg = ChatMessageModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        sender: 'mentor',
        senderName: 'Dr. Sarah Jenkins',
        text: text,
        timestamp: timeStr,
        isMock: current.data.isMock,
      );

      targetList.add(newMsg);
      currentHistory[target] = targetList;

      final updatedPayload = current.data.copyWith(chatHistory: currentHistory);

      emit(current.copyWith(
        data: updatedPayload,
        isTyping: true,
      ));

      // Network sync in background
      _repository.sendChatMessage(
        target: target,
        text: text,
        isGroup: event.isGroup,
      );

      // Simulate student response delay for rich responsive feedback
      await Future.delayed(const Duration(milliseconds: 1400));

      if (state is CommunicationLoaded && (state as CommunicationLoaded).activeTarget == target) {
        final autoReplies = [
          'Thank you Dr. Sarah! Reviewing the suggestions right now.',
          'Noted! I will update the project files accordingly.',
          'Understood, preparing the test suites for our next sync.',
          'Got it! Thanks for the timely guidance.'
        ];
        final replyText = autoReplies[targetList.length % autoReplies.length];

        final replyMsg = ChatMessageModel(
          id: 'm_reply_${DateTime.now().millisecondsSinceEpoch}',
          sender: 'student',
          senderName: event.isGroup ? 'Rahul Sharma' : target,
          text: replyText,
          timestamp: 'Just now',
          isMock: current.data.isMock,
        );

        final withReplyHistory = Map<String, List<ChatMessageModel>>.from(
          (state as CommunicationLoaded).data.chatHistory,
        );
        final withReplyList = List<ChatMessageModel>.from(withReplyHistory[target] ?? []);
        withReplyList.add(replyMsg);
        withReplyHistory[target] = withReplyList;

        final finalPayload = (state as CommunicationLoaded).data.copyWith(
          chatHistory: withReplyHistory,
        );

        emit((state as CommunicationLoaded).copyWith(
          data: finalPayload,
          isTyping: false,
        ));
      }
    }
  }

  void _onFilterChannelType(
    FilterChannelTypeEvent event,
    Emitter<MentorCommunicationState> emit,
  ) {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      emit(current.copyWith(activeFilter: event.filter));
    }
  }

  void _onSearch(
    SearchCommunicationEvent event,
    Emitter<MentorCommunicationState> emit,
  ) {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      final q = event.query;

      final filteredContacts = _filterContacts(current.data.contacts, q);
      final filteredChannels = _filterChannels(current.data.channels, q);
      final filteredAnnouncements = _filterAnnouncements(current.data.announcements, q);

      emit(current.copyWith(
        searchQuery: q,
        filteredContacts: filteredContacts,
        filteredChannels: filteredChannels,
        filteredAnnouncements: filteredAnnouncements,
      ));
    }
  }

  Future<void> _onCreateAnnouncement(
    CreateAnnouncementEvent event,
    Emitter<MentorCommunicationState> emit,
  ) async {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      emit(current.copyWith(isSubmitting: true));

      final newAnnouncement = await _repository.createAnnouncement(
        title: event.title.trim(),
        content: event.content.trim(),
        category: event.category,
      );

      final updatedAnnouncements = [newAnnouncement, ...current.data.announcements];
      final updatedPayload = current.data.copyWith(
        announcements: updatedAnnouncements,
      );

      final filtered = _filterAnnouncements(updatedAnnouncements, current.searchQuery);

      emit(current.copyWith(
        data: updatedPayload,
        filteredAnnouncements: filtered,
        isSubmitting: false,
        toastMessage: 'Announcement broadcasted: ${newAnnouncement.title}',
      ));
    }
  }

  Future<void> _onStartDirectChat(
    StartDirectChatEvent event,
    Emitter<MentorCommunicationState> emit,
  ) async {
    if (state is CommunicationLoaded) {
      final current = state as CommunicationLoaded;
      final studentName = event.studentName.trim();
      if (studentName.isEmpty) return;

      final existingContact = current.data.contacts.any((c) => c.name.toLowerCase() == studentName.toLowerCase());

      List<ChatContactModel> updatedContacts = List.from(current.data.contacts);
      if (!existingContact) {
        final initials = studentName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase().padRight(2, 'S').substring(0, 2);
        final newContact = ChatContactModel(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          name: studentName,
          role: 'Mentee',
          college: 'Campus Candidate',
          avatar: initials,
          avatarBg: '0xFF6366F1',
          lastMessage: event.initialMessage.isNotEmpty ? event.initialMessage : 'Conversation started',
          lastMessageTime: 'Just now',
          unreadCount: 0,
          isOnline: true,
          isMock: current.data.isMock,
        );
        updatedContacts = [newContact, ...updatedContacts];
      }

      final currentHistory = Map<String, List<ChatMessageModel>>.from(current.data.chatHistory);
      if (event.initialMessage.trim().isNotEmpty) {
        final targetList = List<ChatMessageModel>.from(currentHistory[studentName] ?? []);
        targetList.add(ChatMessageModel(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          sender: 'mentor',
          senderName: 'Dr. Sarah Jenkins',
          text: event.initialMessage.trim(),
          timestamp: 'Just now',
          isMock: current.data.isMock,
        ));
        currentHistory[studentName] = targetList;
      }

      final updatedPayload = current.data.copyWith(
        contacts: updatedContacts,
        chatHistory: currentHistory,
      );

      final filtered = _filterContacts(updatedContacts, current.searchQuery);

      emit(current.copyWith(
        data: updatedPayload,
        filteredContacts: filtered,
        activeTarget: studentName,
        isGroupChannel: false,
        toastMessage: 'Direct workspace opened for $studentName',
      ));
    }
  }

  List<ChatContactModel> _filterContacts(List<ChatContactModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.role.toLowerCase().contains(q) ||
          c.college.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  List<CohortChannelModel> _filterChannels(List<CohortChannelModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.topic.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  List<MentorAnnouncementModel> _filterAnnouncements(
      List<MentorAnnouncementModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.trim().toLowerCase();
    return list.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.content.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q);
    }).toList();
  }
}
