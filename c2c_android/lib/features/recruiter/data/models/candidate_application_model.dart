import 'package:equatable/equatable.dart';

/// Type-safe DTO mirroring `src/pages/recruiter/ApplicationsReports.tsx -> CandidateAppItem`
class CandidateAppItem extends Equatable {
  final String id;
  final String? jobId;
  final String? jobTitle;
  final String name;
  final String role;
  final String stage; // eligible | shortlisted | contacted | interview | offer
  final String score;
  final String appliedDate;
  final String source;
  final String email;
  final String college;
  final String branch;
  final bool isMock;

  const CandidateAppItem({
    required this.id,
    this.jobId,
    this.jobTitle,
    required this.name,
    required this.role,
    this.stage = 'eligible',
    this.score = '90',
    this.appliedDate = 'Recently',
    this.source = 'Direct Application',
    this.email = '',
    this.college = 'IIT / NIT Campus',
    this.branch = 'Computer Science & Engineering',
    this.isMock = false,
  });

  CandidateAppItem copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? name,
    String? role,
    String? stage,
    String? score,
    String? appliedDate,
    String? source,
    String? email,
    String? college,
    String? branch,
    bool? isMock,
  }) {
    return CandidateAppItem(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      name: name ?? this.name,
      role: role ?? this.role,
      stage: stage ?? this.stage,
      score: score ?? this.score,
      appliedDate: appliedDate ?? this.appliedDate,
      source: source ?? this.source,
      email: email ?? this.email,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      isMock: isMock ?? this.isMock,
    );
  }

  factory CandidateAppItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawId = json['id'] ?? json['_id'] ?? json['candidateId'];
    final String parsedId = (rawId != null && rawId.toString().isNotEmpty)
        ? rawId.toString()
        : 'cand_${DateTime.now().millisecondsSinceEpoch}';

    final rawStage = (json['stage'] ?? json['status'] ?? 'eligible').toString().toLowerCase();
    String stage = 'eligible';
    if (rawStage.contains('shortlist')) {
      stage = 'shortlisted';
    } else if (rawStage.contains('interview')) {
      stage = 'interview';
    } else if (rawStage.contains('offer') || rawStage.contains('select')) {
      stage = 'offer';
    } else if (rawStage.contains('contact') || rawStage.contains('review')) {
      stage = 'contacted';
    } else {
      stage = 'eligible';
    }

    final rawScore = json['score'] ?? json['matchScore'] ?? '92';

    return CandidateAppItem(
      id: parsedId,
      jobId: json['jobId']?.toString(),
      jobTitle: json['jobTitle']?.toString() ?? json['role']?.toString() ?? 'Associate Software Engineer',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Student Candidate',
      role: json['role']?.toString() ?? json['jobTitle']?.toString() ?? 'Associate Software Engineer',
      stage: stage,
      score: rawScore.toString().replaceAll(RegExp(r'[^0-9]'), ''),
      appliedDate: json['appliedDate']?.toString() ?? json['appliedAt']?.toString() ?? 'Recently',
      source: json['source']?.toString() ?? 'Direct Application',
      email: json['email']?.toString() ?? '',
      college: json['college']?.toString() ?? 'Indian Institute of Technology',
      branch: json['branch']?.toString() ?? 'Computer Science',
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'name': name,
        'role': role,
        'stage': stage,
        'score': score,
        'appliedDate': appliedDate,
        'source': source,
        'email': email,
        'college': college,
        'branch': branch,
        'isMock': isMock,
      };

  @override
  List<Object?> get props => [
        id,
        jobId,
        jobTitle,
        name,
        role,
        stage,
        score,
        appliedDate,
        source,
        email,
        college,
        branch,
        isMock,
      ];
}
