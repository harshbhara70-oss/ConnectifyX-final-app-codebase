import 'package:equatable/equatable.dart';
import 'mentor_overview_model.dart';

/// Single chat message model supporting mentor and mentee participants
class ChatMessageModel extends Equatable {
  final String id;
  final String sender; // 'mentor' | 'student'
  final String senderName;
  final String text;
  final String timestamp;
  final bool isMock;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isMock = false,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sender: json['sender'] as String? ?? 'student',
      senderName: json['senderName'] as String? ?? 'Mentee',
      text: json['text'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? 'Just now',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? sender,
    String? senderName,
    String? text,
    String? timestamp,
    bool? isMock,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, sender, senderName, text, timestamp, isMock];
}

/// Direct message contact representation for mentees
class ChatContactModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String college;
  final String avatar;
  final String avatarBg;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isMock;

  const ChatContactModel({
    required this.id,
    required this.name,
    required this.role,
    required this.college,
    required this.avatar,
    required this.avatarBg,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = true,
    this.isMock = false,
  });

  factory ChatContactModel.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return ChatContactModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? 'Candidate',
      role: json['role'] as String? ?? 'Mentee',
      college: json['college'] as String? ?? 'Campus Candidate',
      avatar: json['avatar'] as String? ?? 'CC',
      avatarBg: json['avatarBg'] as String? ?? '0xFF6366F1',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? 'Today',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] as bool? ?? true,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'college': college,
      'avatar': avatar,
      'avatarBg': avatarBg,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }

  ChatContactModel copyWith({
    String? id,
    String? name,
    String? role,
    String? college,
    String? avatar,
    String? avatarBg,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    bool? isMock,
  }) {
    return ChatContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      college: college ?? this.college,
      avatar: avatar ?? this.avatar,
      avatarBg: avatarBg ?? this.avatarBg,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        college,
        avatar,
        avatarBg,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isOnline,
        isMock,
      ];
}

/// Cohort and workspace group channels (e.g. #stripe-frontend, #atlassian-cohort)
class CohortChannelModel extends Equatable {
  final String id;
  final String name; // e.g. '#stripe-frontend'
  final String topic;
  final int memberCount;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isMock;

  const CohortChannelModel({
    required this.id,
    required this.name,
    required this.topic,
    required this.memberCount,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isMock = false,
  });

  factory CohortChannelModel.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return CohortChannelModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '#channel',
      topic: json['topic'] as String? ?? 'Cohort Channel',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 12,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] as String? ?? 'Today',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'topic': topic,
      'memberCount': memberCount,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
    };
  }

  CohortChannelModel copyWith({
    String? id,
    String? name,
    String? topic,
    int? memberCount,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    bool? isMock,
  }) {
    return CohortChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      topic: topic ?? this.topic,
      memberCount: memberCount ?? this.memberCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        topic,
        memberCount,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isMock,
      ];
}

/// Placement Victory Ticker Banner (Module 18 from MentorDashboard.tsx)
class PlacementSuccessStoryModel extends Equatable {
  final String id;
  final String studentName;
  final String company;
  final String package;
  final String role;
  final String date;
  final String message;
  final bool isMock;

  const PlacementSuccessStoryModel({
    required this.id,
    required this.studentName,
    required this.company,
    required this.package,
    required this.role,
    required this.date,
    required this.message,
    this.isMock = false,
  });

  factory PlacementSuccessStoryModel.fromJson(
    Map<String, dynamic> json, {
    bool isMock = false,
  }) {
    return PlacementSuccessStoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      studentName: json['studentName'] as String? ?? 'Rahul Sharma',
      company: json['company'] as String? ?? 'TCS',
      package: json['package'] as String? ?? '₹7 LPA',
      role: json['role'] as String? ?? 'Frontend Developer',
      date: json['date'] as String? ?? 'Today',
      message: json['message'] as String? ??
          'Congratulations! Rahul Sharma placed at TCS (Package: ₹7 LPA) - Mentored by You',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'company': company,
      'package': package,
      'role': role,
      'date': date,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [
        id,
        studentName,
        company,
        package,
        role,
        date,
        message,
        isMock,
      ];
}

/// Aggregated Communication Hub payload
class MentorCommunicationData extends Equatable {
  final PlacementSuccessStoryModel successStory;
  final List<ChatContactModel> contacts;
  final List<CohortChannelModel> channels;
  final List<MentorAnnouncementModel> announcements;
  final Map<String, List<ChatMessageModel>> chatHistory;
  final bool isMock;

  const MentorCommunicationData({
    required this.successStory,
    required this.contacts,
    required this.channels,
    required this.announcements,
    required this.chatHistory,
    this.isMock = false,
  });

  MentorCommunicationData copyWith({
    PlacementSuccessStoryModel? successStory,
    List<ChatContactModel>? contacts,
    List<CohortChannelModel>? channels,
    List<MentorAnnouncementModel>? announcements,
    Map<String, List<ChatMessageModel>>? chatHistory,
    bool? isMock,
  }) {
    return MentorCommunicationData(
      successStory: successStory ?? this.successStory,
      contacts: contacts ?? this.contacts,
      channels: channels ?? this.channels,
      announcements: announcements ?? this.announcements,
      chatHistory: chatHistory ?? this.chatHistory,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        successStory,
        contacts,
        channels,
        announcements,
        chatHistory,
        isMock,
      ];
}
