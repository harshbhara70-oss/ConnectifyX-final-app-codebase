import 'package:equatable/equatable.dart';

/// Single Message / Response entry inside a Support Ticket thread.
class AdminSupportMessageModel extends Equatable {
  final String id;
  final String senderName;
  final String senderRole;
  final String? avatarUrl;
  final String timestamp;
  final String content;
  final bool isInternalNote;
  final String? attachmentName;
  final String? attachmentSize;

  const AdminSupportMessageModel({
    required this.id,
    required this.senderName,
    required this.senderRole,
    this.avatarUrl,
    required this.timestamp,
    required this.content,
    this.isInternalNote = false,
    this.attachmentName,
    this.attachmentSize,
  });

  factory AdminSupportMessageModel.fromJson(Map<String, dynamic> json) {
    return AdminSupportMessageModel(
      id: json['id']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? 'Support Staff',
      senderRole: json['senderRole']?.toString() ?? 'Administrator',
      avatarUrl: json['avatarUrl']?.toString(),
      timestamp: json['timestamp']?.toString() ?? 'Just now',
      content: json['content']?.toString() ?? '',
      isInternalNote: json['isInternalNote'] == true,
      attachmentName: json['attachmentName']?.toString(),
      attachmentSize: json['attachmentSize']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'senderRole': senderRole,
      'avatarUrl': avatarUrl,
      'timestamp': timestamp,
      'content': content,
      'isInternalNote': isInternalNote,
      'attachmentName': attachmentName,
      'attachmentSize': attachmentSize,
    };
  }

  @override
  List<Object?> get props => [
        id,
        senderName,
        senderRole,
        avatarUrl,
        timestamp,
        content,
        isInternalNote,
        attachmentName,
        attachmentSize,
      ];
}

/// Primary Support Ticket model matching web SupportCenter.tsx
class AdminSupportTicketModel extends Equatable {
  final String id;
  final String title;
  final String requester;
  final String organization;
  final String priority; // 'Critical Priority', 'Escalated', 'Standard'
  final String type; // 'Dispute', 'Request', 'System Issue'
  final String sla; // '2h 14m remaining', '14h ago', 'Yesterday'
  final String created;
  final String status; // 'open', 'in_progress', 'resolved'
  final bool unread;
  final List<AdminSupportMessageModel> messages;
  final String? attachmentName;
  final String? attachmentSize;
  final String? assignedTo;
  final bool isMock;

  const AdminSupportTicketModel({
    required this.id,
    required this.title,
    required this.requester,
    required this.organization,
    required this.priority,
    required this.type,
    required this.sla,
    required this.created,
    required this.status,
    this.unread = false,
    this.messages = const [],
    this.attachmentName,
    this.attachmentSize,
    this.assignedTo,
    this.isMock = false,
  });

  AdminSupportTicketModel copyWith({
    String? id,
    String? title,
    String? requester,
    String? organization,
    String? priority,
    String? type,
    String? sla,
    String? created,
    String? status,
    bool? unread,
    List<AdminSupportMessageModel>? messages,
    String? attachmentName,
    String? attachmentSize,
    String? assignedTo,
    bool? isMock,
  }) {
    return AdminSupportTicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      requester: requester ?? this.requester,
      organization: organization ?? this.organization,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      sla: sla ?? this.sla,
      created: created ?? this.created,
      status: status ?? this.status,
      unread: unread ?? this.unread,
      messages: messages ?? this.messages,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      assignedTo: assignedTo ?? this.assignedTo,
      isMock: isMock ?? this.isMock,
    );
  }

  factory AdminSupportTicketModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return AdminSupportTicketModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      requester: json['requester']?.toString() ?? 'Anonymous',
      organization: json['organization']?.toString() ?? json['org']?.toString() ?? 'General',
      priority: json['priority']?.toString() ?? 'Standard',
      type: json['type']?.toString() ?? 'Inquiry',
      sla: json['sla']?.toString() ?? '1d SLA',
      created: json['created']?.toString() ?? json['createdAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      unread: json['unread'] == true,
      messages: rawMessages.map((m) => AdminSupportMessageModel.fromJson(m as Map<String, dynamic>)).toList(),
      attachmentName: json['attachmentName']?.toString(),
      attachmentSize: json['attachmentSize']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'requester': requester,
      'organization': organization,
      'priority': priority,
      'type': type,
      'sla': sla,
      'created': created,
      'status': status,
      'unread': unread,
      'messages': messages.map((m) => m.toJson()).toList(),
      'attachmentName': attachmentName,
      'attachmentSize': attachmentSize,
      'assignedTo': assignedTo,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        requester,
        organization,
        priority,
        type,
        sla,
        created,
        status,
        unread,
        messages,
        attachmentName,
        attachmentSize,
        assignedTo,
        isMock,
      ];
}

/// Summary Stats counters matching top badges in SupportCenter.tsx
class AdminSupportStatsModel extends Equatable {
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final bool isMock;

  const AdminSupportStatsModel({
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    this.isMock = false,
  });

  factory AdminSupportStatsModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminSupportStatsModel(
      openCount: (json['openCount'] as num?)?.toInt() ?? (isMock ? 124 : 0),
      inProgressCount: (json['inProgressCount'] as num?)?.toInt() ?? (isMock ? 38 : 0),
      resolvedCount: (json['resolvedCount'] as num?)?.toInt() ?? (isMock ? 892 : 0),
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openCount': openCount,
      'inProgressCount': inProgressCount,
      'resolvedCount': resolvedCount,
      'isMock': isMock,
    };
  }

  @override
  List<Object?> get props => [openCount, inProgressCount, resolvedCount, isMock];
}

/// Aggregate DTO for Support Center
class AdminSupportDataDto extends Equatable {
  final AdminSupportStatsModel stats;
  final List<AdminSupportTicketModel> tickets;
  final bool isMock;

  const AdminSupportDataDto({
    required this.stats,
    required this.tickets,
    this.isMock = false,
  });

  factory AdminSupportDataDto.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawTickets = json['tickets'] as List<dynamic>? ?? [];
    return AdminSupportDataDto(
      stats: json['stats'] != null
          ? AdminSupportStatsModel.fromJson(json['stats'] as Map<String, dynamic>, isMock: isMock)
          : AdminSupportStatsModel(
              openCount: isMock ? 124 : 0,
              inProgressCount: isMock ? 38 : 0,
              resolvedCount: isMock ? 892 : 0,
              isMock: isMock,
            ),
      tickets: rawTickets
          .map((t) => AdminSupportTicketModel.fromJson(t as Map<String, dynamic>, isMock: isMock))
          .toList(),
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [stats, tickets, isMock];
}
