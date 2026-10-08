// Type-safe domain data models for the College "Reports & Analytics" module.
// 1:1 Parity with web frontend `ReportsAnalyticsView.tsx`.

class DrivePerformanceRow {
  final String id;
  final String companyName;
  final String logoType; // 'cloud' | 'atlassian' | 'bank' | 'zap'
  final String logoBg;
  final String role;
  final int applicants;
  final int selected;
  final double conversionPct;
  final String avgCtcLpa;
  final String status; // 'CLOSED' | 'IN PROGRESS' | 'UPCOMING'
  final bool isMock;

  const DrivePerformanceRow({
    required this.id,
    required this.companyName,
    required this.logoType,
    required this.logoBg,
    required this.role,
    required this.applicants,
    required this.selected,
    required this.conversionPct,
    required this.avgCtcLpa,
    required this.status,
    this.isMock = false,
  });

  factory DrivePerformanceRow.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return DrivePerformanceRow(
      id: json['id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? 'Company',
      logoType: json['logoType']?.toString() ?? 'cloud',
      logoBg: json['logoBg']?.toString() ?? 'bg-purple-50',
      role: json['role']?.toString() ?? 'Software Engineer',
      applicants: (json['applicants'] as num?)?.toInt() ?? 0,
      selected: (json['selected'] as num?)?.toInt() ?? 0,
      conversionPct: (json['conversionPct'] as num?)?.toDouble() ?? 0.0,
      avgCtcLpa: json['avgCtcLpa']?.toString() ?? '0.0 LPA',
      status: json['status']?.toString().toUpperCase() ?? 'CLOSED',
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'logoType': logoType,
        'logoBg': logoBg,
        'role': role,
        'applicants': applicants,
        'selected': selected,
        'conversionPct': conversionPct,
        'avgCtcLpa': avgCtcLpa,
        'status': status,
        'isMock': isMock,
      };
}

class DepartmentPlacementMetric {
  final String dept;
  final int placed;
  final int total;
  final int pct;
  final bool isMock;

  const DepartmentPlacementMetric({
    required this.dept,
    required this.placed,
    required this.total,
    required this.pct,
    this.isMock = false,
  });

  factory DepartmentPlacementMetric.fromJson(Map<String, dynamic> json, {bool isMock = false}) {
    return DepartmentPlacementMetric(
      dept: json['dept']?.toString() ?? '',
      placed: (json['placed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      pct: (json['pct'] as num?)?.toInt() ?? 0,
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'dept': dept,
        'placed': placed,
        'total': total,
        'pct': pct,
        'isMock': isMock,
      };
}

class TierDistribution {
  final double tier1;
  final double tier2;
  final double tier3;
  final double others;

  const TierDistribution({
    this.tier1 = 0,
    this.tier2 = 0,
    this.tier3 = 0,
    this.others = 0,
  });

  factory TierDistribution.fromJson(Map<String, dynamic> json) {
    return TierDistribution(
      tier1: (json['tier1'] as num?)?.toDouble() ?? 0.0,
      tier2: (json['tier2'] as num?)?.toDouble() ?? 0.0,
      tier3: (json['tier3'] as num?)?.toDouble() ?? 0.0,
      others: (json['others'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier1': tier1,
        'tier2': tier2,
        'tier3': tier3,
        'others': others,
      };
}

class ReportsAnalyticsDataModel {
  final String academicSession;
  final int placedPct;
  final int eligibleCount;
  final int offersCount;
  final TierDistribution tierDist;
  final int monthlyAvg;
  final double aiMastery;
  final int codeQuality;
  final int archDesign;
  final int scalability;
  final List<DepartmentPlacementMetric> departments;
  final List<DrivePerformanceRow> drives;
  final bool isMock;

  const ReportsAnalyticsDataModel({
    required this.academicSession,
    required this.placedPct,
    required this.eligibleCount,
    required this.offersCount,
    required this.tierDist,
    required this.monthlyAvg,
    required this.aiMastery,
    required this.codeQuality,
    required this.archDesign,
    required this.scalability,
    required this.departments,
    required this.drives,
    this.isMock = false,
  });

  factory ReportsAnalyticsDataModel.fromJson(
    Map<String, dynamic> json, {
    String session = '2023-24',
    bool isMock = false,
  }) {
    final deptsRaw = json['departments'] as List? ?? [];
    final drivesRaw = json['drives'] as List? ?? [];

    return ReportsAnalyticsDataModel(
      academicSession: json['academicSession']?.toString() ?? session,
      placedPct: (json['placedPct'] as num?)?.toInt() ?? 0,
      eligibleCount: (json['eligibleCount'] as num?)?.toInt() ?? 0,
      offersCount: (json['offersCount'] as num?)?.toInt() ?? 0,
      tierDist: json['tierDist'] is Map<String, dynamic>
          ? TierDistribution.fromJson(json['tierDist'] as Map<String, dynamic>)
          : (json['tierDist'] is Map
              ? TierDistribution.fromJson(Map<String, dynamic>.from(json['tierDist'] as Map))
              : const TierDistribution()),
      monthlyAvg: (json['monthlyAvg'] as num?)?.toInt() ?? 0,
      aiMastery: (json['aiMastery'] as num?)?.toDouble() ?? 0.0,
      codeQuality: (json['codeQuality'] as num?)?.toInt() ?? 0,
      archDesign: (json['archDesign'] as num?)?.toInt() ?? 0,
      scalability: (json['scalability'] as num?)?.toInt() ?? 0,
      departments: deptsRaw
          .whereType<Map>()
          .map((d) => DepartmentPlacementMetric.fromJson(
                Map<String, dynamic>.from(d),
                isMock: isMock,
              ))
          .toList(),
      drives: drivesRaw
          .whereType<Map>()
          .map((d) => DrivePerformanceRow.fromJson(
                Map<String, dynamic>.from(d),
                isMock: isMock,
              ))
          .toList(),
      isMock: isMock || (json['isMock'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
        'academicSession': academicSession,
        'placedPct': placedPct,
        'eligibleCount': eligibleCount,
        'offersCount': offersCount,
        'tierDist': tierDist.toJson(),
        'monthlyAvg': monthlyAvg,
        'aiMastery': aiMastery,
        'codeQuality': codeQuality,
        'archDesign': archDesign,
        'scalability': scalability,
        'departments': departments.map((d) => d.toJson()).toList(),
        'drives': drives.map((d) => d.toJson()).toList(),
        'isMock': isMock,
      };

  bool get isEmpty =>
      placedPct == 0 &&
      eligibleCount == 0 &&
      offersCount == 0 &&
      departments.isEmpty &&
      drives.isEmpty;

  /// Mock Seed Datasets 1:1 matching `ReportsAnalyticsView.tsx`
  static final Map<String, ReportsAnalyticsDataModel> sessionDatasets = {
    '2023-24': const ReportsAnalyticsDataModel(
      academicSession: '2023-24',
      placedPct: 82,
      eligibleCount: 1240,
      offersCount: 1016,
      tierDist: TierDistribution(tier1: 25, tier2: 35, tier3: 30, others: 10),
      monthlyAvg: 2841,
      aiMastery: 88.4,
      codeQuality: 92,
      archDesign: 84,
      scalability: 76,
      departments: [
        DepartmentPlacementMetric(dept: 'CS/IT', placed: 420, total: 450, pct: 93, isMock: true),
        DepartmentPlacementMetric(dept: 'ECE', placed: 260, total: 300, pct: 86, isMock: true),
        DepartmentPlacementMetric(dept: 'Mech', placed: 180, total: 220, pct: 81, isMock: true),
        DepartmentPlacementMetric(dept: 'MBA', placed: 110, total: 140, pct: 78, isMock: true),
        DepartmentPlacementMetric(dept: 'Civil', placed: 46, total: 130, pct: 35, isMock: true),
      ],
      drives: [
        DrivePerformanceRow(
          id: 'd-1',
          companyName: 'Salesforce',
          logoType: 'cloud',
          logoBg: 'purple',
          role: 'MTS-1 Software',
          applicants: 840,
          selected: 24,
          conversionPct: 2.8,
          avgCtcLpa: '28.5 LPA',
          status: 'CLOSED',
          isMock: true,
        ),
        DrivePerformanceRow(
          id: 'd-2',
          companyName: 'Atlassian',
          logoType: 'atlassian',
          logoBg: 'blue',
          role: 'Product Engineer',
          applicants: 520,
          selected: 12,
          conversionPct: 2.3,
          avgCtcLpa: '42.0 LPA',
          status: 'CLOSED',
          isMock: true,
        ),
        DrivePerformanceRow(
          id: 'd-3',
          companyName: 'Goldman Sachs',
          logoType: 'bank',
          logoBg: 'slate',
          role: 'Analyst',
          applicants: 1150,
          selected: 45,
          conversionPct: 3.9,
          avgCtcLpa: '22.0 LPA',
          status: 'IN PROGRESS',
          isMock: true,
        ),
        DrivePerformanceRow(
          id: 'd-4',
          companyName: 'Razorpay',
          logoType: 'zap',
          logoBg: 'violet',
          role: 'Frontend SDE',
          applicants: 410,
          selected: 8,
          conversionPct: 1.9,
          avgCtcLpa: '18.0 LPA',
          status: 'UPCOMING',
          isMock: true,
        ),
      ],
      isMock: true,
    ),
    '2024-25': const ReportsAnalyticsDataModel(
      academicSession: '2024-25',
      placedPct: 88,
      eligibleCount: 1350,
      offersCount: 1188,
      tierDist: TierDistribution(tier1: 30, tier2: 38, tier3: 24, others: 8),
      monthlyAvg: 3120,
      aiMastery: 91.2,
      codeQuality: 95,
      archDesign: 88,
      scalability: 82,
      departments: [
        DepartmentPlacementMetric(dept: 'CS/IT', placed: 470, total: 490, pct: 95, isMock: true),
        DepartmentPlacementMetric(dept: 'ECE', placed: 290, total: 320, pct: 90, isMock: true),
        DepartmentPlacementMetric(dept: 'Mech', placed: 200, total: 230, pct: 87, isMock: true),
        DepartmentPlacementMetric(dept: 'MBA', placed: 130, total: 150, pct: 86, isMock: true),
        DepartmentPlacementMetric(dept: 'Civil', placed: 98, total: 160, pct: 61, isMock: true),
      ],
      drives: [
        DrivePerformanceRow(
          id: 'd-5',
          companyName: 'Salesforce',
          logoType: 'cloud',
          logoBg: 'purple',
          role: 'MTS-2 Software',
          applicants: 920,
          selected: 30,
          conversionPct: 3.2,
          avgCtcLpa: '30.0 LPA',
          status: 'CLOSED',
          isMock: true,
        ),
        DrivePerformanceRow(
          id: 'd-6',
          companyName: 'Atlassian',
          logoType: 'atlassian',
          logoBg: 'blue',
          role: 'Senior Product Engineer',
          applicants: 600,
          selected: 18,
          conversionPct: 3.0,
          avgCtcLpa: '45.0 LPA',
          status: 'IN PROGRESS',
          isMock: true,
        ),
      ],
      isMock: true,
    ),
    '2025-26': const ReportsAnalyticsDataModel(
      academicSession: '2025-26',
      placedPct: 92,
      eligibleCount: 1420,
      offersCount: 1306,
      tierDist: TierDistribution(tier1: 35, tier2: 40, tier3: 20, others: 5),
      monthlyAvg: 3450,
      aiMastery: 93.8,
      codeQuality: 97,
      archDesign: 92,
      scalability: 88,
      departments: [
        DepartmentPlacementMetric(dept: 'CS/IT', placed: 510, total: 520, pct: 98, isMock: true),
        DepartmentPlacementMetric(dept: 'ECE', placed: 310, total: 330, pct: 93, isMock: true),
        DepartmentPlacementMetric(dept: 'Mech', placed: 220, total: 240, pct: 91, isMock: true),
        DepartmentPlacementMetric(dept: 'MBA', placed: 145, total: 160, pct: 90, isMock: true),
        DepartmentPlacementMetric(dept: 'Civil', placed: 121, total: 170, pct: 71, isMock: true),
      ],
      drives: [
        DrivePerformanceRow(
          id: 'd-7',
          companyName: 'Goldman Sachs',
          logoType: 'bank',
          logoBg: 'slate',
          role: 'Quantitative Analyst',
          applicants: 1100,
          selected: 48,
          conversionPct: 4.3,
          avgCtcLpa: '26.0 LPA',
          status: 'IN PROGRESS',
          isMock: true,
        ),
      ],
      isMock: true,
    ),
  };
}