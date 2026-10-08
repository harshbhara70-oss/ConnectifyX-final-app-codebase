import 'package:equatable/equatable.dart';

class ChatMessageItem extends Equatable {
  final String id;
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  const ChatMessageItem({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    final senderStr = json['sender']?.toString() ?? 'recruiter';
    return ChatMessageItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: senderStr,
      text: json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Just now',
      isMe: json['isMe'] == true || senderStr == 'recruiter',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'time': time,
      'isMe': isMe,
    };
  }

  @override
  List<Object?> get props => [id, sender, text, time, isMe];
}

class RecruiterConversationItem extends Equatable {
  final String id;
  final String candidateName;
  final String role;
  final String lastMessage;
  final String time;
  final List<ChatMessageItem> messages;
  final bool isMock;

  const RecruiterConversationItem({
    required this.id,
    required this.candidateName,
    required this.role,
    required this.lastMessage,
    required this.time,
    this.messages = const [],
    this.isMock = false,
  });

  factory RecruiterConversationItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    List<ChatMessageItem> parsedMessages = [];
    if (json['messages'] != null && json['messages'] is List) {
      parsedMessages = (json['messages'] as List)
          .map((m) => ChatMessageItem.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      parsedMessages = [
        ChatMessageItem(
          id: '1',
          sender: 'recruiter',
          text: json['lastMessage']?.toString() ?? 'Hello, thank you for applying.',
          time: json['time']?.toString() ?? 'Just now',
          isMe: true,
        ),
      ];
    }

    return RecruiterConversationItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      candidateName: json['candidateName']?.toString() ?? 'Candidate',
      role: json['role']?.toString() ?? 'Software Engineer',
      lastMessage: json['lastMessage']?.toString() ?? '',
      time: json['time']?.toString() ?? 'Just now',
      messages: parsedMessages,
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'candidateName': candidateName,
      'role': role,
      'lastMessage': lastMessage,
      'time': time,
      'messages': messages.map((m) => m.toJson()).toList(),
      'isMock': isMock,
    };
  }

  RecruiterConversationItem copyWith({
    String? id,
    String? candidateName,
    String? role,
    String? lastMessage,
    String? time,
    List<ChatMessageItem>? messages,
    bool? isMock,
  }) {
    return RecruiterConversationItem(
      id: id ?? this.id,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      messages: messages ?? this.messages,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, candidateName, role, lastMessage, time, messages, isMock];
}
