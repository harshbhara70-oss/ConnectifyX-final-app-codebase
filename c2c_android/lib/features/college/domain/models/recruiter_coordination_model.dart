import 'package:equatable/equatable.dart';

/// Opening/Job vacancy posted by a corporate partner.
class RecruiterOpeningModel extends Equatable {
  final String id;
  final String title;
  final String badge; // 'HIRING', 'SHORTLISTING', 'CLOSED'
  final int positions;
  final String packageText;
  final String deadlineText;
  final bool isMock;

  const RecruiterOpeningModel({
    required this.id,
    required this.title,
    this.badge = 'HIRING',
    this.positions = 5,
    this.packageText = '12 - 18 LPA',
    this.deadlineText = 'Open',
    this.isMock = false,
  });

  factory RecruiterOpeningModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return RecruiterOpeningModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'op-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? json['role']?.toString() ?? 'Software Engineer',
      badge: (json['badge']?.toString() ?? json['status']?.toString() ?? 'HIRING').toUpperCase(),
      positions: (json['positions'] as num?)?.toInt() ?? (json['openings'] as num?)?.toInt() ?? 5,
      packageText: json['packageText']?.toString() ??
          json['packageLPA']?.toString() ??
          '${((json['stipend'] as num?)?.toDouble() ?? 100000) / 100000 * 12} LPA',
      deadlineText: json['deadlineText']?.toString() ?? json['applicationDeadline']?.toString() ?? 'Open',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'badge': badge,
    'positions': positions,
    'packageText': packageText,
    'deadlineText': deadlineText,
    'isMock': isMock,
  };

  RecruiterOpeningModel copyWith({
    String? id,
    String? title,
    String? badge,
    int? positions,
    String? packageText,
    String? deadlineText,
    bool? isMock,
  }) {
    return RecruiterOpeningModel(
      id: id ?? this.id,
      title: title ?? this.title,
      badge: badge ?? this.badge,
      positions: positions ?? this.positions,
      packageText: packageText ?? this.packageText,
      deadlineText: deadlineText ?? this.deadlineText,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, title, badge, positions, packageText, deadlineText, isMock];
}

/// Intelligence activity feed event for a partner.
class IntelligenceEventModel extends Equatable {
  final String id;
  final String title;
  final String timeAgo;
  final String description;
  final String iconType; // 'share', 'email', 'meeting', 'feedback'
  final bool isMock;

  const IntelligenceEventModel({
    required this.id,
    required this.title,
    this.timeAgo = 'Recently',
    this.description = '',
    this.iconType = 'meeting',
    this.isMock = false,
  });

  factory IntelligenceEventModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return IntelligenceEventModel(
      id: json['id']?.toString() ?? 'ev-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Activity Logged',
      timeAgo: json['timeAgo']?.toString() ?? 'Recently',
      description: json['description']?.toString() ?? '',
      iconType: json['iconType']?.toString() ?? 'meeting',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeAgo': timeAgo,
    'description': description,
    'iconType': iconType,
    'isMock': isMock,
  };

  IntelligenceEventModel copyWith({
    String? id,
    String? title,
    String? timeAgo,
    String? description,
    String? iconType,
    bool? isMock,
  }) {
    return IntelligenceEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      timeAgo: timeAgo ?? this.timeAgo,
      description: description ?? this.description,
      iconType: iconType ?? this.iconType,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [id, title, timeAgo, description, iconType, isMock];
}

/// Corporate Partner Model for College Recruiter Coordination screen.
/// Directly mirrors the web `RecruiterCoordinationView.tsx` data architecture.
class CorporatePartnerModel extends Equatable {
  final String id;
  final String companyName;
  final String logoLetter;
  final String logoBg;
  final String statusBadge; // '🟢 Highly Engaged', '🟣 Active Drive', '⚪ Pending Sync'
  final String lastActivity;
  final String location;
  final String industry;
  final String hiringVelocity;
  final String hiringVelocityTrend;
  final String conversionRate;
  final String conversionBenchmark;
  final double studentRating;
  final String contactName;
  final String contactTitle;
  final String contactAvatar;
  final String contactEmail;
  final String contactPhone;
  final String nextBestActionText;
  final List<RecruiterOpeningModel> openings;
  final List<IntelligenceEventModel> intelligenceFeed;
  final int sharedTalentCount;
  final int driveHistoryCount;
  final bool isMock;

  const CorporatePartnerModel({
    required this.id,
    required this.companyName,
    this.logoLetter = 'C',
    this.logoBg = '',
    this.statusBadge = '🟢 Highly Engaged',
    this.lastActivity = 'Recently',
    this.location = 'Campus Placement Cell',
    this.industry = 'Technology & Software',
    this.hiringVelocity = 'High',
    this.hiringVelocityTrend = '+12%',
    this.conversionRate = '22.4%',
    this.conversionBenchmark = 'Avg 18%',
    this.studentRating = 4.8,
    this.contactName = 'Recruiter Lead',
    this.contactTitle = 'Talent Acquisition Lead',
    this.contactAvatar = '',
    this.contactEmail = 'recruiter@company.com',
    this.contactPhone = '+91 9876543210',
    this.nextBestActionText = 'Review shortlisted batch candidates and dispatch interview slots.',
    this.openings = const [],
    this.intelligenceFeed = const [],
    this.sharedTalentCount = 30,
    this.driveHistoryCount = 3,
    this.isMock = false,
  });

  factory CorporatePartnerModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final company = json['companyName']?.toString() ??
        json['company']?['name']?.toString() ??
        json['company']?.toString() ??
        json['name']?.toString() ??
        'Corporate Partner';
    final initial = company.trim().isNotEmpty ? company.trim()[0].toUpperCase() : 'C';

    final rawOpenings = json['openings'] ?? json['projects'] ?? const [];
    final openingsList = (rawOpenings is List)
        ? rawOpenings.whereType<Map<String, dynamic>>().map((o) => RecruiterOpeningModel.fromJson(o, isMock: isMock)).toList()
        : <RecruiterOpeningModel>[];

    final rawFeed = json['intelligenceFeed'] ?? json['feed'] ?? const [];
    final feedList = (rawFeed is List)
        ? rawFeed.whereType<Map<String, dynamic>>().map((f) => IntelligenceEventModel.fromJson(f, isMock: isMock)).toList()
        : <IntelligenceEventModel>[];

    return CorporatePartnerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'part-${DateTime.now().millisecondsSinceEpoch}',
      companyName: company,
      logoLetter: json['logoLetter']?.toString() ?? initial,
      logoBg: json['logoBg']?.toString() ?? '',
      statusBadge: json['statusBadge']?.toString() ?? (json['status']?.toString() == 'Open' ? '🟣 Active Drive' : '🟢 Highly Engaged'),
      lastActivity: json['lastActivity']?.toString() ?? 'Recently',
      location: json['location']?.toString() ?? 'Bengaluru, India',
      industry: json['industry']?.toString() ?? 'Software & IT',
      hiringVelocity: json['hiringVelocity']?.toString() ?? 'High',
      hiringVelocityTrend: json['hiringVelocityTrend']?.toString() ?? '+10%',
      conversionRate: json['conversionRate']?.toString() ?? '20.5%',
      conversionBenchmark: json['conversionBenchmark']?.toString() ?? 'Avg 18%',
      studentRating: (json['studentRating'] as num?)?.toDouble() ?? 4.7,
      contactName: json['contactName']?.toString() ?? json['recruiter']?['name']?.toString() ?? 'University Recruiter',
      contactTitle: json['contactTitle']?.toString() ?? 'Senior Talent Acquisition Manager',
      contactAvatar: json['contactAvatar']?.toString() ?? '',
      contactEmail: json['contactEmail']?.toString() ?? json['recruiter']?['email']?.toString() ?? 'recruiter@${company.toLowerCase().replaceAll(' ', '')}.com',
      contactPhone: json['contactPhone']?.toString() ?? json['recruiter']?['phone']?.toString() ?? '+91 9876543210',
      nextBestActionText: json['nextBestActionText']?.toString() ?? '$company viewed the gold tier candidate batch packet recently.',
      openings: openingsList,
      intelligenceFeed: feedList,
      sharedTalentCount: (json['sharedTalentCount'] as num?)?.toInt() ?? 25,
      driveHistoryCount: (json['driveHistoryCount'] as num?)?.toInt() ?? 2,
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'logoLetter': logoLetter,
    'logoBg': logoBg,
    'statusBadge': statusBadge,
    'lastActivity': lastActivity,
    'location': location,
    'industry': industry,
    'hiringVelocity': hiringVelocity,
    'hiringVelocityTrend': hiringVelocityTrend,
    'conversionRate': conversionRate,
    'conversionBenchmark': conversionBenchmark,
    'studentRating': studentRating,
    'contactName': contactName,
    'contactTitle': contactTitle,
    'contactAvatar': contactAvatar,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'nextBestActionText': nextBestActionText,
    'openings': openings.map((o) => o.toJson()).toList(),
    'intelligenceFeed': intelligenceFeed.map((e) => e.toJson()).toList(),
    'sharedTalentCount': sharedTalentCount,
    'driveHistoryCount': driveHistoryCount,
    'isMock': isMock,
  };

  CorporatePartnerModel copyWith({
    String? id,
    String? companyName,
    String? logoLetter,
    String? logoBg,
    String? statusBadge,
    String? lastActivity,
    String? location,
    String? industry,
    String? hiringVelocity,
    String? hiringVelocityTrend,
    String? conversionRate,
    String? conversionBenchmark,
    double? studentRating,
    String? contactName,
    String? contactTitle,
    String? contactAvatar,
    String? contactEmail,
    String? contactPhone,
    String? nextBestActionText,
    List<RecruiterOpeningModel>? openings,
    List<IntelligenceEventModel>? intelligenceFeed,
    int? sharedTalentCount,
    int? driveHistoryCount,
    bool? isMock,
  }) {
    return CorporatePartnerModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      logoLetter: logoLetter ?? this.logoLetter,
      logoBg: logoBg ?? this.logoBg,
      statusBadge: statusBadge ?? this.statusBadge,
      lastActivity: lastActivity ?? this.lastActivity,
      location: location ?? this.location,
      industry: industry ?? this.industry,
      hiringVelocity: hiringVelocity ?? this.hiringVelocity,
      hiringVelocityTrend: hiringVelocityTrend ?? this.hiringVelocityTrend,
      conversionRate: conversionRate ?? this.conversionRate,
      conversionBenchmark: conversionBenchmark ?? this.conversionBenchmark,
      studentRating: studentRating ?? this.studentRating,
      contactName: contactName ?? this.contactName,
      contactTitle: contactTitle ?? this.contactTitle,
      contactAvatar: contactAvatar ?? this.contactAvatar,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      nextBestActionText: nextBestActionText ?? this.nextBestActionText,
      openings: openings ?? this.openings,
      intelligenceFeed: intelligenceFeed ?? this.intelligenceFeed,
      sharedTalentCount: sharedTalentCount ?? this.sharedTalentCount,
      driveHistoryCount: driveHistoryCount ?? this.driveHistoryCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyName,
    logoLetter,
    logoBg,
    statusBadge,
    lastActivity,
    location,
    industry,
    hiringVelocity,
    hiringVelocityTrend,
    conversionRate,
    conversionBenchmark,
    studentRating,
    contactName,
    contactTitle,
    contactAvatar,
    contactEmail,
    contactPhone,
    nextBestActionText,
    openings,
    intelligenceFeed,
    sharedTalentCount,
    driveHistoryCount,
    isMock,
  ];
}

/// Overall Recruiter Coordination state container
class RecruiterCoordinationData extends Equatable {
  final int totalPartners;
  final int activeDrives;
  final String avgConversionRate;
  final double avgStudentRating;
  final List<CorporatePartnerModel> partners;
  final bool isMock;

  const RecruiterCoordinationData({
    this.totalPartners = 0,
    this.activeDrives = 0,
    this.avgConversionRate = '22.4%',
    this.avgStudentRating = 4.8,
    this.partners = const [],
    this.isMock = false,
  });

  factory RecruiterCoordinationData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final raw = json['data'] ?? json['partners'] ?? json['recruiters'] ?? const [];
    final list = (raw is List)
        ? raw.whereType<Map<String, dynamic>>().map((p) => CorporatePartnerModel.fromJson(p, isMock: isMock)).toList()
        : <CorporatePartnerModel>[];

    return RecruiterCoordinationData(
      totalPartners: (json['totalPartners'] as num?)?.toInt() ?? list.length,
      activeDrives: (json['activeDrives'] as num?)?.toInt() ??
          list.where((p) => p.statusBadge.toLowerCase().contains('active')).length,
      avgConversionRate: json['avgConversionRate']?.toString() ?? '22.4%',
      avgStudentRating: (json['avgStudentRating'] as num?)?.toDouble() ?? 4.8,
      partners: list,
      isMock: isMock,
    );
  }

  static const RecruiterCoordinationData empty = RecruiterCoordinationData(
    totalPartners: 0,
    activeDrives: 0,
    avgConversionRate: 'Soon',
    avgStudentRating: 0.0,
    partners: [],
    isMock: false,
  );

  /// 1:1 Seed Dataset matching INITIAL_PARTNERS from web `RecruiterCoordinationView.tsx`
  static RecruiterCoordinationData mockSeed() {
    final partners = [
      CorporatePartnerModel(
        id: 'part-1',
        companyName: 'TechVanguard Systems',
        logoLetter: 'T',
        statusBadge: '🟢 Highly Engaged',
        lastActivity: '2H AGO',
        location: 'Palo Alto, CA',
        industry: 'Software & AI',
        hiringVelocity: 'High',
        hiringVelocityTrend: '+12%',
        conversionRate: '22.4%',
        conversionBenchmark: 'Avg 18%',
        studentRating: 4.8,
        contactName: 'Sarah Jenkins',
        contactTitle: 'Senior Talent Acquisition Lead',
        contactAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
        contactEmail: 'sarah.jenkins@techvanguard.io',
        contactPhone: '+1 (650) 555-0192',
        nextBestActionText: "TechVanguard viewed the 'Gold Tier Batch' packet 14 times today.",
        openings: const [
          RecruiterOpeningModel(
            id: 'op-1',
            title: 'Associate Software Engineer',
            badge: 'HIRING',
            positions: 12,
            packageText: '18 - 24 LPA',
            deadlineText: 'Deadline: Oct 12',
            isMock: true,
          ),
          RecruiterOpeningModel(
            id: 'op-2',
            title: 'Data Science Intern',
            badge: 'SHORTLISTING',
            positions: 5,
            packageText: '45k Stipend',
            deadlineText: 'Deadline: Closed',
            isMock: true,
          ),
          RecruiterOpeningModel(
            id: 'op-3',
            title: 'DevOps & Cloud Engineer',
            badge: 'HIRING',
            positions: 8,
            packageText: '16 - 20 LPA',
            deadlineText: 'Deadline: Nov 01',
            isMock: true,
          ),
        ],
        intelligenceFeed: const [
          IntelligenceEventModel(
            id: 'ev-1',
            title: 'Profiles Shared',
            timeAgo: '2h ago',
            description: 'Batch 2024 Top 50 packet shared with Sarah via secure link.',
            iconType: 'share',
            isMock: true,
          ),
          IntelligenceEventModel(
            id: 'ev-2',
            title: 'Email Interaction',
            timeAgo: 'Yesterday',
            description: 'Confirmed receipt of new JD for DevOps role.',
            iconType: 'email',
            isMock: true,
          ),
          IntelligenceEventModel(
            id: 'ev-3',
            title: 'Meeting Held',
            timeAgo: '3 days ago',
            description: 'On-campus visit for facility audit completed.',
            iconType: 'meeting',
            isMock: true,
          ),
          IntelligenceEventModel(
            id: 'ev-4',
            title: 'Feedback Received',
            timeAgo: '5 days ago',
            description: "Tech interview feedback: 'Strong coding skills, need more soft skill focus.'",
            iconType: 'feedback',
            isMock: true,
          ),
        ],
        sharedTalentCount: 50,
        driveHistoryCount: 6,
        isMock: true,
      ),
      CorporatePartnerModel(
        id: 'part-2',
        companyName: 'Lumina Robotics',
        logoLetter: 'L',
        statusBadge: '🟣 Active Drive',
        lastActivity: '4H AGO',
        location: 'Austin, TX',
        industry: 'Robotics & Automation',
        hiringVelocity: 'Medium',
        hiringVelocityTrend: '+8%',
        conversionRate: '19.5%',
        conversionBenchmark: 'Avg 18%',
        studentRating: 4.6,
        contactName: 'Marcus Vance',
        contactTitle: 'Head of Campus Relations',
        contactAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
        contactEmail: 'marcus.v@luminarobotics.com',
        contactPhone: '+1 (512) 555-0144',
        nextBestActionText: 'Lumina Robotics requested 10 additional interview slots for ECE batch.',
        openings: const [
          RecruiterOpeningModel(
            id: 'op-4',
            title: 'Embedded Systems Hardware Engineer',
            badge: 'HIRING',
            positions: 8,
            packageText: '15 - 20 LPA',
            deadlineText: 'Deadline: Oct 28',
            isMock: true,
          ),
        ],
        intelligenceFeed: const [
          IntelligenceEventModel(
            id: 'ev-5',
            title: 'Drive Scheduled',
            timeAgo: '1h ago',
            description: 'On-campus physical interviews locked for Nov 10.',
            iconType: 'meeting',
            isMock: true,
          ),
        ],
        sharedTalentCount: 35,
        driveHistoryCount: 3,
        isMock: true,
      ),
      CorporatePartnerModel(
        id: 'part-3',
        companyName: 'Nexus Fintech',
        logoLetter: 'N',
        statusBadge: '⚪ Pending Sync',
        lastActivity: '1D AGO',
        location: 'New York, NY',
        industry: 'Fintech & Banking',
        hiringVelocity: 'Moderate',
        hiringVelocityTrend: '+5%',
        conversionRate: '17.8%',
        conversionBenchmark: 'Avg 18%',
        studentRating: 4.5,
        contactName: 'Elena Rostova',
        contactTitle: 'University Recruiting Lead',
        contactAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
        contactEmail: 'elena.r@nexusfintech.com',
        contactPhone: '+1 (212) 555-0881',
        nextBestActionText: 'Nexus Fintech pending NDA sign-off for autumn drive.',
        openings: const [
          RecruiterOpeningModel(
            id: 'op-5',
            title: 'Quantitative Risk Analyst',
            badge: 'SHORTLISTING',
            positions: 6,
            packageText: '16.5 LPA',
            deadlineText: 'Deadline: Nov 05',
            isMock: true,
          ),
        ],
        intelligenceFeed: const [
          IntelligenceEventModel(
            id: 'ev-6',
            title: 'NDA Contract Dispatched',
            timeAgo: '2 days ago',
            description: 'Contract sent to Elena via legal portal.',
            iconType: 'email',
            isMock: true,
          ),
        ],
        sharedTalentCount: 20,
        driveHistoryCount: 2,
        isMock: true,
      ),
    ];

    return RecruiterCoordinationData(
      totalPartners: 42,
      activeDrives: 14,
      avgConversionRate: '22.4%',
      avgStudentRating: 4.8,
      partners: partners,
      isMock: true,
    );
  }

  RecruiterCoordinationData copyWith({
    int? totalPartners,
    int? activeDrives,
    String? avgConversionRate,
    double? avgStudentRating,
    List<CorporatePartnerModel>? partners,
    bool? isMock,
  }) {
    return RecruiterCoordinationData(
      totalPartners: totalPartners ?? this.totalPartners,
      activeDrives: activeDrives ?? this.activeDrives,
      avgConversionRate: avgConversionRate ?? this.avgConversionRate,
      avgStudentRating: avgStudentRating ?? this.avgStudentRating,
      partners: partners ?? this.partners,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [totalPartners, activeDrives, avgConversionRate, avgStudentRating, partners, isMock];
}
