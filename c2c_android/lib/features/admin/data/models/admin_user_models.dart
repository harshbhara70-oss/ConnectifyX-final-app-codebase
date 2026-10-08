import 'package:equatable/equatable.dart';

/// Role category tab for User Management Directory
enum UserRoleTab {
  students,
  colleges,
  recruiters;

  String get label {
    switch (this) {
      case UserRoleTab.students:
        return 'Students';
      case UserRoleTab.colleges:
        return 'Colleges';
      case UserRoleTab.recruiters:
        return 'Recruiters';
    }
  }
}

/// Helper extension for Title Case string formatting
extension StringTitleCase on String {
  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Student Model for Admin Directory Oversight
class AdminStudentModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String college;
  final String branch;
  final String cgpa;
  final String rms;
  final String prjs;
  final String placementStatus; // 'Placed' | 'Seeking'
  final String activeStatus; // 'Active' | 'Suspended' | 'Inactive'
  final String phone;
  final int semester;
  final double percentage;
  final List<String> skills;
  final bool isMock;

  const AdminStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.college,
    required this.branch,
    required this.cgpa,
    required this.rms,
    required this.prjs,
    required this.placementStatus,
    required this.activeStatus,
    this.phone = '',
    this.semester = 8,
    this.percentage = 0.0,
    this.skills = const [],
    this.isMock = false,
  });

  factory AdminStudentModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    // Handling college if populated as Object or ObjectId String
    String collegeName = 'Autonomous Tech Institute';
    if (json['college'] is Map) {
      collegeName = json['college']['name']?.toString() ?? 'Tech Institute';
    } else if (json['college'] is String && (json['college'] as String).isNotEmpty) {
      collegeName = json['college'] as String;
    }

    final double rawPct = (json['percentage'] is num)
        ? (json['percentage'] as num).toDouble()
        : double.tryParse(json['percentage']?.toString() ?? '0.0') ?? 0.0;

    // Derive approximate CGPA from percentage or existing field
    String cgpaStr = json['cgpa']?.toString() ?? '';
    if (cgpaStr.isEmpty) {
      if (rawPct > 0) {
        cgpaStr = (rawPct / 10.0).toStringAsFixed(1);
      } else {
        cgpaStr = '8.5';
      }
    }

    final List<String> skillList = [];
    if (json['skills'] is List) {
      for (final s in json['skills']) {
        if (s != null && s.toString().trim().isNotEmpty) {
          skillList.add(s.toString().trim());
        }
      }
    }

    // Derive RMs and PRJs if not explicitly present
    final int rmsCount = (json['learningProgress'] is List)
        ? (json['learningProgress'] as List).length
        : (json['rmsCount'] is int ? json['rmsCount'] as int : 3);
    final int prjsCount = (json['assignmentSubmissions'] is List)
        ? (json['assignmentSubmissions'] as List).length
        : (json['prjsCount'] is int ? json['prjsCount'] as int : 4);

    final rawActive = json['status']?.toString() ?? json['activeStatus']?.toString() ?? 'Active';
    final normalizedActive = rawActive.toLowerCase().contains('suspend')
        ? 'Suspended'
        : (rawActive.toLowerCase().contains('inact') ? 'Inactive' : 'Active');

    final rawPlacement = json['placementStatus']?.toString() ?? (rawPct >= 75 ? 'Placed' : 'Seeking');

    final fallbackAvatars = [
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
    ];
    final String avatarUrl = (json['avatar'] != null && json['avatar'].toString().isNotEmpty)
        ? json['avatar'].toString()
        : fallbackAvatars[(json['name']?.toString().length ?? 0) % fallbackAvatars.length];

    return AdminStudentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Anonymous Student',
      email: json['email']?.toString() ?? '',
      avatar: avatarUrl,
      college: collegeName,
      branch: json['branch']?.toString() ?? 'Computer Science',
      cgpa: cgpaStr,
      rms: '$rmsCount RMs',
      prjs: '$prjsCount PRJs',
      placementStatus: rawPlacement,
      activeStatus: normalizedActive,
      phone: json['phone']?.toString() ?? '',
      semester: (json['semester'] is num) ? (json['semester'] as num).toInt() : 8,
      percentage: rawPct,
      skills: skillList.isNotEmpty ? skillList : const ['Flutter', 'Node.js', 'MongoDB', 'Python'],
      isMock: isMock,
    );
  }

  AdminStudentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? college,
    String? branch,
    String? cgpa,
    String? rms,
    String? prjs,
    String? placementStatus,
    String? activeStatus,
    String? phone,
    int? semester,
    double? percentage,
    List<String>? skills,
    bool? isMock,
  }) {
    return AdminStudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      cgpa: cgpa ?? this.cgpa,
      rms: rms ?? this.rms,
      prjs: prjs ?? this.prjs,
      placementStatus: placementStatus ?? this.placementStatus,
      activeStatus: activeStatus ?? this.activeStatus,
      phone: phone ?? this.phone,
      semester: semester ?? this.semester,
      percentage: percentage ?? this.percentage,
      skills: skills ?? this.skills,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatar,
        college,
        branch,
        cgpa,
        rms,
        prjs,
        placementStatus,
        activeStatus,
        phone,
        semester,
        percentage,
        skills,
        isMock,
      ];
}

/// College / Institution Model for Admin Directory Oversight
class AdminCollegeModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String university;
  final String address;
  final String city;
  final String state;
  final String phone;
  final String website;
  final String status; // 'Active' | 'Inactive' | 'Suspended'
  final int studentsCount;
  final bool isMock;

  const AdminCollegeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.university,
    this.address = '',
    this.city = '',
    this.state = '',
    this.phone = '',
    this.website = '',
    this.status = 'Active',
    this.studentsCount = 0,
    this.isMock = false,
  });

  factory AdminCollegeModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    int count = 0;
    if (json['students'] is List) {
      count = (json['students'] as List).length;
    } else if (json['studentsCount'] is int) {
      count = json['studentsCount'] as int;
    }

    return AdminCollegeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed Institution',
      email: json['email']?.toString() ?? '',
      university: json['university']?.toString() ?? 'State Technical University',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? 'Metropolis',
      state: json['state']?.toString() ?? 'State',
      phone: json['phone']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      studentsCount: count,
      isMock: isMock,
    );
  }

  AdminCollegeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? university,
    String? address,
    String? city,
    String? state,
    String? phone,
    String? website,
    String? status,
    int? studentsCount,
    bool? isMock,
  }) {
    return AdminCollegeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      university: university ?? this.university,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      status: status ?? this.status,
      studentsCount: studentsCount ?? this.studentsCount,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        university,
        address,
        city,
        state,
        phone,
        website,
        status,
        studentsCount,
        isMock,
      ];
}

/// Corporate Recruiter Model for Admin Directory Oversight
class AdminRecruiterModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String company;
  final String designation;
  final String phone;
  final String linkedin;
  final String status; // 'Active' | 'Inactive' | 'Suspended'
  final bool isMock;

  const AdminRecruiterModel({
    required this.id,
    required this.name,
    required this.email,
    required this.company,
    required this.designation,
    this.phone = '',
    this.linkedin = '',
    this.status = 'Active',
    this.isMock = false,
  });

  factory AdminRecruiterModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    String companyName = 'Global Tech Corp';
    if (json['company'] is Map) {
      companyName = json['company']['name']?.toString() ?? 'Global Tech Corp';
    } else if (json['company'] is String && (json['company'] as String).isNotEmpty) {
      companyName = json['company'] as String;
    }

    return AdminRecruiterModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Corporate Recruiter',
      email: json['email']?.toString() ?? '',
      company: companyName,
      designation: json['designation']?.toString() ?? 'Talent Acquisition Lead',
      phone: json['phone']?.toString() ?? '',
      linkedin: json['linkedin']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      isMock: isMock,
    );
  }

  AdminRecruiterModel copyWith({
    String? id,
    String? name,
    String? email,
    String? company,
    String? designation,
    String? phone,
    String? linkedin,
    String? status,
    bool? isMock,
  }) {
    return AdminRecruiterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      linkedin: linkedin ?? this.linkedin,
      status: status ?? this.status,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        company,
        designation,
        phone,
        linkedin,
        status,
        isMock,
      ];
}

/// Aggregated Directory Counter Metrics
class AdminUserDirectoryStats extends Equatable {
  final int totalStudents;
  final int totalColleges;
  final int totalRecruiters;
  final int totalPlaced;
  final bool isMock;

  const AdminUserDirectoryStats({
    required this.totalStudents,
    required this.totalColleges,
    required this.totalRecruiters,
    required this.totalPlaced,
    this.isMock = false,
  });

  @override
  List<Object?> get props => [
        totalStudents,
        totalColleges,
        totalRecruiters,
        totalPlaced,
        isMock,
      ];
}
