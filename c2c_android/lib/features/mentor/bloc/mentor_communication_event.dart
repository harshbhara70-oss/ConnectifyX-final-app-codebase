import 'package:equatable/equatable.dart';

abstract class MentorCommunicationEvent extends Equatable {
  const MentorCommunicationEvent();

  @override
  List<Object?> get props => [];
}

class FetchCommunicationDataEvent extends MentorCommunicationEvent {
  final bool isRefresh;

  const FetchCommunicationDataEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SelectChatTargetEvent extends MentorCommunicationEvent {
  final String targetName; // student name or '#channel-name'
  final bool isGroup;

  const SelectChatTargetEvent({
    required this.targetName,
    required this.isGroup,
  });

  @override
  List<Object?> get props => [targetName, isGroup];
}

class SendChatMessageEvent extends MentorCommunicationEvent {
  final String targetName;
  final String text;
  final bool isGroup;

  const SendChatMessageEvent({
    required this.targetName,
    required this.text,
    required this.isGroup,
  });

  @override
  List<Object?> get props => [targetName, text, isGroup];
}

class FilterChannelTypeEvent extends MentorCommunicationEvent {
  final String filter; // 'all' | 'direct' | 'cohort' | 'announcements'

  const FilterChannelTypeEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchCommunicationEvent extends MentorCommunicationEvent {
  final String query;

  const SearchCommunicationEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateAnnouncementEvent extends MentorCommunicationEvent {
  final String title;
  final String content;
  final String category;

  const CreateAnnouncementEvent({
    required this.title,
    required this.content,
    required this.category,
  });

  @override
  List<Object?> get props => [title, content, category];
}

class StartDirectChatEvent extends MentorCommunicationEvent {
  final String studentName;
  final String initialMessage;

  const StartDirectChatEvent({
    required this.studentName,
    required this.initialMessage,
  });

  @override
  List<Object?> get props => [studentName, initialMessage];
}
