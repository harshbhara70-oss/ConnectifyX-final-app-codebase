import 'package:equatable/equatable.dart';

/// Student model for College Module with 1:1 parity with web `StudentRecordItem`
/// and MongoDB `Student` schema.
///
/// Features strict `isMock` boolean handling:
/// - Real MongoDB Atlas data sets `isMock = false`.
/// - Fallback seeds / unintegrated mock flows set `isMock = true` and show explicit `*`.
class CollegeStudentModel extends Equatable {
  final String id;
  final String name;
  final String rollNumber;
  final String avatar;
  final String department;
  final String graduationYear;
  final int? semester;
  final double percentage;
  final double cgpa;
  final int projectsCount;
  final String projectsTag;
  final String projectsTagType; // 'success' | 'neutral' | 'danger'
  final int readinessScore;
  final String placementStatus; // 'PLACED' | 'UNPLACED' | 'PENDING'
  final String? hiredBy;
  final List<String> hiredLogos;
  final List<String> skills;
  final String email;
  final String phone;
  final String bio;
  final String location;
  final String status; // 'Active' | 'Inactive'
  final DateTime? createdAt;
  final bool isMock;

  const CollegeStudentModel({
    required this.id,
    required this.name,
    this.rollNumber = '',
    this.avatar = '',
    this.department = 'Computer Science',
    this.graduationYear = '2024 (Current)',
    this.semester,
    this.percentage = 0.0,
    this.cgpa = 0.0,
    this.projectsCount = 0,
    this.projectsTag = 'Avg',
    this.projectsTagType = 'neutral',
    this.readinessScore = 0,
    this.placementStatus = 'UNPLACED',
    this.hiredBy,
    this.hiredLogos = const [],
    this.skills = const [],
    this.email = '',
    this.phone = '',
    this.bio = '',
    this.location = '',
    this.status = 'Active',
    this.createdAt,
    this.isMock = false,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPlaced => placementStatus.toUpperCase() == 'PLACED';
  bool get isUnplaced => placementStatus.toUpperCase() == 'UNPLACED';
  bool get isPending => placementStatus.toUpperCase() == 'PENDING';
  String get branch => department;
  int? get atsScore => readinessScore;

  /// Formatted roll number for display
  String get displayRollNumber {
    if (rollNumber.isNotEmpty) {
      return rollNumber.startsWith('Roll:') ? rollNumber : 'Roll: $rollNumber';
    }
    if (id.isNotEmpty) {
      final shortId = id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase();
      return 'Roll: STU-$shortId';
    }
    return 'Roll: CS2024-001';
  }

  /// Formatted name with mock asterisk if `isMock`
  String get displayName => isMock ? '$name*' : name;

  factory CollegeStudentModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    final perc = (json['percentage'] as num?)?.toDouble() ?? 0.0;
    final parsedCgpa = (json['cgpa'] as num?)?.toDouble() ?? (perc > 0 ? (perc / 10.0) : 7.5);
    final calculatedReadiness = (json['readinessScore'] as num?)?.toInt() ??
        (parsedCgpa > 0 ? (parsedCgpa * 10).clamp(10, 99).round() : 75);

    // Derived project count & tag if not in backend document
    final projCount = (json['projectsCount'] as num?)?.toInt() ??
        ((json['assignmentSubmissions'] as List?)?.length ??
            (perc >= 8.5 ? 12 : perc >= 7.0 ? 7 : 4));

    final projTag = json['projectsTag']?.toString() ??
        (projCount >= 10
            ? '+2 recent'
            : projCount >= 6
                ? 'Avg'
                : 'Critical');

    final projTagType = json['projectsTagType']?.toString() ??
        (projCount >= 10
            ? 'success'
            : projCount >= 6
                ? 'neutral'
                : 'danger');

    final rawStatus = json['placementStatus']?.toString() ??
        (perc >= 8.5 ? 'PLACED' : perc >= 7.0 ? 'PENDING' : 'UNPLACED');

    final dept = json['department']?.toString() ??
        json['branch']?.toString() ??
        'Computer Science';

    final gradYear = json['graduationYear']?.toString() ??
        (json['semester'] != null
            ? (json['semester'] as num) >= 7
                ? '2024 (Current)'
                : (json['semester'] as num) >= 5
                    ? '2025'
                    : '2026'
            : '2024 (Current)');

    return CollegeStudentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Candidate',
      rollNumber: json['rollNumber']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      department: dept.isEmpty ? 'Computer Science' : dept,
      graduationYear: gradYear,
      semester: (json['semester'] as num?)?.toInt(),
      percentage: perc,
      cgpa: parsedCgpa,
      projectsCount: projCount,
      projectsTag: projTag,
      projectsTagType: projTagType,
      readinessScore: calculatedReadiness,
      placementStatus: rawStatus.toUpperCase(),
      hiredBy: json['hiredBy']?.toString(),
      hiredLogos: (json['hiredLogos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (rawStatus.toUpperCase() == 'PLACED' ? const ['G', 'M'] : const []),
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const ['React.js', 'Node.js', 'Python'],
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      isMock: json['isMock'] == true || isMock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'avatar': avatar,
      'department': department,
      'branch': department,
      'graduationYear': graduationYear,
      'semester': semester,
      'percentage': percentage,
      'cgpa': cgpa,
      'projectsCount': projectsCount,
      'projectsTag': projectsTag,
      'projectsTagType': projectsTagType,
      'readinessScore': readinessScore,
      'placementStatus': placementStatus,
      'hiredBy': hiredBy,
      'hiredLogos': hiredLogos,
      'skills': skills,
      'email': email,
      'phone': phone,
      'bio': bio,
      'location': location,
      'status': status,
      'isMock': isMock,
    };
  }

  CollegeStudentModel copyWith({
    String? id,
    String? name,
    String? rollNumber,
    String? avatar,
    String? department,
    String? graduationYear,
    int? semester,
    double? percentage,
    double? cgpa,
    int? projectsCount,
    String? projectsTag,
    String? projectsTagType,
    int? readinessScore,
    String? placementStatus,
    String? hiredBy,
    List<String>? hiredLogos,
    List<String>? skills,
    String? email,
    String? phone,
    String? bio,
    String? location,
    String? status,
    DateTime? createdAt,
    bool? isMock,
  }) {
    return CollegeStudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      avatar: avatar ?? this.avatar,
      department: department ?? this.department,
      graduationYear: graduationYear ?? this.graduationYear,
      semester: semester ?? this.semester,
      percentage: percentage ?? this.percentage,
      cgpa: cgpa ?? this.cgpa,
      projectsCount: projectsCount ?? this.projectsCount,
      projectsTag: projectsTag ?? this.projectsTag,
      projectsTagType: projectsTagType ?? this.projectsTagType,
      readinessScore: readinessScore ?? this.readinessScore,
      placementStatus: placementStatus ?? this.placementStatus,
      hiredBy: hiredBy ?? this.hiredBy,
      hiredLogos: hiredLogos ?? this.hiredLogos,
      skills: skills ?? this.skills,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        rollNumber,
        avatar,
        department,
        graduationYear,
        semester,
        percentage,
        cgpa,
        projectsCount,
        projectsTag,
        projectsTagType,
        readinessScore,
        placementStatus,
        hiredBy,
        hiredLogos,
        skills,
        email,
        phone,
        bio,
        location,
        status,
        createdAt,
        isMock,
      ];

  /// Rich seed dataset matching web `INITIAL_STUDENT_RECORDS` in `StudentRecordsView.tsx`.
  static List<CollegeStudentModel> get mockSeeds => [
        const CollegeStudentModel(
          id: 'stu-101',
          name: 'Arjun Mehta',
          rollNumber: 'Roll: CS2024-042',
          avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
          department: 'Computer Science',
          graduationYear: '2024 (Current)',
          cgpa: 8.92,
          percentage: 89.2,
          projectsCount: 12,
          projectsTag: '+2 recent',
          projectsTagType: 'success',
          readinessScore: 94,
          placementStatus: 'UNPLACED',
          skills: ['React.js', 'Node.js', 'Python', 'TypeScript', 'SQL', 'Docker', 'AWS'],
          email: 'arjun.mehta@college.edu',
          phone: '+91 98765 43210',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-102',
          name: 'Sarah Johnson',
          rollNumber: 'Roll: EC2024-118',
          avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
          department: 'Electronics',
          graduationYear: '2024 (Current)',
          cgpa: 7.45,
          percentage: 74.5,
          projectsCount: 8,
          projectsTag: 'Avg',
          projectsTagType: 'neutral',
          readinessScore: 68,
          placementStatus: 'PLACED',
          hiredBy: 'Google',
          hiredLogos: ['G', 'M'],
          skills: ['Embedded C', 'Python', 'IoT', 'MATLAB', 'Signal Proc'],
          email: 'sarah.j@college.edu',
          phone: '+91 98123 45678',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-103',
          name: 'Vikram Singh',
          rollNumber: 'Roll: CS2024-001',
          avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
          department: 'Computer Science',
          graduationYear: '2024 (Current)',
          cgpa: 5.82,
          percentage: 58.2,
          projectsCount: 4,
          projectsTag: 'Critical',
          projectsTagType: 'danger',
          readinessScore: 42,
          placementStatus: 'UNPLACED',
          skills: ['C++', 'HTML/CSS', 'Java', 'SQL'],
          email: 'vikram.singh@college.edu',
          phone: '+91 97654 32109',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-104',
          name: 'Priya Sharma',
          rollNumber: 'Roll: CS2024-099',
          avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200',
          department: 'Computer Science',
          graduationYear: '2024 (Current)',
          cgpa: 9.60,
          percentage: 96.0,
          projectsCount: 15,
          projectsTag: '+3 recent',
          projectsTagType: 'success',
          readinessScore: 98,
          placementStatus: 'PLACED',
          hiredBy: 'Microsoft',
          hiredLogos: ['MS', 'AZ'],
          skills: ['Python', 'DSA', 'System Design', 'React.js', 'GraphQL'],
          email: 'priya.sharma@college.edu',
          phone: '+91 98989 12345',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-105',
          name: 'Ananya Roy',
          rollNumber: 'Roll: ME2024-089',
          avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200',
          department: 'Mechanical',
          graduationYear: '2024 (Current)',
          cgpa: 8.15,
          percentage: 81.5,
          projectsCount: 10,
          projectsTag: '+1 recent',
          projectsTagType: 'success',
          readinessScore: 88,
          placementStatus: 'PLACED',
          hiredBy: 'Tesla',
          hiredLogos: ['T'],
          skills: ['SolidWorks', 'CAD', 'Python', 'Robotics', 'FEA'],
          email: 'ananya.roy@college.edu',
          phone: '+91 98456 78901',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-106',
          name: 'Rahul Verma',
          rollNumber: 'Roll: CE2025-015',
          avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
          department: 'Civil',
          graduationYear: '2025',
          cgpa: 7.20,
          percentage: 72.0,
          projectsCount: 6,
          projectsTag: 'Avg',
          projectsTagType: 'neutral',
          readinessScore: 62,
          placementStatus: 'PENDING',
          skills: ['AutoCAD', 'STAAD Pro', 'Project Mgmt', 'Surveying'],
          email: 'rahul.verma@college.edu',
          phone: '+91 91234 56789',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-107',
          name: 'Dev Patel',
          rollNumber: 'Roll: EC2026-033',
          avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200',
          department: 'Electronics',
          graduationYear: '2026',
          cgpa: 6.90,
          percentage: 69.0,
          projectsCount: 5,
          projectsTag: 'Avg',
          projectsTagType: 'neutral',
          readinessScore: 55,
          placementStatus: 'UNPLACED',
          skills: ['Arduino', 'C++', 'Python', 'Sensors'],
          email: 'dev.patel@college.edu',
          phone: '+91 98000 11122',
          isMock: true,
        ),
        const CollegeStudentModel(
          id: 'stu-108',
          name: 'Kavya Nair',
          rollNumber: 'Roll: CS2025-077',
          avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
          department: 'Computer Science',
          graduationYear: '2025',
          cgpa: 8.75,
          percentage: 87.5,
          projectsCount: 11,
          projectsTag: '+2 recent',
          projectsTagType: 'success',
          readinessScore: 91,
          placementStatus: 'PLACED',
          hiredBy: 'Amazon',
          hiredLogos: ['A', 'AWS'],
          skills: ['Java', 'Spring Boot', 'AWS', 'Docker', 'Microservices'],
          email: 'kavya.nair@college.edu',
          phone: '+91 97111 22233',
          isMock: true,
        ),
      ];
}
