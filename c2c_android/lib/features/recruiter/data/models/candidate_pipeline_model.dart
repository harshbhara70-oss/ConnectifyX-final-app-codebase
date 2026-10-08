import 'package:equatable/equatable.dart';

/// DTO mirroring `src/pages/recruiter/PipelineManagement.tsx -> CandidateCard`
class CandidatePipelineItem extends Equatable {
  final String id;
  final String name;
  final String role;
  final String stage; // shortlisted | contacted | interview | offer
  final String score;
  final String source;
  final bool isMock;

  const CandidatePipelineItem({
    required this.id,
    required this.name,
    required this.role,
    this.stage = 'shortlisted',
    this.score = '90',
    this.source = 'Referral',
    this.isMock = false,
  });

  CandidatePipelineItem copyWith({
    String? id,
    String? name,
    String? role,
    String? stage,
    String? score,
    String? source,
    bool? isMock,
  }) {
    return CandidatePipelineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      stage: stage ?? this.stage,
      score: score ?? this.score,
      source: source ?? this.source,
      isMock: isMock ?? this.isMock,
    );
  }

  factory CandidatePipelineItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawId = json['id'] ?? json['_id'] ?? json['candidateId'];
    final String parsedId = (rawId != null && rawId.toString().isNotEmpty)
        ? rawId.toString()
        : 'cand_${DateTime.now().millisecondsSinceEpoch}';

    final rawStage = (json['stage'] ?? json['status'] ?? 'shortlisted').toString().toLowerCase();
    String stage = 'shortlisted';
    if (rawStage.contains('contact')) {
      stage = 'contacted';
    } else if (rawStage.contains('interview')) {
      stage = 'interview';
    } else if (rawStage.contains('offer') || rawStage.contains('select')) {
      stage = 'offer';
    } else {
      stage = 'shortlisted';
    }

    final rawScore = json['score'] ?? json['matchScore'] ?? '90';

    return CandidatePipelineItem(
      id: parsedId,
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Candidate',
      role: json['role']?.toString() ?? json['jobTitle']?.toString() ?? 'Software Engineer',
      stage: stage,
      score: rawScore.toString().replaceAll(RegExp(r'[^0-9]'), ''),
      source: json['source']?.toString() ?? 'Referral',
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'stage': stage,
        'score': score,
        'source': source,
        'isMock': isMock,
      };

  @override
  List<Object?> get props => [id, name, role, stage, score, source, isMock];
}
