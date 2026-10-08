import 'package:equatable/equatable.dart';
import '../data/models/mentor_communication_model.dart';
import '../data/models/mentor_overview_model.dart';

abstract class MentorCommunicationState extends Equatable {
  const MentorCommunicationState();

  @override
  List<Object?> get props => [];
}

class CommunicationInitial extends MentorCommunicationState {
  const CommunicationInitial();
}

class CommunicationLoading extends MentorCommunicationState {
  const CommunicationLoading();
}

class CommunicationLoaded extends MentorCommunicationState {
  final MentorCommunicationData data;
  final String activeTarget; // Contact name or channel name currently being viewed/chatted with
  final bool isGroupChannel;
  final String activeFilter; // 'all' | 'direct' | 'cohort' | 'announcements'
  final String searchQuery;
  final bool isTyping;
  final bool isSubmitting;
  final String? toastMessage;
  final List<ChatContactModel> filteredContacts;
  final List<CohortChannelModel> filteredChannels;
  final List<MentorAnnouncementModel> filteredAnnouncements;

  const CommunicationLoaded({
    required this.data,
    required this.activeTarget,
    required this.isGroupChannel,
    required this.activeFilter,
    required this.searchQuery,
    this.isTyping = false,
    this.isSubmitting = false,
    this.toastMessage,
    required this.filteredContacts,
    required this.filteredChannels,
    required this.filteredAnnouncements,
  });

  CommunicationLoaded copyWith({
    MentorCommunicationData? data,
    String? activeTarget,
    bool? isGroupChannel,
    String? activeFilter,
    String? searchQuery,
    bool? isTyping,
    bool? isSubmitting,
    String? toastMessage,
    List<ChatContactModel>? filteredContacts,
    List<CohortChannelModel>? filteredChannels,
    List<MentorAnnouncementModel>? filteredAnnouncements,
  }) {
    return CommunicationLoaded(
      data: data ?? this.data,
      activeTarget: activeTarget ?? this.activeTarget,
      isGroupChannel: isGroupChannel ?? this.isGroupChannel,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isTyping: isTyping ?? this.isTyping,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      toastMessage: toastMessage,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      filteredChannels: filteredChannels ?? this.filteredChannels,
      filteredAnnouncements: filteredAnnouncements ?? this.filteredAnnouncements,
    );
  }

  @override
  List<Object?> get props => [
        data,
        activeTarget,
        isGroupChannel,
        activeFilter,
        searchQuery,
        isTyping,
        isSubmitting,
        toastMessage,
        filteredContacts,
        filteredChannels,
        filteredAnnouncements,
      ];
}

class CommunicationError extends MentorCommunicationState {
  final String message;

  const CommunicationError(this.message);

  @override
  List<Object?> get props => [message];
}
