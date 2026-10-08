import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Registered Student Application item inside a Campus Drive
/// 1:1 Parity with `registeredStudents` in `PlacementManagementView.tsx`
class DriveRegisteredStudent extends Equatable {
  final String id;
  final String name;
  final String roll;
  final double cgpa;
  final String dept;
  final String status; // 'Shortlisted' | 'Under Review' | 'Rejected'

  const DriveRegisteredStudent({
    required this.id,
    required this.name,
    required this.roll,
    required this.cgpa,
    required this.dept,
    required this.status,
  });

  factory DriveRegisteredStudent.fromJson(Map<String, dynamic> json) {
    return DriveRegisteredStudent(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['studentName']?.toString() ?? 'Candidate',
      roll: json['roll']?.toString() ?? json['rollNumber']?.toString() ?? 'CS2024-001',
      cgpa: (json['cgpa'] as num?)?.toDouble() ?? 8.5,
      dept: json['dept']?.toString() ?? json['department']?.toString() ?? 'Computer Science',
      status: json['status']?.toString() ?? 'Under Review',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'roll': roll,
    'cgpa': cgpa,
    'dept': dept,
    'status': status,
  };

  @override
  List<Object?> get props => [id, name, roll, cgpa, dept, status];
}

/// Production-ready null-safe model for Campus Placement Drives
/// 1:1 Parity with `CampusDriveItem` in `PlacementManagementView.tsx` and MongoDB Atlas Project Schema
class PlacementDriveModel extends Equatable {
  final String id;
  final String companyName;
  final String logoText;
  final Color logoBg;
  final String jobRole;
  final String mode; // 'Virtual' | 'On-Campus' | 'Hybrid'
  final String eligibility; // e.g. 'CGPA > 8.5'
  final int appliedCount;
  final int capacityLimit;
  final String deadlineDate; // e.g. '24 Oct, 2023'
  final bool isUrgentDeadline;
  final String stageStatus; // 'INTERVIEWING' | 'REGISTRATION OPEN' | 'TESTING STAGE' | 'OFFERS RELEASED' | 'CLOSED'
  final String packageLPA; // e.g. '22.0 LPA'
  final String location; // e.g. 'Bengaluru / Remote'
  final String description;
  final List<DriveRegisteredStudent> registeredStudents;
  final bool isMock;

  // Legacy / Extended fields for backward compatibility
  final String companyId;
  final String companyLogoUrl;
  final String tier;
  final int shortlistedCount;
  final int interviewingCount;
  final int offeredCount;
  final int eligibleCount;
  final int openings;
  final String duration;
  final int stipend;
  final DateTime? applicationDeadline;
  final List<String> requiredSkills;
  final String minCgpa;
  final String recruiterContact;
  final String recruiterEmail;
  final double rating;

  const PlacementDriveModel({
    required this.id,
    required this.companyName,
    this.logoText = '',
    this.logoBg = const Color(0xFF4F46E5),
    required this.jobRole,
    this.mode = 'Virtual',
    this.eligibility = 'CGPA > 8.0',
    this.appliedCount = 0,
    this.capacityLimit = 250,
    this.deadlineDate = 'Active Cycle',
    this.isUrgentDeadline = false,
    this.stageStatus = 'REGISTRATION OPEN',
    this.packageLPA = '18.0 LPA',
    this.location = 'Bengaluru / Remote',
    this.description = '',
    this.registeredStudents = const [],
    this.isMock = false,
    // Extended fields
    this.companyId = 'comp_1',
    this.companyLogoUrl = '',
    this.tier = 'Gold Partner',
    this.shortlistedCount = 0,
    this.interviewingCount = 0,
    this.offeredCount = 0,
    this.eligibleCount = 0,
    this.openings = 5,
    this.duration = 'Full Time',
    this.stipend = 0,
    this.applicationDeadline,
    this.requiredSkills = const ['Core Tech', 'Problem Solving', 'Git'],
    this.minCgpa = '7.5',
    this.recruiterContact = 'Talent Acquisition Team',
    this.recruiterEmail = 'careers@corporate.com',
    this.rating = 4.8,
  });

  /// Display name showing explicit asterisk `*` when `isMock == true`
  String get displayCompanyName => isMock ? '$companyName*' : companyName;
  String get displayJobRole => isMock ? '$jobRole*' : jobRole;

  // Compatibility Getters
  String get roleTitle => jobRole;
  String get ctcPackage => packageLPA;
  String get locationType => mode;
  String get status => stageStatus;
  String get driveDate => deadlineDate;

  /// Generate 2-letter initials for logo badge
  String get displayLogoLetters {
    if (logoText.isNotEmpty) return logoText;
    final parts = companyName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (companyName.isNotEmpty) {
      return companyName.substring(0, companyName.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'CP';
  }

  Color get statusColor {
    switch (stageStatus.toUpperCase()) {
      case 'INTERVIEWING':
        return const Color(0xFF10B981);
      case 'REGISTRATION OPEN':
      case 'LIVE':
      case 'OPEN':
        return const Color(0xFF2563EB);
      case 'TESTING STAGE':
      case 'UPCOMING':
        return const Color(0xFFD97706);
      case 'OFFERS RELEASED':
        return const Color(0xFF7C3AED);
      case 'CLOSED':
      case 'COMPLETED':
      default:
        return AppColors.textSecondary;
    }
  }

  Color get statusBgColor {
    switch (stageStatus.toUpperCase()) {
      case 'INTERVIEWING':
        return const Color(0xFFD1FAE5);
      case 'REGISTRATION OPEN':
      case 'LIVE':
      case 'OPEN':
        return const Color(0xFFDBEAFE);
      case 'TESTING STAGE':
      case 'UPCOMING':
        return const Color(0xFFFEF3C7);
      case 'OFFERS RELEASED':
        return const Color(0xFFF3E8FF);
      case 'CLOSED':
      case 'COMPLETED':
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  factory PlacementDriveModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    // Parse populated company object if available
    final companyData = json['company'] is Map<String, dynamic>
        ? json['company'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Parse populated recruiter object if available
    final recruiterData = json['recruiter'] is Map<String, dynamic>
        ? json['recruiter'] as Map<String, dynamic>
        : <String, dynamic>{};

    final titleStr = json['title']?.toString() ?? 'Campus Hiring Drive';
    String compName = json['companyName']?.toString() ?? companyData['name']?.toString() ?? '';
    String role = json['jobRole']?.toString() ?? '';

    if (compName.isEmpty && titleStr.contains('-')) {
      final parts = titleStr.split('-');
      compName = parts[0].trim();
      role = parts.sublist(1).join('-').trim();
    } else if (compName.isEmpty) {
      compName = titleStr;
    }
    if (role.isEmpty) {
      role = 'Software Engineer';
    }

    final rawSkills = json['requiredSkills'];
    List<String> skillsList = [];
    if (rawSkills is List) {
      skillsList = rawSkills.map((e) => e.toString()).toList();
    } else if (rawSkills is String) {
      skillsList = rawSkills.split(',').map((e) => e.trim()).toList();
    }
    if (skillsList.isEmpty) {
      skillsList = ['Core Tech', 'Problem Solving', 'Git'];
    }

    DateTime? deadlineDate;
    if (json['applicationDeadline'] != null) {
      try {
        deadlineDate = DateTime.parse(json['applicationDeadline'].toString());
      } catch (_) {}
    }

    final rawDesc = json['description']?.toString() ?? '';
    String packageStr = json['packageLPA']?.toString() ?? json['ctcPackage']?.toString() ?? '';
    if (packageStr.isEmpty) {
      final match = RegExp(r'(\d+(\.\d+)?)\s*LPA', caseSensitive: false).firstMatch(rawDesc);
      if (match != null) {
        packageStr = '${match.group(1)} LPA';
      } else {
        final stipendNum = (json['stipend'] as num?)?.toInt() ?? 0;
        if (stipendNum > 0) {
          packageStr = '${((stipendNum * 12) / 100000).toStringAsFixed(1)} LPA';
        } else {
          packageStr = '18.5 LPA';
        }
      }
    }

    final rawStatus = json['stageStatus']?.toString() ?? json['status']?.toString() ?? 'REGISTRATION OPEN';
    String stage = rawStatus.toUpperCase();
    if (stage == 'OPEN' || stage == 'LIVE') stage = 'REGISTRATION OPEN';
    if (stage == 'UPCOMING') stage = 'TESTING STAGE';
    if (stage == 'COMPLETED') stage = 'OFFERS RELEASED';

    // Parse registered students
    List<DriveRegisteredStudent> students = [];
    if (json['registeredStudents'] is List) {
      students = (json['registeredStudents'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => DriveRegisteredStudent.fromJson(e))
          .toList();
    }

    // Color mapper
    Color colorFromText(String? colorStr) {
      if (colorStr == null || colorStr.isEmpty) return const Color(0xFF4F46E5);
      if (colorStr.contains('0EA5E9')) return const Color(0xFF0EA5E9);
      if (colorStr.contains('9333EA')) return const Color(0xFF9333EA);
      if (colorStr.contains('2563EB')) return const Color(0xFF2563EB);
      if (colorStr.contains('10B981')) return const Color(0xFF10B981);
      if (colorStr.contains('F59E0B')) return const Color(0xFFF59E0B);
      return const Color(0xFF4F46E5);
    }

    return PlacementDriveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'd_${DateTime.now().millisecondsSinceEpoch}',
      companyName: compName,
      logoText: json['logoText']?.toString() ?? '',
      logoBg: colorFromText(json['logoBg']?.toString()),
      jobRole: role,
      mode: json['mode']?.toString() ?? json['locationType']?.toString() ?? 'Virtual',
      eligibility: json['eligibility']?.toString() ?? 'CGPA > 8.0',
      appliedCount: (json['appliedCount'] as num?)?.toInt() ?? students.length,
      capacityLimit: (json['capacityLimit'] as num?)?.toInt() ?? 250,
      deadlineDate: json['deadlineDate']?.toString() ??
          (deadlineDate != null ? '${deadlineDate.day} ${_monthName(deadlineDate.month)}, ${deadlineDate.year}' : '30 Oct, 2024'),
      isUrgentDeadline: json['isUrgentDeadline'] == true,
      stageStatus: stage,
      packageLPA: packageStr,
      location: json['location']?.toString() ?? 'Bengaluru / Remote',
      description: rawDesc.isNotEmpty ? rawDesc : 'Candidate technical evaluation and campus interview recruitment drive.',
      registeredStudents: students,
      isMock: isMock,
      // Extended fields
      companyId: companyData['_id']?.toString() ?? json['companyId']?.toString() ?? 'comp_1',
      companyLogoUrl: companyData['logo']?.toString() ?? json['companyLogoUrl']?.toString() ?? '',
      tier: json['tier']?.toString() ?? 'Gold Partner',
      shortlistedCount: (json['shortlistedCount'] as num?)?.toInt() ?? students.where((s) => s.status == 'Shortlisted').length,
      interviewingCount: (json['interviewingCount'] as num?)?.toInt() ?? 6,
      offeredCount: (json['offeredCount'] as num?)?.toInt() ?? 3,
      eligibleCount: (json['eligibleCount'] as num?)?.toInt() ?? 120,
      openings: (json['openings'] as num?)?.toInt() ?? 5,
      duration: json['duration']?.toString() ?? 'Full Time',
      stipend: (json['stipend'] as num?)?.toInt() ?? 50000,
      applicationDeadline: deadlineDate,
      requiredSkills: skillsList,
      minCgpa: json['minCgpa']?.toString() ?? '7.5',
      recruiterContact: recruiterData['name']?.toString() ?? json['recruiterContact']?.toString() ?? 'Talent Acquisition Team',
      recruiterEmail: recruiterData['email']?.toString() ?? json['recruiterEmail']?.toString() ?? 'careers@corporate.com',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyName': companyName,
    'logoText': logoText,
    'jobRole': jobRole,
    'mode': mode,
    'eligibility': eligibility,
    'appliedCount': appliedCount,
    'capacityLimit': capacityLimit,
    'deadlineDate': deadlineDate,
    'isUrgentDeadline': isUrgentDeadline,
    'stageStatus': stageStatus,
    'packageLPA': packageLPA,
    'location': location,
    'description': description,
    'registeredStudents': registeredStudents.map((s) => s.toJson()).toList(),
    'isMock': isMock,
  };

  PlacementDriveModel copyWith({
    String? id,
    String? companyName,
    String? logoText,
    Color? logoBg,
    String? jobRole,
    String? mode,
    String? eligibility,
    int? appliedCount,
    int? capacityLimit,
    String? deadlineDate,
    bool? isUrgentDeadline,
    String? stageStatus,
    String? packageLPA,
    String? location,
    String? description,
    List<DriveRegisteredStudent>? registeredStudents,
    bool? isMock,
  }) {
    return PlacementDriveModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      logoText: logoText ?? this.logoText,
      logoBg: logoBg ?? this.logoBg,
      jobRole: jobRole ?? this.jobRole,
      mode: mode ?? this.mode,
      eligibility: eligibility ?? this.eligibility,
      appliedCount: appliedCount ?? this.appliedCount,
      capacityLimit: capacityLimit ?? this.capacityLimit,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      isUrgentDeadline: isUrgentDeadline ?? this.isUrgentDeadline,
      stageStatus: stageStatus ?? this.stageStatus,
      packageLPA: packageLPA ?? this.packageLPA,
      location: location ?? this.location,
      description: description ?? this.description,
      registeredStudents: registeredStudents ?? this.registeredStudents,
      isMock: isMock ?? this.isMock,
    );
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (month >= 1 && month <= 12) ? months[month - 1] : 'Oct';
  }

  @override
  List<Object?> get props => [
    id,
    companyName,
    jobRole,
    mode,
    eligibility,
    appliedCount,
    capacityLimit,
    deadlineDate,
    stageStatus,
    packageLPA,
    location,
    isMock,
  ];

  // ---------------------------------------------------------------------------
  // 1:1 Web INITIAL_DRIVES Mock Seeds
  // ---------------------------------------------------------------------------
  static const List<PlacementDriveModel> mockDrives = [
    PlacementDriveModel(
      id: 'drive-1',
      companyName: 'Nexus Systems',
      logoText: 'NS',
      logoBg: Color(0xFF4F46E5),
      jobRole: 'Senior Software Engineer',
      mode: 'Virtual',
      eligibility: 'CGPA > 8.5',
      appliedCount: 156,
      capacityLimit: 240,
      deadlineDate: '24 Oct, 2024',
      isUrgentDeadline: true,
      stageStatus: 'INTERVIEWING',
      packageLPA: '22.0 LPA',
      location: 'Bengaluru / Remote',
      description: 'Architecting cloud-native distributed backend microservices and React dashboards.',
      isMock: true,
      registeredStudents: [
        DriveRegisteredStudent(id: 's-1', name: 'Arjun Mehta', roll: 'CS2024-042', cgpa: 8.92, dept: 'Computer Science', status: 'Shortlisted'),
        DriveRegisteredStudent(id: 's-2', name: 'Priya Sharma', roll: 'CS2024-099', cgpa: 9.60, dept: 'Computer Science', status: 'Shortlisted'),
        DriveRegisteredStudent(id: 's-3', name: 'Kavya Nair', roll: 'CS2025-077', cgpa: 8.75, dept: 'Computer Science', status: 'Under Review'),
      ],
    ),
    PlacementDriveModel(
      id: 'drive-2',
      companyName: 'FinStrat Global',
      logoText: 'FG',
      logoBg: Color(0xFF0EA5E9),
      jobRole: 'Investment Analyst',
      mode: 'On-Campus',
      eligibility: 'Finance Major',
      appliedCount: 42,
      capacityLimit: 85,
      deadlineDate: '28 Oct, 2024',
      isUrgentDeadline: false,
      stageStatus: 'REGISTRATION OPEN',
      packageLPA: '16.5 LPA',
      location: 'Mumbai',
      description: 'Quantitative risk modeling, corporate valuations, and capital markets analytics.',
      isMock: true,
      registeredStudents: [
        DriveRegisteredStudent(id: 's-4', name: 'Sarah Johnson', roll: 'EC2024-118', cgpa: 7.45, dept: 'Electronics', status: 'Under Review'),
        DriveRegisteredStudent(id: 's-5', name: 'Rahul Verma', roll: 'CE2025-015', cgpa: 7.20, dept: 'Civil', status: 'Under Review'),
      ],
    ),
    PlacementDriveModel(
      id: 'drive-3',
      companyName: 'CloudScale Solutions',
      logoText: 'CS',
      logoBg: Color(0xFF9333EA),
      jobRole: 'Cloud Architect Intern',
      mode: 'Virtual',
      eligibility: 'Any Tech',
      appliedCount: 312,
      capacityLimit: 500,
      deadlineDate: '30 Oct, 2024',
      isUrgentDeadline: false,
      stageStatus: 'TESTING STAGE',
      packageLPA: '12.0 LPA',
      location: 'Hyderabad / Remote',
      description: 'AWS Infrastructure provisioning, Kubernetes orchestration, and CI/CD pipelines.',
      isMock: true,
      registeredStudents: [
        DriveRegisteredStudent(id: 's-6', name: 'Ananya Roy', roll: 'ME2024-089', cgpa: 8.15, dept: 'Mechanical', status: 'Shortlisted'),
        DriveRegisteredStudent(id: 's-7', name: 'Dev Patel', roll: 'EC2026-033', cgpa: 6.90, dept: 'Electronics', status: 'Under Review'),
      ],
    ),
    PlacementDriveModel(
      id: 'drive-4',
      companyName: 'Stripe APAC',
      logoText: 'ST',
      logoBg: Color(0xFF2563EB),
      jobRole: 'Full Stack Engineer',
      mode: 'Virtual',
      eligibility: 'CGPA > 8.0',
      appliedCount: 198,
      capacityLimit: 300,
      deadlineDate: '05 Nov, 2024',
      isUrgentDeadline: false,
      stageStatus: 'REGISTRATION OPEN',
      packageLPA: '28.5 LPA',
      location: 'Singapore / Remote',
      description: 'Building next-generation global payment orchestration rails and developer APIs.',
      isMock: true,
      registeredStudents: [
        DriveRegisteredStudent(id: 's-8', name: 'Vikram Singh', roll: 'CS2024-001', cgpa: 8.52, dept: 'Computer Science', status: 'Under Review'),
      ],
    ),
    PlacementDriveModel(
      id: 'drive-5',
      companyName: 'Aether Tech Labs',
      logoText: 'AT',
      logoBg: Color(0xFF10B981),
      jobRole: 'AI / ML Research Associate',
      mode: 'On-Campus',
      eligibility: 'CGPA > 8.5',
      appliedCount: 88,
      capacityLimit: 100,
      deadlineDate: '12 Nov, 2024',
      isUrgentDeadline: false,
      stageStatus: 'OFFERS RELEASED',
      packageLPA: '24.0 LPA',
      location: 'Bengaluru',
      description: 'Large language model fine-tuning, computer vision pipelines, and edge inference.',
      isMock: true,
      registeredStudents: [
        DriveRegisteredStudent(id: 's-9', name: 'Neha Gupta', roll: 'CS2024-055', cgpa: 9.40, dept: 'Computer Science', status: 'Shortlisted'),
      ],
    ),
  ];
}
