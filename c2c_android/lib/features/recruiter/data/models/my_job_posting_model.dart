import 'package:equatable/equatable.dart';

/// Type-safe DTO mirroring `src/pages/recruiter/MyJobPostings.tsx -> JobPostingItem`
/// 1:1 parity with web shape. Includes `isMock` flag for Smart Mock Shell.
class JobPostingItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String jobType;
  final bool isRemote;
  final String location;
  final String salaryMin;
  final String salaryMax;
  final String salaryCurrency;
  final List<String> skills;
  final List<dynamic> departments;
  final String status; // ACTIVE | DRAFT
  final String createdAt;
  final int applicantsCount;
  final int inReviewCount;
  final int hiredCount;
  final bool isMock;

  const JobPostingItem({
    required this.id,
    required this.title,
    this.description = '',
    this.jobType = 'Full-time Permanent',
    this.isRemote = false,
    this.location = '',
    this.salaryMin = '',
    this.salaryMax = '',
    this.salaryCurrency = 'LPA',
    this.skills = const [],
    this.departments = const [],
    this.status = 'ACTIVE',
    this.createdAt = '',
    this.applicantsCount = 0,
    this.inReviewCount = 0,
    this.hiredCount = 0,
    this.isMock = false,
  });

  JobPostingItem copyWith({
    String? id,
    String? title,
    String? description,
    String? jobType,
    bool? isRemote,
    String? location,
    String? salaryMin,
    String? salaryMax,
    String? salaryCurrency,
    List<String>? skills,
    List<dynamic>? departments,
    String? status,
    String? createdAt,
    int? applicantsCount,
    int? inReviewCount,
    int? hiredCount,
    bool? isMock,
  }) {
    return JobPostingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      jobType: jobType ?? this.jobType,
      isRemote: isRemote ?? this.isRemote,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      skills: skills ?? this.skills,
      departments: departments ?? this.departments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      inReviewCount: inReviewCount ?? this.inReviewCount,
      hiredCount: hiredCount ?? this.hiredCount,
      isMock: isMock ?? this.isMock,
    );
  }

  factory JobPostingItem.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawId = json['id'] ?? json['_id'] ?? json['jobId'];
    final String parsedId = (rawId != null && rawId.toString().isNotEmpty)
        ? rawId.toString()
        : 'job_${DateTime.now().millisecondsSinceEpoch}';

    // Salary extraction
    String min = json['salaryMin']?.toString() ?? '';
    String max = json['salaryMax']?.toString() ?? '';
    String currency = json['salaryCurrency']?.toString() ?? 'LPA';
    if ((min.isEmpty || max.isEmpty) && json['salary'] != null) {
      final salaryStr = json['salary'].toString();
      final parts = salaryStr.split('-');
      if (parts.length >= 2) {
        min = parts[0].trim().replaceAll(RegExp(r'[^0-9.]'), '');
        final maxPart = parts[1].trim();
        max = maxPart.replaceAll(RegExp(r'[^0-9.]'), '');
        if (maxPart.toUpperCase().contains('LPA')) currency = 'LPA';
        if (maxPart.toUpperCase().contains('INR') || salaryStr.contains('₹')) currency = 'INR';
      } else {
        min = salaryStr.replaceAll(RegExp(r'[^0-9.]'), '');
        max = min;
        if (salaryStr.contains('₹')) currency = 'INR';
      }
    }

    final rawMode = json['mode']?.toString() ?? '';
    final isRemote = json['isRemote'] == true ||
        json['location']?.toString().toLowerCase() == 'remote' ||
        rawMode.toLowerCase() == 'remote';

    final rawStatus = (json['status']?.toString().toUpperCase() ?? 'ACTIVE');
    final status = rawStatus.contains('DRAFT') ? 'DRAFT' : (rawStatus == 'CLOSED' ? 'CLOSED' : 'ACTIVE');

    return JobPostingItem(
      id: parsedId,
      title: json['title']?.toString() ?? 'Untitled Position',
      description: json['description']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? (rawMode.isNotEmpty ? rawMode : 'Full-time Permanent'),
      isRemote: isRemote,
      location: isRemote ? 'Remote' : (json['location']?.toString() ?? 'Bengaluru, India'),
      salaryMin: min.isNotEmpty ? min : '8',
      salaryMax: max.isNotEmpty ? max : '14',
      salaryCurrency: currency,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['skillsRequired'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (json['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      departments: (json['departments'] as List<dynamic>?) ?? [],
      status: status,
      createdAt: json['createdAt']?.toString() ?? json['postedAt']?.toString() ?? '',
      applicantsCount: json['applicantsCount'] is int
          ? json['applicantsCount'] as int
          : int.tryParse(json['applicantsCount']?.toString() ?? '0') ??
              (json['applicants'] is List ? (json['applicants'] as List).length : 0),
      inReviewCount: json['inReviewCount'] is int
          ? json['inReviewCount'] as int
          : int.tryParse(json['inReviewCount']?.toString() ?? '0') ?? 0,
      hiredCount: json['hiredCount'] is int
          ? json['hiredCount'] as int
          : int.tryParse(json['hiredCount']?.toString() ?? '0') ?? 0,
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'jobType': jobType,
        'isRemote': isRemote,
        'location': location,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'salaryCurrency': salaryCurrency,
        'salary': salaryMin.isNotEmpty ? '$salaryMin - $salaryMax $salaryCurrency' : '',
        'skills': skills,
        'skillsRequired': skills,
        'departments': departments,
        'status': status,
        'createdAt': createdAt,
        'applicantsCount': applicantsCount,
        'inReviewCount': inReviewCount,
        'hiredCount': hiredCount,
        'isMock': isMock,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        jobType,
        isRemote,
        location,
        salaryMin,
        salaryMax,
        salaryCurrency,
        skills,
        departments,
        status,
        createdAt,
        applicantsCount,
        inReviewCount,
        hiredCount,
        isMock,
      ];
}
