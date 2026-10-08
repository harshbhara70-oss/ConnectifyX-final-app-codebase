import 'package:equatable/equatable.dart';

/// String sanitization and title-casing extension
extension StringCasingExtension on String {
  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Aggregated graduating batch group derived from the authenticated college's
/// real MongoDB student records (branch + graduating year) via
/// `GET /college/batches` or live aggregation from `GET /college/students`.
class BatchGroupModel extends Equatable {
  final String id;
  final String name;
  final String department;
  final String departmentCode;
  final String batchYear;
  final String description;
  final int memberCount;
  final int activeCount;
  final int eligibleCount;
  final int placedCount;
  final int placementRate;
  final double avgPercentage;
  final int avgSemester;
  final String topSkill;
  final String? coordinator;
  final bool isMock;

  const BatchGroupModel({
    required this.id,
    required this.name,
    required this.department,
    required this.departmentCode,
    required this.batchYear,
    required this.description,
    required this.memberCount,
    required this.activeCount,
    required this.eligibleCount,
    required this.placedCount,
    required this.placementRate,
    required this.avgPercentage,
    required this.avgSemester,
    required this.topSkill,
    this.coordinator,
    this.isMock = false,
  });

  /// Type-safe parser with safe null fallbacks. Never throws on partial data.
  factory BatchGroupModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawName = json['name']?.toString() ?? 'Batch Group';
    final rawDept = json['department']?.toString() ?? json['branch']?.toString() ?? '';
    final rawDeptCode = json['departmentCode']?.toString() ?? deriveCode(rawDept);
    final rawCoord = json['coordinator']?.toString();

    return BatchGroupModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: rawName.toTitleCase(),
      department: rawDept.toTitleCase(),
      departmentCode: rawDeptCode.toUpperCase(),
      batchYear: json['batchYear']?.toString() ?? '2024 - 2025',
      description: json['description']?.toString() ??
          'Cohort of graduating students specialized in engineering and technology.',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
      eligibleCount: (json['eligibleCount'] as num?)?.toInt() ?? 0,
      placedCount: (json['placedCount'] as num?)?.toInt() ?? 0,
      placementRate: (json['placementRate'] as num?)?.toInt() ?? 0,
      avgPercentage: (json['avgPercentage'] as num?)?.toDouble() ?? 0.0,
      avgSemester: (json['avgSemester'] as num?)?.toInt() ?? 6,
      topSkill: (json['topSkill']?.toString() ?? 'Core Engineering').toTitleCase(),
      coordinator: (rawCoord != null && rawCoord.isNotEmpty) ? rawCoord.toTitleCase() : null,
      isMock: isMock,
    );
  }

  static String deriveCode(String dept) {
    final lower = dept.toLowerCase();
    if (lower.contains('comp') || lower.contains('cse')) return 'CSE';
    if (lower.contains('info') || lower.contains('it')) return 'IT';
    if (lower.contains('elect') || lower.contains('ece') || lower.contains('ee')) return 'ECE';
    if (lower.contains('mech')) return 'ME';
    if (lower.contains('civil')) return 'CE';
    if (dept.length >= 3) return dept.substring(0, 3).toUpperCase();
    return 'GEN';
  }

  double get placementFraction {
    if (memberCount <= 0) return 0.0;
    return (placedCount / memberCount).clamp(0.0, 1.0);
  }

  int get activePercentage {
    if (memberCount <= 0) return 0;
    return ((activeCount / memberCount) * 100).round();
  }

  BatchGroupModel copyWith({
    String? id,
    String? name,
    String? department,
    String? departmentCode,
    String? batchYear,
    String? description,
    int? memberCount,
    int? activeCount,
    int? eligibleCount,
    int? placedCount,
    int? placementRate,
    double? avgPercentage,
    int? avgSemester,
    String? topSkill,
    String? coordinator,
    bool? isMock,
  }) {
    return BatchGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      departmentCode: departmentCode ?? this.departmentCode,
      batchYear: batchYear ?? this.batchYear,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      activeCount: activeCount ?? this.activeCount,
      eligibleCount: eligibleCount ?? this.eligibleCount,
      placedCount: placedCount ?? this.placedCount,
      placementRate: placementRate ?? this.placementRate,
      avgPercentage: avgPercentage ?? this.avgPercentage,
      avgSemester: avgSemester ?? this.avgSemester,
      topSkill: topSkill ?? this.topSkill,
      coordinator: coordinator ?? this.coordinator,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        department,
        departmentCode,
        batchYear,
        description,
        memberCount,
        activeCount,
        eligibleCount,
        placedCount,
        placementRate,
        avgPercentage,
        avgSemester,
        topSkill,
        coordinator,
        isMock,
      ];

  /// Default mock seeds for fallback when network or backend endpoint is disconnected.
  static const List<BatchGroupModel> defaultSeeds = [
    BatchGroupModel(
      id: 'bg-cse-2025',
      name: 'Computer Science & Engineering',
      department: 'Computer Science',
      departmentCode: 'CSE',
      batchYear: '2024 - 2025',
      description: 'Final year cohort focusing on Full Stack, DSA, Distributed Systems and Cloud Architecture.',
      memberCount: 420,
      activeCount: 395,
      eligibleCount: 380,
      placedCount: 360,
      placementRate: 86,
      avgPercentage: 84.5,
      avgSemester: 8,
      topSkill: 'Full Stack & DSA',
      coordinator: 'Dr. Ananya Rao',
      isMock: true,
    ),
    BatchGroupModel(
      id: 'bg-ece-2025',
      name: 'Electronics & Communication',
      department: 'Electronics',
      departmentCode: 'ECE',
      batchYear: '2024 - 2025',
      description: 'Graduating batch specialized in VLSI Design, Embedded Systems, IoT, and Signal Processing.',
      memberCount: 310,
      activeCount: 285,
      eligibleCount: 260,
      placedCount: 240,
      placementRate: 77,
      avgPercentage: 78.2,
      avgSemester: 8,
      topSkill: 'Embedded Systems & VLSI',
      coordinator: 'Dr. Ramesh Gupta',
      isMock: true,
    ),
    BatchGroupModel(
      id: 'bg-it-2025',
      name: 'Information Technology',
      department: 'Information Tech',
      departmentCode: 'IT',
      batchYear: '2024 - 2025',
      description: 'High-readiness batch specialized in Cloud Infrastructure, DevOps pipelines, and Cybersecurity.',
      memberCount: 350,
      activeCount: 330,
      eligibleCount: 325,
      placedCount: 310,
      placementRate: 89,
      avgPercentage: 82.8,
      avgSemester: 8,
      topSkill: 'Cloud & DevOps',
      coordinator: 'Dr. Priya Nair',
      isMock: true,
    ),
    BatchGroupModel(
      id: 'bg-me-2025',
      name: 'Mechanical Engineering',
      department: 'Mechanical Engineering',
      departmentCode: 'ME',
      batchYear: '2024 - 2025',
      description: 'Core engineering cohort with certifications in CAD/CAM modeling, Robotics, and Mechatronics.',
      memberCount: 280,
      activeCount: 250,
      eligibleCount: 210,
      placedCount: 180,
      placementRate: 64,
      avgPercentage: 74.6,
      avgSemester: 8,
      topSkill: 'CAD/CAM & Mechatronics',
      coordinator: 'Prof. Vikram Malhotra',
      isMock: true,
    ),
  ];
}

/// A single student member inside a batch group.
class BatchMemberModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String branch;
  final String department;
  final String departmentCode;
  final int semester;
  final String batchYear;
  final double percentage;
  final String status;
  final bool isEligible;
  final List<String> skills;
  final String bio;
  final bool isMock;

  const BatchMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.branch,
    required this.department,
    required this.departmentCode,
    required this.semester,
    required this.batchYear,
    required this.percentage,
    required this.status,
    required this.isEligible,
    required this.skills,
    required this.bio,
    this.isMock = false,
  });

  factory BatchMemberModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final rawName = json['name']?.toString() ?? 'Student';
    final rawBranch = json['branch']?.toString() ?? json['department']?.toString() ?? '';
    final percentage = (json['percentage'] as num?)?.toDouble() ?? 0.0;
    final isEligible = json['isEligible'] as bool? ?? (percentage >= 70.0);

    return BatchMemberModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: rawName.toTitleCase(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '+91 98765 43210',
      branch: rawBranch.toTitleCase(),
      department: (json['department']?.toString() ?? rawBranch).toTitleCase(),
      departmentCode: json['departmentCode'] != null
          ? json['departmentCode'].toString().toUpperCase()
          : BatchGroupModel.deriveCode(rawBranch),
      semester: (json['semester'] as num?)?.toInt() ?? 6,
      batchYear: json['batchYear']?.toString() ?? '2024 - 2025',
      percentage: percentage,
      status: (json['status']?.toString() ?? 'Active').toTitleCase(),
      isEligible: isEligible,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString().toTitleCase())
              .toList() ??
          const ['Problem Solving', 'Data Structures'],
      bio: json['bio']?.toString() ?? '',
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        branch,
        department,
        departmentCode,
        semester,
        batchYear,
        percentage,
        status,
        isEligible,
        skills,
        bio,
        isMock,
      ];
}

/// Header + member payload returned by `GET /college/batches/:batchId`.
class BatchDetailModel extends Equatable {
  final BatchGroupModel batch;
  final List<BatchMemberModel> members;
  final bool isMock;

  const BatchDetailModel({
    required this.batch,
    required this.members,
    this.isMock = false,
  });

  factory BatchDetailModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final batchJson = json['batch'] is Map<String, dynamic>
        ? json['batch'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawMembers = json['students'] is List
        ? json['students'] as List
        : json['members'] is List
            ? json['members'] as List
            : const <dynamic>[];

    return BatchDetailModel(
      batch: BatchGroupModel.fromJson(batchJson, isMock: isMock),
      members: rawMembers
          .whereType<Map<String, dynamic>>()
          .map((e) => BatchMemberModel.fromJson(e, isMock: isMock))
          .toList(),
      isMock: isMock,
    );
  }

  @override
  List<Object?> get props => [batch, members, isMock];
}