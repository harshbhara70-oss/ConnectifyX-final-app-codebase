import 'package:equatable/equatable.dart';

/// DTO for aggregate metrics on the Placement Oversight dashboard
class AdminPlacementMetricDto extends Equatable {
  final int activeDrives;
  final int participatingColleges;
  final int totalApplicants;
  final int offersExtended;
  final String activeDrivesGrowth;
  final String collegesGrowth;
  final String applicantsGrowth;
  final String offersGrowth;
  final bool isMock;

  const AdminPlacementMetricDto({
    required this.activeDrives,
    required this.participatingColleges,
    required this.totalApplicants,
    required this.offersExtended,
    this.activeDrivesGrowth = '+18% this month',
    this.collegesGrowth = '+4 new this season',
    this.applicantsGrowth = '+2.4k this week',
    this.offersGrowth = '+320 accepted',
    this.isMock = false,
  });

  factory AdminPlacementMetricDto.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminPlacementMetricDto(
      activeDrives: (json['activeDrives'] ?? json['activeProjects'] ?? json['totalProjects'] ?? 142) as int,
      participatingColleges: (json['participatingColleges'] ?? json['totalColleges'] ?? 38) as int,
      totalApplicants: (json['totalApplicants'] ?? json['totalApplications'] ?? json['totalStudents'] ?? 12450) as int,
      offersExtended: (json['offersExtended'] ?? 2105) as int,
      activeDrivesGrowth: json['activeDrivesGrowth']?.toString() ?? '+18% this month',
      collegesGrowth: json['collegesGrowth']?.toString() ?? '+4 new this season',
      applicantsGrowth: json['applicantsGrowth']?.toString() ?? '+2.4k this week',
      offersGrowth: json['offersGrowth']?.toString() ?? '+320 accepted',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'activeDrives': activeDrives,
    'participatingColleges': participatingColleges,
    'totalApplicants': totalApplicants,
    'offersExtended': offersExtended,
    'activeDrivesGrowth': activeDrivesGrowth,
    'collegesGrowth': collegesGrowth,
    'applicantsGrowth': applicantsGrowth,
    'offersGrowth': offersGrowth,
    'isMock': isMock,
  };

  @override
  List<Object?> get props => [
    activeDrives,
    participatingColleges,
    totalApplicants,
    offersExtended,
    activeDrivesGrowth,
    collegesGrowth,
    applicantsGrowth,
    offersGrowth,
    isMock,
  ];
}

/// Model representing an active placement drive
class AdminPlacementDriveModel extends Equatable {
  final String id;
  final String college;
  final String company;
  final String role;
  final String type; // On-Campus, Pooled, Off-Campus, Virtual
  final String deadline;
  final int applicants;
  final String status; // In Progress, Assessment Phase, Completed, Scheduled
  final String ctcRange;
  final String location;
  final String eligibility;
  final List<String> rounds;
  final String notes;
  final bool isMock;

  const AdminPlacementDriveModel({
    required this.id,
    required this.college,
    required this.company,
    required this.role,
    required this.type,
    required this.deadline,
    required this.applicants,
    required this.status,
    this.ctcRange = '8 - 14 LPA',
    this.location = 'Bengaluru / Hybrid',
    this.eligibility = 'B.Tech / B.E (CS/IT/ECE) CGPA >= 7.0',
    this.rounds = const ['Online Assessment', 'Technical Interview', 'HR Round'],
    this.notes = 'Pre-placement talk completed with 95% attendance.',
    this.isMock = false,
  });

  factory AdminPlacementDriveModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    List<String> parsedRounds = ['Online Assessment', 'Technical Round', 'HR Interview'];
    if (json['rounds'] is List) {
      parsedRounds = (json['rounds'] as List).map((e) => e.toString()).toList();
    }

    return AdminPlacementDriveModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? 'drv_${DateTime.now().millisecondsSinceEpoch}',
      college: json['college']?.toString() ?? json['collegeName']?.toString() ?? 'Engineering Institute',
      company: json['company']?.toString() ?? json['companyName']?.toString() ?? 'TechCorp',
      role: json['role']?.toString() ?? json['jobRole']?.toString() ?? 'Associate Engineer',
      type: json['type']?.toString() ?? 'On-Campus',
      deadline: json['deadline']?.toString() ?? json['driveDate']?.toString() ?? 'Oct 20, 2024',
      applicants: (json['applicants'] ?? json['applicantCount'] ?? 0) is int
          ? (json['applicants'] ?? json['applicantCount'] ?? 0) as int
          : int.tryParse(json['applicants']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'In Progress',
      ctcRange: json['ctcRange']?.toString() ?? '8 - 14 LPA',
      location: json['location']?.toString() ?? 'Bengaluru / Hybrid',
      eligibility: json['eligibility']?.toString() ?? 'B.Tech / B.E (CS/IT/ECE) CGPA >= 7.0',
      rounds: parsedRounds,
      notes: json['notes']?.toString() ?? 'Pre-placement talk completed with high engagement.',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'college': college,
    'company': company,
    'role': role,
    'type': type,
    'deadline': deadline,
    'applicants': applicants,
    'status': status,
    'ctcRange': ctcRange,
    'location': location,
    'eligibility': eligibility,
    'rounds': rounds,
    'notes': notes,
    'isMock': isMock,
  };

  AdminPlacementDriveModel copyWith({
    String? id,
    String? college,
    String? company,
    String? role,
    String? type,
    String? deadline,
    int? applicants,
    String? status,
    String? ctcRange,
    String? location,
    String? eligibility,
    List<String>? rounds,
    String? notes,
    bool? isMock,
  }) {
    return AdminPlacementDriveModel(
      id: id ?? this.id,
      college: college ?? this.college,
      company: company ?? this.company,
      role: role ?? this.role,
      type: type ?? this.type,
      deadline: deadline ?? this.deadline,
      applicants: applicants ?? this.applicants,
      status: status ?? this.status,
      ctcRange: ctcRange ?? this.ctcRange,
      location: location ?? this.location,
      eligibility: eligibility ?? this.eligibility,
      rounds: rounds ?? this.rounds,
      notes: notes ?? this.notes,
      isMock: isMock ?? this.isMock,
    );
  }

  @override
  List<Object?> get props => [
    id,
    college,
    company,
    role,
    type,
    deadline,
    applicants,
    status,
    ctcRange,
    location,
    eligibility,
    rounds,
    notes,
    isMock,
  ];
}

/// Model representing Upcoming Critical Events (Interviews, Tests, PPTs)
class AdminPlacementEventModel extends Equatable {
  final String id;
  final String title;
  final String college;
  final String scheduleTime;
  final String type; // Interview, Assessment, PPT
  final String colorHex;
  final bool isMock;

  const AdminPlacementEventModel({
    required this.id,
    required this.title,
    required this.college,
    required this.scheduleTime,
    required this.type,
    required this.colorHex,
    this.isMock = false,
  });

  factory AdminPlacementEventModel.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return AdminPlacementEventModel(
      id: json['id']?.toString() ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Placement Event',
      college: json['college']?.toString() ?? 'Engineering Institute',
      scheduleTime: json['scheduleTime']?.toString() ?? json['desc']?.toString() ?? 'Tomorrow, 9:00 AM',
      type: json['type']?.toString() ?? 'Interview',
      colorHex: json['colorHex']?.toString() ?? '0xFF6D28D9',
      isMock: isMock,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'college': college,
    'scheduleTime': scheduleTime,
    'type': type,
    'colorHex': colorHex,
    'isMock': isMock,
  };

  @override
  List<Object?> get props => [id, title, college, scheduleTime, type, colorHex, isMock];
}

/// Filter DTO for Placement Oversight
class AdminPlacementFilterDto extends Equatable {
  final String selectedCollege;
  final String selectedCompany;
  final String selectedType;
  final String selectedStatus;
  final String dateQuery;
  final String searchQuery;

  const AdminPlacementFilterDto({
    this.selectedCollege = 'all',
    this.selectedCompany = 'all',
    this.selectedType = 'all',
    this.selectedStatus = 'all',
    this.dateQuery = '',
    this.searchQuery = '',
  });

  AdminPlacementFilterDto copyWith({
    String? selectedCollege,
    String? selectedCompany,
    String? selectedType,
    String? selectedStatus,
    String? dateQuery,
    String? searchQuery,
  }) {
    return AdminPlacementFilterDto(
      selectedCollege: selectedCollege ?? this.selectedCollege,
      selectedCompany: selectedCompany ?? this.selectedCompany,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      dateQuery: dateQuery ?? this.dateQuery,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    selectedCollege,
    selectedCompany,
    selectedType,
    selectedStatus,
    dateQuery,
    searchQuery,
  ];
}
