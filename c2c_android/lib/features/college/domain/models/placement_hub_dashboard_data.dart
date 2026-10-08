import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// KPI Card Model for Placement Statistics (matches frontend kpiCards)
class PlacementKpiItem {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color bgColor;

  const PlacementKpiItem({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.bgColor,
  });
}

/// Trend Point for Monthly Placement Rates and Offers (matches frontend placementTrend)
class PlacementTrendPoint {
  final String month;
  final double rate; // e.g. 60.0, 71.0
  final int offers; // e.g. 48, 86

  const PlacementTrendPoint({
    required this.month,
    required this.rate,
    required this.offers,
  });
}

/// Department Placement Rate (matches frontend departmentPlacement)
class DepartmentPlacementRate {
  final String department;
  final double rate; // 0-100%
  final Color color;

  const DepartmentPlacementRate({
    required this.department,
    required this.rate,
    required this.color,
  });
}

/// Eligibility Split Model (matches frontend eligibleVsPlaced)
class EligibilitySplit {
  final String name;
  final int value;
  final Color color;

  const EligibilitySplit({
    required this.name,
    required this.value,
    required this.color,
  });
}

/// CTC Band Distribution (matches frontend ctcDistribution)
class CtcBandDistribution {
  final String band;
  final int count;

  const CtcBandDistribution({
    required this.band,
    required this.count,
  });
}

/// Top Recruiter Offers Summary (matches frontend companyOffers)
class CompanyOfferSummary {
  final String company;
  final int offers;

  const CompanyOfferSummary({
    required this.company,
    required this.offers,
  });
}

/// Branch Average CTC Comparison (matches frontend branchAvgCtc)
class BranchAvgCtc {
  final String title;
  final String value;
  final double progress; // 0 to 100
  final Color color;

  const BranchAvgCtc({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });
}

/// Drive Summary Item for Drive Log (matches frontend driveSummary)
class DriveSummaryItem {
  final String company;
  final String date;
  final int appeared;
  final int selected;
  final int conversion; // percentage

  const DriveSummaryItem({
    required this.company,
    required this.date,
    required this.appeared,
    required this.selected,
    required this.conversion,
  });
}

/// Calendar Event Model for Campus Drive Calendar
class CalendarEventModel {
  final String id;
  final String month;
  final String date;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String driveId;

  const CalendarEventModel({
    required this.id,
    required this.month,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.driveId,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id']?.toString() ?? 'cal_${DateTime.now().millisecondsSinceEpoch}',
      month: json['month']?.toString() ?? 'OCT',
      date: json['date']?.toString() ?? '05',
      title: json['title']?.toString() ?? 'Technical Drive',
      subtitle: json['subtitle']?.toString() ?? '10:00 AM - 12:00 PM',
      accentColor: _parseColor(json['accentColor']),
      driveId: json['driveId']?.toString() ?? 'd1',
    );
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is String && colorValue.startsWith('#')) {
      return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
    }
    return AppColors.primary;
  }
}

/// Offer Pipeline Card Model
class PipelineOfferModel {
  final String id;
  final String driveId;
  final String roleTitle;
  final String companyName;
  final String badgeText;
  final Color badgeColor;
  final double progress; // 0.0 to 1.0

  const PipelineOfferModel({
    required this.id,
    required this.driveId,
    required this.roleTitle,
    required this.companyName,
    required this.badgeText,
    required this.badgeColor,
    required this.progress,
  });

  factory PipelineOfferModel.fromJson(Map<String, dynamic> json) {
    return PipelineOfferModel(
      id: json['id']?.toString() ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
      driveId: json['driveId']?.toString() ?? 'd1',
      roleTitle: json['roleTitle']?.toString() ?? 'Software Engineering (L3)',
      companyName: json['companyName']?.toString() ?? 'GOOGLE',
      badgeText: json['badgeText']?.toString() ?? '42 PENDING',
      badgeColor: json['badgeColor'] == 'green' ? AppColors.success : AppColors.primary,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.72,
    );
  }
}

/// Recruiter Allocation Model
class RecruiterAllocationModel {
  final String id;
  final String companyId;
  final String initials;
  final String name;
  final String title;
  final int activeCount;

  const RecruiterAllocationModel({
    required this.id,
    required this.companyId,
    required this.initials,
    required this.name,
    required this.title,
    required this.activeCount,
  });

  factory RecruiterAllocationModel.fromJson(Map<String, dynamic> json) {
    return RecruiterAllocationModel(
      id: json['id']?.toString() ?? 'r_${DateTime.now().millisecondsSinceEpoch}',
      companyId: json['companyId']?.toString() ?? 'c1',
      initials: json['initials']?.toString() ?? 'JD',
      name: json['name']?.toString() ?? 'Jane Doe',
      title: json['title']?.toString() ?? 'Senior Coordinator',
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 3,
    );
  }
}

/// Today's Lineup Interview Item Model
class LineupInterviewModel {
  final String id;
  final String time;
  final String candidateName;
  final String roleCompany;
  final String interviewer;
  final String statusText; // IN PROGRESS, UPCOMING, COMPLETED
  final Color statusColor;
  final Color statusBg;
  final bool isLast;

  const LineupInterviewModel({
    required this.id,
    required this.time,
    required this.candidateName,
    required this.roleCompany,
    required this.interviewer,
    required this.statusText,
    required this.statusColor,
    required this.statusBg,
    this.isLast = false,
  });

  factory LineupInterviewModel.fromJson(Map<String, dynamic> json) {
    final status = json['statusText']?.toString().toUpperCase() ?? 'UPCOMING';
    Color textCol = AppColors.textSecondary;
    Color bgCol = AppColors.inputFill;

    if (status == 'IN PROGRESS') {
      textCol = AppColors.success;
      bgCol = AppColors.successLight;
    } else if (status == 'LIVE') {
      textCol = AppColors.error;
      bgCol = AppColors.errorLight;
    }

    return LineupInterviewModel(
      id: json['id']?.toString() ?? 'l_${DateTime.now().millisecondsSinceEpoch}',
      time: json['time']?.toString() ?? '10:00 AM',
      candidateName: json['candidateName']?.toString() ?? 'Rahul Sharma',
      roleCompany: json['roleCompany']?.toString() ?? 'SDE-1 @ Google',
      interviewer: json['interviewer']?.toString() ?? 'Interviewer: David Chen',
      statusText: status,
      statusColor: textCol,
      statusBg: bgCol,
      isLast: json['isLast'] == true,
    );
  }
}

/// Aggregate Dashboard Payload Model (Unifies Placement Operations & Analytics)
class PlacementHubDashboardData {
  final List<CalendarEventModel> calendarEvents;
  final List<PipelineOfferModel> offerPipelines;
  final List<RecruiterAllocationModel> recruiters;
  final List<LineupInterviewModel> todaysLineup;
  final int activeCyclesCount;
  final int totalCandidatesCount;
  final int totalApplicationsCount;
  final int placedCount;
  final String avgPackage;
  final String highestPackage;
  final double placementRate;
  
  // Placement Analytics Extensions (matching frontend PlacementStatistics.tsx)
  final List<PlacementKpiItem> kpiCards;
  final List<PlacementTrendPoint> placementTrend;
  final List<DepartmentPlacementRate> departmentPlacement;
  final List<EligibilitySplit> eligibleVsPlaced;
  final List<CtcBandDistribution> ctcDistribution;
  final List<CompanyOfferSummary> companyOffers;
  final List<BranchAvgCtc> branchAvgCtc;
  final List<DriveSummaryItem> driveSummary;

  const PlacementHubDashboardData({
    required this.calendarEvents,
    required this.offerPipelines,
    required this.recruiters,
    required this.todaysLineup,
    required this.activeCyclesCount,
    required this.totalCandidatesCount,
    this.totalApplicationsCount = 186,
    this.placedCount = 610,
    this.avgPackage = '₹6.8 LPA',
    this.highestPackage = '₹42.0 LPA',
    this.placementRate = 71.0,
    this.kpiCards = const [],
    this.placementTrend = const [],
    this.departmentPlacement = const [],
    this.eligibleVsPlaced = const [],
    this.ctcDistribution = const [],
    this.companyOffers = const [],
    this.branchAvgCtc = const [],
    this.driveSummary = const [],
  });

  static const List<PlacementTrendPoint> defaultTrends = [
    PlacementTrendPoint(month: 'Jan', rate: 60.0, offers: 48),
    PlacementTrendPoint(month: 'Feb', rate: 66.0, offers: 61),
    PlacementTrendPoint(month: 'Mar', rate: 71.0, offers: 74),
    PlacementTrendPoint(month: 'Apr', rate: 77.0, offers: 88),
    PlacementTrendPoint(month: 'May', rate: 82.0, offers: 96),
  ];

  static const List<DepartmentPlacementRate> defaultDepartments = [
    DepartmentPlacementRate(department: 'CSE', rate: 82.0, color: Color(0xFF2563EB)),
    DepartmentPlacementRate(department: 'IT', rate: 76.0, color: Color(0xFFF59E0B)),
    DepartmentPlacementRate(department: 'ECE', rate: 68.0, color: Color(0xFF10B981)),
    DepartmentPlacementRate(department: 'Mech', rate: 54.0, color: Color(0xFF8B5CF6)),
  ];

  static const List<EligibilitySplit> defaultEligibility = [
    EligibilitySplit(name: 'Placed', value: 610, color: Color(0xFF2563EB)),
    EligibilitySplit(name: 'Eligible, not placed', value: 250, color: Color(0xFFF59E0B)),
    EligibilitySplit(name: 'Not yet eligible', value: 380, color: Color(0xFF94A3B8)),
  ];

  static const List<CtcBandDistribution> defaultCtc = [
    CtcBandDistribution(band: '< ₹4 LPA', count: 96),
    CtcBandDistribution(band: '₹4–6 LPA', count: 214),
    CtcBandDistribution(band: '₹6–8 LPA', count: 178),
    CtcBandDistribution(band: '₹8–10 LPA', count: 82),
    CtcBandDistribution(band: '₹10–15 LPA', count: 30),
    CtcBandDistribution(band: '₹15+ LPA', count: 10),
  ];

  static const List<CompanyOfferSummary> defaultCompanyOffers = [
    CompanyOfferSummary(company: 'TCS', offers: 142),
    CompanyOfferSummary(company: 'Infosys', offers: 118),
    CompanyOfferSummary(company: 'Accenture', offers: 96),
    CompanyOfferSummary(company: 'Wipro', offers: 88),
    CompanyOfferSummary(company: 'Deloitte', offers: 58),
    CompanyOfferSummary(company: 'Microsoft', offers: 34),
  ];

  static const List<BranchAvgCtc> defaultBranchAvg = [
    BranchAvgCtc(title: 'Computer Science & Engg.', value: '₹8.4 LPA', progress: 88, color: Color(0xFF2563EB)),
    BranchAvgCtc(title: 'Information Technology', value: '₹7.1 LPA', progress: 74, color: Color(0xFFF59E0B)),
    BranchAvgCtc(title: 'Electronics & Communication', value: '₹6.0 LPA', progress: 62, color: Color(0xFF10B981)),
    BranchAvgCtc(title: 'Mechanical Engineering', value: '₹4.8 LPA', progress: 48, color: Color(0xFF8B5CF6)),
  ];

  static const List<DriveSummaryItem> defaultDriveSummaries = [
    DriveSummaryItem(company: 'TCS', date: '25 Jun 2026', appeared: 420, selected: 142, conversion: 34),
    DriveSummaryItem(company: 'Infosys', date: '12 Jun 2026', appeared: 380, selected: 118, conversion: 31),
    DriveSummaryItem(company: 'Accenture', date: '02 Jun 2026', appeared: 310, selected: 96, conversion: 31),
    DriveSummaryItem(company: 'Wipro', date: '24 May 2026', appeared: 265, selected: 88, conversion: 33),
    DriveSummaryItem(company: 'Deloitte', date: '14 May 2026', appeared: 190, selected: 58, conversion: 31),
    DriveSummaryItem(company: 'Microsoft', date: '05 May 2026', appeared: 140, selected: 34, conversion: 24),
  ];

  static const PlacementHubDashboardData mockData = PlacementHubDashboardData(
    activeCyclesCount: 5,
    totalCandidatesCount: 1240,
    totalApplicationsCount: 186,
    placedCount: 610,
    avgPackage: '₹6.8 LPA',
    highestPackage: '₹42.0 LPA',
    placementRate: 71.0,
    placementTrend: defaultTrends,
    departmentPlacement: defaultDepartments,
    eligibleVsPlaced: defaultEligibility,
    ctcDistribution: defaultCtc,
    companyOffers: defaultCompanyOffers,
    branchAvgCtc: defaultBranchAvg,
    driveSummary: defaultDriveSummaries,
    calendarEvents: [
      CalendarEventModel(
        id: 'cal_1',
        month: 'JUN',
        date: '25',
        title: 'TCS Campus Drive',
        subtitle: '10:00 AM - 04:00 PM',
        accentColor: AppColors.primary,
        driveId: 'd1',
      ),
      CalendarEventModel(
        id: 'cal_2',
        month: 'JUL',
        date: '12',
        title: 'Infosys Placement Drive',
        subtitle: 'Main Auditorium',
        accentColor: AppColors.success,
        driveId: 'd2',
      ),
    ],
    offerPipelines: [
      PipelineOfferModel(
        id: 'p1',
        driveId: 'd1',
        roleTitle: 'Software Engineering (L3)',
        companyName: 'TCS',
        badgeText: '142 SELECTED',
        badgeColor: AppColors.success,
        progress: 0.85,
      ),
      PipelineOfferModel(
        id: 'p2',
        driveId: 'd2',
        roleTitle: 'System Engineer Specialist',
        companyName: 'INFOSYS',
        badgeText: '118 SELECTED',
        badgeColor: AppColors.primary,
        progress: 0.78,
      ),
      PipelineOfferModel(
        id: 'p3',
        driveId: 'd3',
        roleTitle: 'Full Stack Associate',
        companyName: 'ACCENTURE',
        badgeText: '96 SELECTED',
        badgeColor: AppColors.accentViolet,
        progress: 0.70,
      ),
    ],
    recruiters: [
      RecruiterAllocationModel(
        id: 'r1',
        companyId: 'c1',
        initials: 'JD',
        name: 'Jane Doe',
        title: 'Senior Coordinator',
        activeCount: 3,
      ),
      RecruiterAllocationModel(
        id: 'r2',
        companyId: 'c2',
        initials: 'AS',
        name: 'Arjun Singh',
        title: 'Lead Officer',
        activeCount: 1,
      ),
      RecruiterAllocationModel(
        id: 'r3',
        companyId: 'c3',
        initials: 'PK',
        name: 'Priya Kapoor',
        title: 'Talent Acquisition Manager',
        activeCount: 4,
      ),
    ],
    todaysLineup: [
      LineupInterviewModel(
        id: 'l1',
        time: '10:00 AM',
        candidateName: 'Rahul Sharma',
        roleCompany: 'SDE-1 @ Microsoft',
        interviewer: 'Interviewer: David Chen',
        statusText: 'IN PROGRESS',
        statusColor: AppColors.success,
        statusBg: AppColors.successLight,
        isLast: false,
      ),
      LineupInterviewModel(
        id: 'l2',
        time: '11:30 AM',
        candidateName: 'Ananya Iyer',
        roleCompany: 'Consultant @ Deloitte',
        interviewer: 'Interviewer: Sarah Jenkins',
        statusText: 'UPCOMING',
        statusColor: AppColors.textSecondary,
        statusBg: AppColors.inputFill,
        isLast: true,
      ),
    ],
  );
}
