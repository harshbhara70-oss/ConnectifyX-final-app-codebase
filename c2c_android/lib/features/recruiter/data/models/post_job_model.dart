import 'package:equatable/equatable.dart';

/// DTO for Job Posting & Draft Submission
class PostJobRequest extends Equatable {
  final String title;
  final String description;
  final String jobType;
  final bool isRemote;
  final String location;
  final String salaryMin;
  final String salaryMax;
  final String salaryCurrency;
  final List<String> skills;
  final List<EligibilityRuleItem> eligibilityRules;
  final String status; // 'ACTIVE' or 'DRAFT'
  final bool isMock;

  const PostJobRequest({
    required this.title,
    required this.description,
    this.jobType = 'Full-time Permanent',
    this.isRemote = false,
    this.location = '',
    required this.salaryMin,
    required this.salaryMax,
    this.salaryCurrency = 'LPA',
    this.skills = const [],
    this.eligibilityRules = const [],
    this.status = 'ACTIVE',
    this.isMock = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'jobType': jobType,
        'isRemote': isRemote,
        'location': isRemote ? 'Remote' : location,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'salaryCurrency': salaryCurrency,
        'salary': '$salaryMin - $salaryMax $salaryCurrency',
        'skillsRequired': skills,
        'eligibilityRules': eligibilityRules.map((e) => e.toJson()).toList(),
        'status': status,
      };

  @override
  List<Object?> get props => [
        title,
        description,
        jobType,
        isRemote,
        location,
        salaryMin,
        salaryMax,
        salaryCurrency,
        skills,
        eligibilityRules,
        status,
        isMock,
      ];
}

class EligibilityRuleItem extends Equatable {
  final String id;
  final String institutionTier;
  final String department;
  final String requirement;

  const EligibilityRuleItem({
    required this.id,
    this.institutionTier = '',
    this.department = '',
    this.requirement = '',
  });

  EligibilityRuleItem copyWith({
    String? id,
    String? institutionTier,
    String? department,
    String? requirement,
  }) {
    return EligibilityRuleItem(
      id: id ?? this.id,
      institutionTier: institutionTier ?? this.institutionTier,
      department: department ?? this.department,
      requirement: requirement ?? this.requirement,
    );
  }

  factory EligibilityRuleItem.fromJson(Map<String, dynamic> json) => EligibilityRuleItem(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        institutionTier: json['institution']?.toString() ?? json['institutionTier']?.toString() ?? '',
        department: json['department']?.toString() ?? '',
        requirement: json['requirement']?.toString() ?? json['minScore']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution': institutionTier,
        'department': department,
        'requirement': requirement,
      };

  @override
  List<Object?> get props => [id, institutionTier, department, requirement];
}
