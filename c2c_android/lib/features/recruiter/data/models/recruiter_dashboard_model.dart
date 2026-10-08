import 'package:equatable/equatable.dart';

/// Type-safe DTO for Recruiter Dashboard Overview
class RecruiterDashboardData extends Equatable {
  final RecruiterStats stats;
  final List<RecruiterJobItem> activeJobs;
  final List<RecruiterCandidateItem> recentApplications;
  final List<RecruiterCandidateItem> topMatches;
  final List<InterviewQueueItem> interviewQueue;
  final String verificationStatus; // 'VERIFIED', 'PENDING', 'UNFILLED'
  final double pipelineProgress; // 0.76 (76%)
  final String cohortName; // 'Stripe India cohort'
  final bool isMock;

  const RecruiterDashboardData({
    required this.stats,
    required this.activeJobs,
    required this.recentApplications,
    required this.topMatches,
    this.interviewQueue = const [],
    required this.verificationStatus,
    this.pipelineProgress = 0.76,
    this.cohortName = 'Stripe India cohort',
    this.isMock = false,
  });

  factory RecruiterDashboardData.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final statsData = json['stats'] is Map<String, dynamic>
        ? json['stats'] as Map<String, dynamic>
        : <String, dynamic>{};

    final jobsList = (json['activeJobs'] as List<dynamic>?)
            ?.map((e) => RecruiterJobItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final appsList = (json['recentApplications'] as List<dynamic>?)
            ?.map((e) => RecruiterCandidateItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final matchesList = (json['topMatches'] as List<dynamic>?)
            ?.map((e) => RecruiterCandidateItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final queueList = (json['interviewQueue'] as List<dynamic>?)
            ?.map((e) => InterviewQueueItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return RecruiterDashboardData(
      stats: RecruiterStats.fromJson(statsData),
      activeJobs: jobsList,
      recentApplications: appsList,
      topMatches: matchesList,
      interviewQueue: queueList.isNotEmpty ? queueList : InterviewQueueItem.defaultList(),
      verificationStatus: json['verificationStatus']?.toString().toUpperCase() ?? 'VERIFIED',
      pipelineProgress: (json['pipelineProgress'] is num) ? (json['pipelineProgress'] as num).toDouble() : 0.76,
      cohortName: json['cohortName']?.toString() ?? 'Stripe India cohort',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
        'stats': stats.toJson(),
        'activeJobs': activeJobs.map((e) => e.toJson()).toList(),
        'recentApplications': recentApplications.map((e) => e.toJson()).toList(),
        'topMatches': topMatches.map((e) => e.toJson()).toList(),
        'interviewQueue': interviewQueue.map((e) => e.toJson()).toList(),
        'verificationStatus': verificationStatus,
        'pipelineProgress': pipelineProgress,
        'cohortName': cohortName,
        'isMock': isMock,
      };

  RecruiterDashboardData copyWith({
    RecruiterStats? stats,
    List<RecruiterJobItem>? activeJobs,
    List<RecruiterCandidateItem>? recentApplications,
    List<RecruiterCandidateItem>? topMatches,
    List<InterviewQueueItem>? interviewQueue,
    String? verificationStatus,
    double? pipelineProgress,
    String? cohortName,
    bool? isMock,
  }) {
    return RecruiterDashboardData(
      stats: stats ?? this.stats,
      activeJobs: activeJobs ?? this.activeJobs,
      recentApplications: recentApplications ?? this.recentApplications,
      topMatches: topMatches ?? this.topMatches,
      interviewQueue: interviewQueue ?? this.interviewQueue,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      pipelineProgress: pipelineProgress ?? this.pipelineProgress,
      cohortName: cohortName ?? this.cohortName,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        activeJobs,
        recentApplications,
        topMatches,
        interviewQueue,
        verificationStatus,
        pipelineProgress,
        cohortName,
        isMock,
      ];
}

class InterviewQueueItem extends Equatable {
  final String time;
  final String candidate;
  final String role;

  const InterviewQueueItem({
    required this.time,
    required this.candidate,
    required this.role,
  });

  factory InterviewQueueItem.fromJson(Map<String, dynamic> json) {
    return InterviewQueueItem(
      time: json['time']?.toString() ?? '10:00 AM',
      candidate: json['candidate']?.toString() ?? 'Candidate',
      role: json['role']?.toString() ?? 'Engineering Drive',
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'candidate': candidate,
        'role': role,
      };

  static List<InterviewQueueItem> defaultList() => const [
        InterviewQueueItem(time: '10:00 AM', candidate: 'Rahul Sharma', role: 'Frontend Engineer'),
        InterviewQueueItem(time: '12:30 PM', candidate: 'Anjali Gupta', role: 'Product Designer'),
        InterviewQueueItem(time: '03:00 PM', candidate: 'Priya Singh', role: 'Full Stack Engineer'),
      ];

  @override
  List<Object?> get props => [time, candidate, role];
}

class RecruiterStats extends Equatable {
  final int activeJobs;
  final int totalApplications;
  final int shortlisted;
  final int interviews;
  final int hires;
  final int matchedCandidates;
  final int avgMatchScore;

  const RecruiterStats({
    this.activeJobs = 0,
    this.totalApplications = 0,
    this.shortlisted = 0,
    this.interviews = 0,
    this.hires = 0,
    this.matchedCandidates = 2410,
    this.avgMatchScore = 91,
  });

  factory RecruiterStats.fromJson(Map<String, dynamic> json) {
    return RecruiterStats(
      activeJobs: json['activeJobs'] is int ? json['activeJobs'] as int : int.tryParse(json['activeJobs']?.toString() ?? '0') ?? 0,
      totalApplications: json['totalApplications'] is int ? json['totalApplications'] as int : int.tryParse(json['totalApplications']?.toString() ?? '0') ?? 0,
      shortlisted: json['shortlisted'] is int ? json['shortlisted'] as int : int.tryParse(json['shortlisted']?.toString() ?? '0') ?? 0,
      interviews: json['interviews'] is int ? json['interviews'] as int : int.tryParse(json['interviews']?.toString() ?? '0') ?? 0,
      hires: json['hires'] is int ? json['hires'] as int : int.tryParse(json['hires']?.toString() ?? '0') ?? 0,
      matchedCandidates: json['matchedCandidates'] is int ? json['matchedCandidates'] as int : int.tryParse(json['matchedCandidates']?.toString() ?? '2410') ?? 2410,
      avgMatchScore: json['avgMatchScore'] is int ? json['avgMatchScore'] as int : int.tryParse(json['avgMatchScore']?.toString() ?? '91') ?? 91,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeJobs': activeJobs,
        'totalApplications': totalApplications,
        'shortlisted': shortlisted,
        'interviews': interviews,
        'hires': hires,
        'matchedCandidates': matchedCandidates,
        'avgMatchScore': avgMatchScore,
      };

  @override
  List<Object?> get props => [
        activeJobs,
        totalApplications,
        shortlisted,
        interviews,
        hires,
        matchedCandidates,
        avgMatchScore,
      ];
}

class RecruiterJobItem extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String jobType; // 'Full-time', 'Internship', 'Remote', 'Contract'
  final String status; // 'ACTIVE', 'PAUSED', 'CLOSED'
  final int applicantsCount;
  final String salary;
  final DateTime postedAt;
  final List<String> requiredSkills;

  const RecruiterJobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.jobType,
    required this.status,
    required this.applicantsCount,
    required this.salary,
    required this.postedAt,
    this.requiredSkills = const [],
  });

  factory RecruiterJobItem.fromJson(Map<String, dynamic> json) {
    return RecruiterJobItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'job_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Untitled Position',
      company: json['company'] is Map ? (json['company']['name']?.toString() ?? 'Corporate Partner') : json['company']?.toString() ?? 'Campus2Corporate',
      location: json['location']?.toString() ?? 'On-site / Hybrid',
      jobType: json['jobType']?.toString() ?? json['type']?.toString() ?? 'Full-time',
      status: (json['status']?.toString() ?? 'ACTIVE').toUpperCase(),
      applicantsCount: json['applicantsCount'] is int ? json['applicantsCount'] as int : (json['applicants'] is List ? (json['applicants'] as List).length : 0),
      salary: json['salary']?.toString() ?? json['stipend']?.toString() ?? 'Competitive / Industry Standard',
      postedAt: json['postedAt'] != null ? DateTime.tryParse(json['postedAt'].toString()) ?? DateTime.now() : DateTime.now(),
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['skillsRequired'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'jobType': jobType,
        'status': status,
        'applicantsCount': applicantsCount,
        'salary': salary,
        'postedAt': postedAt.toIso8601String(),
        'requiredSkills': requiredSkills,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        company,
        location,
        jobType,
        status,
        applicantsCount,
        salary,
        postedAt,
        requiredSkills,
      ];
}

class RecruiterCandidateItem extends Equatable {
  final String id;
  final String name;
  final String email;
  final String college;
  final String branch;
  final String roleApplied;
  final int matchScore; // 0 - 100
  final String stage; // 'applied', 'screening', 'shortlisted', 'interview', 'hired', 'rejected'
  final String? resumeUrl;
  final DateTime appliedAt;

  const RecruiterCandidateItem({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.branch,
    required this.roleApplied,
    required this.matchScore,
    required this.stage,
    this.resumeUrl,
    required this.appliedAt,
  });

  factory RecruiterCandidateItem.fromJson(Map<String, dynamic> json) {
    final studentObj = json['student'] is Map ? json['student'] as Map<String, dynamic> : json;
    final collegeVal = studentObj['college'] is Map ? studentObj['college']['name']?.toString() ?? 'Engineering Institute' : studentObj['college']?.toString() ?? 'IIT / NIT Campus';

    return RecruiterCandidateItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'cand_${DateTime.now().millisecondsSinceEpoch}',
      name: studentObj['name']?.toString() ?? studentObj['fullName']?.toString() ?? 'Candidate',
      email: studentObj['email']?.toString() ?? '',
      college: collegeVal,
      branch: studentObj['branch']?.toString() ?? 'Computer Science',
      roleApplied: json['roleApplied']?.toString() ?? json['projectTitle']?.toString() ?? 'Associate Engineer',
      matchScore: json['matchScore'] is int ? json['matchScore'] as int : int.tryParse(json['matchScore']?.toString() ?? '85') ?? 85,
      stage: (json['stage']?.toString() ?? json['status']?.toString() ?? 'applied').toLowerCase(),
      resumeUrl: studentObj['resumeUrl']?.toString() ?? studentObj['resume']?.toString(),
      appliedAt: json['appliedAt'] != null ? DateTime.tryParse(json['appliedAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'college': college,
        'branch': branch,
        'roleApplied': roleApplied,
        'matchScore': matchScore,
        'stage': stage,
        'resumeUrl': resumeUrl,
        'appliedAt': appliedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        college,
        branch,
        roleApplied,
        matchScore,
        stage,
        resumeUrl,
        appliedAt,
      ];
}
