import 'package:equatable/equatable.dart';

/// Broadcast Center domain models for the College module.
///
/// Features 1:1 parity with `src/components/dashboard/college/views/BroadcastCenterView.tsx`.
/// Supports `isMock` boolean for fallback seeds with explicit asterisk `*`.
class BroadcastCenterData extends Equatable {
  final int totalSent;
  final double avgOpenRate;
  final int urgentPending;
  final List<BroadcastLogItem> broadcasts;
  final List<BroadcastLogItem> drafts;
  final List<BatchGroupItem> batchGroups;
  final bool isMock;

  const BroadcastCenterData({
    this.totalSent = 0,
    this.avgOpenRate = 0,
    this.urgentPending = 0,
    this.broadcasts = const [],
    this.drafts = const [],
    this.batchGroups = const [],
    this.isMock = false,
  });

  factory BroadcastCenterData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    List<BroadcastLogItem> parseBroadcasts(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => BroadcastLogItem.fromJson(e, isMock: isMock))
            .toList();
      }
      return const [];
    }

    List<BatchGroupItem> parseGroups(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => BatchGroupItem.fromJson(e, isMock: isMock))
            .toList();
      }
      return const [];
    }

    final broadcastsRaw =
        payload['broadcasts'] ?? payload['logs'] ?? payload['messages'] ?? payload['items'];
    final draftsRaw = payload['drafts'] ?? payload['draftMessages'];
    final groupsRaw = payload['batchGroups'] ?? payload['groups'] ?? payload['batches'];

    return BroadcastCenterData(
      totalSent: (payload['totalSent'] as num?)?.toInt() ??
          (payload['total_sent'] as num?)?.toInt() ??
          0,
      avgOpenRate: (payload['avgOpenRate'] as num?)?.toDouble() ??
          (payload['avg_open_rate'] as num?)?.toDouble() ??
          0,
      urgentPending: (payload['urgentPending'] as num?)?.toInt() ??
          (payload['urgent_pending'] as num?)?.toInt() ??
          0,
      broadcasts: parseBroadcasts(broadcastsRaw),
      drafts: parseBroadcasts(draftsRaw),
      batchGroups: parseGroups(groupsRaw),
      isMock: isMock,
    );
  }

  /// Initial Seed Dataset directly from React `BroadcastCenterView.tsx`
  static BroadcastCenterData mockSeed() {
    return const BroadcastCenterData(
      totalSent: 1248,
      avgOpenRate: 92.4,
      urgentPending: 3,
      isMock: true,
      broadcasts: [
        BroadcastLogItem(
          id: "bcast-1",
          type: BroadcastType.megaphone,
          title: "Google Recruitment Drive - Preliminary Shortlist",
          snippet:
              "Please review the preliminary shortlist for the upcoming Google engineering interviews scheduled for next week...",
          fullBody:
              "Please review the preliminary shortlist for the upcoming Google engineering interviews scheduled for next week. Shortlisted candidates must report to Seminar Hall B at 9:00 AM.",
          isUrgent: true,
          targetAudience: "CS & IT 2024 Batch",
          dateSent: "Oct 12, 2023",
          readCount: 145,
          totalCount: 200,
          status: BroadcastStatus.sent,
          isMock: true,
        ),
        BroadcastLogItem(
          id: "bcast-2",
          type: BroadcastType.document,
          title: "Weekly Placement Readiness Mock Test",
          snippet:
              "The mock test platform is now open for the weekly DSA & System Design assessment module...",
          fullBody:
              "The mock test platform is now open for the weekly DSA & System Design assessment module. Ensure test submission before Sunday midnight.",
          isUrgent: false,
          targetAudience: "All Final Years",
          dateSent: "Oct 10, 2023",
          readCount: 833,
          totalCount: 850,
          status: BroadcastStatus.sent,
          isMock: true,
        ),
        BroadcastLogItem(
          id: "bcast-3",
          type: BroadcastType.megaphone,
          title: "Stripe Technical Assessment Slot Allotment",
          snippet:
              "Individual test access credentials and online proctoring links have been dispatched...",
          fullBody:
              "Individual test access credentials and online proctoring links have been dispatched to shortlisted candidates. Check your student email portal.",
          isUrgent: true,
          targetAudience: "Shortlisted Candidates",
          dateSent: "Oct 08, 2023",
          readCount: 42,
          totalCount: 45,
          status: BroadcastStatus.sent,
          isMock: true,
        ),
        BroadcastLogItem(
          id: "bcast-4",
          type: BroadcastType.document,
          title: "Mandatory Resume Verification Reminder",
          snippet:
              "All unplaced candidates must update their project links and GitHub profiles before Friday...",
          fullBody:
              "All unplaced candidates must update their project links and GitHub profiles before Friday 5:00 PM for upcoming recruiter shortlist submissions.",
          isUrgent: false,
          targetAudience: "Unplaced Candidates",
          dateSent: "Oct 05, 2023",
          readCount: 310,
          totalCount: 350,
          status: BroadcastStatus.sent,
          isMock: true,
        ),
      ],
      drafts: [
        BroadcastLogItem(
          id: "draft-1",
          type: BroadcastType.document,
          title: "Draft: Amazon APAC Campus Hiring Timeline 2024",
          snippet: "Initial details regarding eligibility cutoff and registration window...",
          fullBody:
              "Initial details regarding eligibility cutoff and registration window for Amazon SDE 1 campus placement drive.",
          isUrgent: false,
          targetAudience: "All Final Years",
          dateSent: "Draft (Saved 2 hrs ago)",
          readCount: 0,
          totalCount: 850,
          status: BroadcastStatus.draft,
          isMock: true,
        ),
        BroadcastLogItem(
          id: "draft-2",
          type: BroadcastType.megaphone,
          title: "Draft: Placement Cell Feedback Survey Q3",
          snippet: "Collecting feedback regarding recent campus pre-placement talks...",
          fullBody:
              "Collecting feedback regarding recent campus pre-placement talks and interview experience.",
          isUrgent: false,
          targetAudience: "All Students",
          dateSent: "Draft (Saved yesterday)",
          readCount: 0,
          totalCount: 1200,
          status: BroadcastStatus.draft,
          isMock: true,
        ),
      ],
      batchGroups: [
        BatchGroupItem(
          id: "grp-1",
          name: "CS & IT 2024 Batch",
          description: "Computer Science and Information Technology graduating seniors",
          memberCount: 200,
          coordinator: "Prof. Rajesh Kumar",
          tagColor: "purple",
          isMock: true,
        ),
        BatchGroupItem(
          id: "grp-2",
          name: "All Final Years",
          description: "Entire 2024 graduating batch across all engineering departments",
          memberCount: 850,
          coordinator: "Dr. Sarah Jenkins",
          tagColor: "indigo",
          isMock: true,
        ),
        BatchGroupItem(
          id: "grp-3",
          name: "Electronics 2024 Batch",
          description: "ECE & Electrical Engineering placement candidates",
          memberCount: 180,
          coordinator: "Dr. Ananya Rao",
          tagColor: "blue",
          isMock: true,
        ),
        BatchGroupItem(
          id: "grp-4",
          name: "Corporate Recruiters & HRs",
          description: "Verified corporate talent acquisition contacts and TPO liaisons",
          memberCount: 65,
          coordinator: "Central TPO Cell",
          tagColor: "emerald",
          isMock: true,
        ),
      ],
    );
  }

  BroadcastCenterData copyWith({
    int? totalSent,
    double? avgOpenRate,
    int? urgentPending,
    List<BroadcastLogItem>? broadcasts,
    List<BroadcastLogItem>? drafts,
    List<BatchGroupItem>? batchGroups,
    bool? isMock,
  }) {
    return BroadcastCenterData(
      totalSent: totalSent ?? this.totalSent,
      avgOpenRate: avgOpenRate ?? this.avgOpenRate,
      urgentPending: urgentPending ?? this.urgentPending,
      broadcasts: broadcasts ?? this.broadcasts,
      drafts: drafts ?? this.drafts,
      batchGroups: batchGroups ?? this.batchGroups,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props =>
      [totalSent, avgOpenRate, urgentPending, broadcasts, drafts, batchGroups, isMock];
}

enum BroadcastType {
  megaphone,
  document;

  static BroadcastType fromString(String? value) {
    return value?.toLowerCase() == 'document'
        ? BroadcastType.document
        : BroadcastType.megaphone;
  }
}

enum BroadcastStatus {
  sent,
  draft;

  static BroadcastStatus fromString(String? value) {
    return value?.toLowerCase() == 'draft'
        ? BroadcastStatus.draft
        : BroadcastStatus.sent;
  }
}

class BroadcastLogItem extends Equatable {
  final String id;
  final BroadcastType type;
  final String title;
  final String snippet;
  final String fullBody;
  final bool isUrgent;
  final String targetAudience;
  final String dateSent;
  final int readCount;
  final int totalCount;
  final BroadcastStatus status;
  final bool isMock;

  const BroadcastLogItem({
    required this.id,
    this.type = BroadcastType.megaphone,
    this.title = '',
    this.snippet = '',
    this.fullBody = '',
    this.isUrgent = false,
    this.targetAudience = '',
    this.dateSent = '',
    this.readCount = 0,
    this.totalCount = 0,
    this.status = BroadcastStatus.sent,
    this.isMock = false,
  });

  factory BroadcastLogItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final String rawTitle = (json['title'] ?? json['subject'] ?? '').toString();
    final String rawBody = (json['fullBody'] ?? json['body'] ?? json['content'] ?? '').toString();
    final String rawSnippet = (json['snippet'] ?? json['preview'] ?? '').toString();
    final String snippetFallback = rawSnippet.isNotEmpty
        ? rawSnippet
        : (rawBody.length > 90 ? '${rawBody.substring(0, 90)}…' : rawBody);

    return BroadcastLogItem(
      id: (json['id'] ?? json['_id'] ?? 'bcast-${DateTime.now().millisecondsSinceEpoch}').toString(),
      type: BroadcastType.fromString((json['type'] ?? json['iconType'])?.toString()),
      title: rawTitle,
      snippet: snippetFallback,
      fullBody: rawBody.isNotEmpty ? rawBody : snippetFallback,
      isUrgent: (json['isUrgent'] ?? (json['priority'] == 'urgent') ?? false) as bool? ?? false,
      targetAudience: (json['targetAudience'] ?? json['audience'] ?? json['target'] ?? '').toString(),
      dateSent: (json['dateSent'] ?? json['createdAt'] ?? json['date'] ?? '').toString(),
      readCount: (json['readCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
      status: BroadcastStatus.fromString((json['status'] ?? json['state'])?.toString()),
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type == BroadcastType.document ? 'document' : 'megaphone',
        'title': title,
        'snippet': snippet,
        'fullBody': fullBody,
        'isUrgent': isUrgent,
        'targetAudience': targetAudience,
        'dateSent': dateSent,
        'readCount': readCount,
        'totalCount': totalCount,
        'status': status == BroadcastStatus.draft ? 'Draft' : 'Sent',
        'isMock': isMock,
      };

  int get readPercentage {
    if (totalCount <= 0) return 0;
    return ((readCount / totalCount) * 100).round().clamp(0, 100);
  }

  BroadcastLogItem copyWith({
    String? title,
    String? snippet,
    String? fullBody,
    bool? isUrgent,
    String? targetAudience,
    String? dateSent,
    int? readCount,
    int? totalCount,
    BroadcastStatus? status,
    bool? isMock,
  }) {
    return BroadcastLogItem(
      id: id,
      type: type,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      fullBody: fullBody ?? this.fullBody,
      isUrgent: isUrgent ?? this.isUrgent,
      targetAudience: targetAudience ?? this.targetAudience,
      dateSent: dateSent ?? this.dateSent,
      readCount: readCount ?? this.readCount,
      totalCount: totalCount ?? this.totalCount,
      status: status ?? this.status,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        snippet,
        fullBody,
        isUrgent,
        targetAudience,
        dateSent,
        readCount,
        totalCount,
        status,
        isMock,
      ];
}

class BatchGroupItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String coordinator;
  final String tagColor;
  final bool isMock;

  const BatchGroupItem({
    required this.id,
    this.name = '',
    this.description = '',
    this.memberCount = 0,
    this.coordinator = '',
    this.tagColor = 'purple',
    this.isMock = false,
  });

  factory BatchGroupItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return BatchGroupItem(
      id: (json['id'] ?? json['_id'] ?? 'grp-${DateTime.now().millisecondsSinceEpoch}').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? json['desc'] ?? '').toString(),
      memberCount: (json['memberCount'] as num?)?.toInt() ??
          (json['members'] as num?)?.toInt() ??
          0,
      coordinator: (json['coordinator'] ?? json['owner'] ?? '').toString(),
      tagColor: (json['tagColor'] ?? json['color'] ?? 'purple').toString(),
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'memberCount': memberCount,
        'coordinator': coordinator,
        'tagColor': tagColor,
        'isMock': isMock,
      };

  BatchGroupItem copyWith({
    String? name,
    String? description,
    int? memberCount,
    String? coordinator,
    String? tagColor,
    bool? isMock,
  }) {
    return BatchGroupItem(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      coordinator: coordinator ?? this.coordinator,
      tagColor: tagColor ?? this.tagColor,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, memberCount, coordinator, tagColor, isMock];
}
