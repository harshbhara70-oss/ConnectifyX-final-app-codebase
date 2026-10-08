import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/admin_user_models.dart';
import '../models/admin_placement_models.dart';
import '../models/admin_verification_models.dart';
import '../models/admin_broadcast_models.dart';
import '../models/admin_analytics_models.dart';
import '../models/admin_support_models.dart';
import '../models/admin_dashboard_models.dart';

class ExportResult {
  final bool success;
  final String filePath;
  final String fileName;
  final int count;
  final String csvContent;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    required this.filePath,
    required this.fileName,
    required this.count,
    required this.csvContent,
    this.errorMessage,
  });
}

class AdminCsvExporter {
  /// Generates real CSV string from Students list
  static String generateStudentsCsv(List<AdminStudentModel> students) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('ID,Name,Email,College,Branch,CGPA,Roadmaps,Projects,Placement Status,Active Status,Phone,Semester,Skills');

    for (final s in students) {
      final id = _escapeCsv(s.id);
      final name = _escapeCsv(s.name);
      final email = _escapeCsv(s.email);
      final college = _escapeCsv(s.college);
      final branch = _escapeCsv(s.branch);
      final cgpa = _escapeCsv(s.cgpa);
      final rms = _escapeCsv(s.rms);
      final prjs = _escapeCsv(s.prjs);
      final placement = _escapeCsv(s.placementStatus);
      final active = _escapeCsv(s.activeStatus);
      final phone = _escapeCsv(s.phone);
      final semester = s.semester;
      final skills = _escapeCsv(s.skills.join('; '));

      buffer.writeln('$id,$name,$email,$college,$branch,$cgpa,$rms,$prjs,$placement,$active,$phone,$semester,$skills');
    }

    return buffer.toString();
  }

  /// Generates real CSV string from Colleges list
  static String generateCollegesCsv(List<AdminCollegeModel> colleges) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('ID,College Name,Email,University,City,State,Phone,Website,Status,Students Count');

    for (final c in colleges) {
      final id = _escapeCsv(c.id);
      final name = _escapeCsv(c.name);
      final email = _escapeCsv(c.email);
      final university = _escapeCsv(c.university);
      final city = _escapeCsv(c.city);
      final state = _escapeCsv(c.state);
      final phone = _escapeCsv(c.phone);
      final website = _escapeCsv(c.website);
      final status = _escapeCsv(c.status);
      final studentsCount = c.studentsCount;

      buffer.writeln('$id,$name,$email,$university,$city,$state,$phone,$website,$status,$studentsCount');
    }

    return buffer.toString();
  }

  /// Generates real CSV string from Recruiters list
  static String generateRecruitersCsv(List<AdminRecruiterModel> recruiters) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('ID,Recruiter Name,Email,Company,Designation,Phone,LinkedIn,Status');

    for (final r in recruiters) {
      final id = _escapeCsv(r.id);
      final name = _escapeCsv(r.name);
      final email = _escapeCsv(r.email);
      final company = _escapeCsv(r.company);
      final designation = _escapeCsv(r.designation);
      final phone = _escapeCsv(r.phone);
      final linkedin = _escapeCsv(r.linkedin);
      final status = _escapeCsv(r.status);

      buffer.writeln('$id,$name,$email,$company,$designation,$phone,$linkedin,$status');
    }

    return buffer.toString();
  }

  /// Generates real CSV string from Placement Drives list and summary metrics
  static String generatePlacementDrivesCsv(
    List<AdminPlacementDriveModel> drives, {
    AdminPlacementMetricDto? metrics,
  }) {
    final buffer = StringBuffer();

    // Summary Header
    if (metrics != null) {
      buffer.writeln('# CAMPUS2CORPORATE - PLACEMENT OVERSIGHT REPORT');
      buffer.writeln('# Generated At: ${DateTime.now().toIso8601String()}');
      buffer.writeln('# Active Drives: ${metrics.activeDrives}');
      buffer.writeln('# Participating Colleges: ${metrics.participatingColleges}');
      buffer.writeln('# Total Applicants: ${metrics.totalApplicants}');
      buffer.writeln('# Offers Extended: ${metrics.offersExtended}');
      buffer.writeln('');
    }

    // Column Headers
    buffer.writeln('Drive ID,Company,Job Role,College,Drive Type,Status,Deadline,Applicants,CTC Package,Location,Eligibility,Rounds,Notes');

    for (final d in drives) {
      final id = _escapeCsv(d.id);
      final company = _escapeCsv(d.company);
      final role = _escapeCsv(d.role);
      final college = _escapeCsv(d.college);
      final type = _escapeCsv(d.type);
      final status = _escapeCsv(d.status);
      final deadline = _escapeCsv(d.deadline);
      final applicants = d.applicants;
      final ctc = _escapeCsv(d.ctcRange);
      final location = _escapeCsv(d.location);
      final eligibility = _escapeCsv(d.eligibility);
      final rounds = _escapeCsv(d.rounds.join('; '));
      final notes = _escapeCsv(d.notes);

      buffer.writeln('$id,$company,$role,$college,$type,$status,$deadline,$applicants,$ctc,$location,$eligibility,$rounds,$notes');
    }

    return buffer.toString();
  }

  /// Exports Placement Drives Report to a local CSV file
  static Future<ExportResult> exportPlacementReportToCsvFile({
    required List<AdminPlacementDriveModel> drives,
    AdminPlacementMetricDto? metrics,
  }) async {
    try {
      if (drives.isEmpty) {
        return const ExportResult(
          success: false,
          filePath: '',
          fileName: '',
          count: 0,
          csvContent: '',
          errorMessage: 'No placement drive records found to export.',
        );
      }

      final csvData = generatePlacementDrivesCsv(drives, metrics: metrics);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'placement_oversight_report_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: drives.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export report: ${e.toString()}',
      );
    }
  }

  /// Generates real CSV string for Verification Queue Audit Log
  static String generateVerificationAuditLogCsv(
    List<AdminVerificationCardModel> cards, {
    AdminQueueStatusDto? status,
  }) {
    final buffer = StringBuffer();

    // Summary Header
    buffer.writeln('# CAMPUS2CORPORATE - VERIFICATION QUEUE AUDIT LOG');
    buffer.writeln('# Exported At: ${DateTime.now().toIso8601String()}');
    if (status != null) {
      buffer.writeln('# High Priority Queue: ${status.highPriority}');
      buffer.writeln('# Standard Queue: ${status.standard}');
      buffer.writeln('# Avg Wait Time: ${status.avgWaitTime}');
    }
    buffer.writeln('');

    // Column Headers
    buffer.writeln('ID,Entity Title,Category,Priority,Submission Info,Domain Verified,Docs Attached,Tax ID Verified,LinkedIn Status,Domain URL,Verification Status,AI Flagged');

    for (final c in cards) {
      final id = _escapeCsv(c.id);
      final title = _escapeCsv(c.title);
      final category = _escapeCsv(c.category);
      final priority = _escapeCsv(c.priority);
      final submitted = _escapeCsv(c.submitted);
      final domainMatch = c.domainMatch ? 'YES' : 'NO';
      final accreditationDoc = c.accreditationDoc ? 'YES' : 'NO';
      final taxIdVerified = c.taxIdVerified ? 'YES' : 'NO';
      final linkedinStatus = _escapeCsv(c.linkedinStatus);
      final domainUrl = _escapeCsv(c.domainUrl);
      final verStatus = _escapeCsv(c.status.toUpperCase());
      final flagged = c.flaggedByAi ? 'YES' : 'NO';

      buffer.writeln('$id,$title,$category,$priority,$submitted,$domainMatch,$accreditationDoc,$taxIdVerified,$linkedinStatus,$domainUrl,$verStatus,$flagged');
    }

    return buffer.toString();
  }

  /// Exports Verification Queue Audit Log to local CSV file
  static Future<ExportResult> exportVerificationAuditLogToCsvFile({
    required List<AdminVerificationCardModel> cards,
    AdminQueueStatusDto? status,
  }) async {
    try {
      if (cards.isEmpty) {
        return const ExportResult(
          success: false,
          filePath: '',
          fileName: '',
          count: 0,
          csvContent: '',
          errorMessage: 'No verification records found to export.',
        );
      }

      final csvData = generateVerificationAuditLogCsv(cards, status: status);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'verification_audit_log_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: cards.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export audit log: ${e.toString()}',
      );
    }
  }

  /// Saves CSV data to local storage and returns ExportResult
  static Future<ExportResult> exportToCsvFile({
    required UserRoleTab role,
    required List<dynamic> items,
    bool onlySelected = false,
  }) async {
    try {
      if (items.isEmpty) {
        return const ExportResult(
          success: false,
          filePath: '',
          fileName: '',
          count: 0,
          csvContent: '',
          errorMessage: 'No records available to export.',
        );
      }

      String csvData = '';
      String prefix = 'students';

      if (role == UserRoleTab.students) {
        final list = items.whereType<AdminStudentModel>().toList();
        csvData = generateStudentsCsv(list);
        prefix = 'students_directory';
      } else if (role == UserRoleTab.colleges) {
        final list = items.whereType<AdminCollegeModel>().toList();
        csvData = generateCollegesCsv(list);
        prefix = 'colleges_directory';
      } else {
        final list = items.whereType<AdminRecruiterModel>().toList();
        csvData = generateRecruitersCsv(list);
        prefix = 'recruiters_directory';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${prefix}_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: items.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  /// Generates real CSV string from Broadcast History & College Oversight
  static String generateBroadcastsCsv(List<AdminBroadcastModel> broadcasts, List<CollegeOversightBroadcastModel> oversight) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln('Type,ID,Title,Target,Priority / Volume,Sent Date,Open Rate,Click Rate,Status,Mock');

    for (final b in broadcasts) {
      final type = 'Platform Broadcast';
      final id = _escapeCsv(b.id);
      final title = _escapeCsv(b.title);
      final target = _escapeCsv(b.target);
      final priority = _escapeCsv(b.priority);
      final date = _escapeCsv(b.date);
      final open = _escapeCsv(b.openRate);
      final click = _escapeCsv(b.clickRate);
      final status = _escapeCsv(b.status);
      final mock = b.isMock ? 'Yes' : 'No';

      buffer.writeln('$type,$id,$title,$target,$priority,$date,$open,$click,$status,$mock');
    }

    for (final o in oversight) {
      final type = 'College Oversight (${o.college})';
      final id = _escapeCsv(o.id);
      final title = _escapeCsv(o.title);
      final target = _escapeCsv(o.target);
      final vol = _escapeCsv(o.vol);
      final date = _escapeCsv(o.sentDate);
      final open = '--';
      final click = '--';
      final status = _escapeCsv(o.status);
      final mock = o.isMock ? 'Yes' : 'No';

      buffer.writeln('$type,$id,$title,$target,$vol,$date,$open,$click,$status,$mock');
    }

    return buffer.toString();
  }

  /// Exports Broadcasts & College Oversight to CSV file on local device
  static Future<ExportResult> exportBroadcastsToCsv(
    List<AdminBroadcastModel> broadcasts,
    List<CollegeOversightBroadcastModel> oversight,
  ) async {
    try {
      final csvData = generateBroadcastsCsv(broadcasts, oversight);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'admin_broadcast_audit_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: broadcasts.length + oversight.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  /// Generates CSV data for Platform Analytics
  static String generateAnalyticsCsv(AdminPlatformAnalyticsDto analytics) {
    final buffer = StringBuffer();
    buffer.writeln('CAMPUS2CORPORATE - PLATFORM ANALYTICS AUDIT REPORT');
    buffer.writeln('Generated At,${DateTime.now().toIso8601String()}');
    buffer.writeln('Selected Date Range,${analytics.selectedDateRange}');
    buffer.writeln('Data Source,${analytics.isMock ? "Platform Baseline Dataset (*)" : "Realtime MongoDB Atlas"}');
    buffer.writeln('');

    buffer.writeln('--- 1. ENTERPRISE KPI METRICS ---');
    buffer.writeln('Metric,Current Value,Growth / Status,Data Integrity');
    buffer.writeln('Total Active Users,${analytics.totalActiveUsers},${analytics.activeUsersGrowth},${analytics.isLiveAtlasConnected ? "MongoDB Atlas" : "Platform Baseline (*)"}');
    buffer.writeln('Average Session Duration,${analytics.avgSessionDuration},${analytics.sessionDurationGrowth},Platform Baseline (*)');
    buffer.writeln('System Health,${analytics.systemHealth},${analytics.systemHealthStatus},Active Operational');
    buffer.writeln('');

    buffer.writeln('--- 2. USER ENGAGEMENT (DAU/MAU) ---');
    buffer.writeln('Metric,Value');
    buffer.writeln('Engagement Ratio,${analytics.engagement.headline}');
    buffer.writeln('Daily Active Users (DAU),${analytics.engagement.dailyActiveUsers}');
    buffer.writeln('Monthly Active Users (MAU),${analytics.engagement.monthlyActiveUsers}');
    buffer.writeln('Summary Note,${analytics.engagement.description}');
    buffer.writeln('');

    buffer.writeln('--- 3. PLACEMENT CONVERSION FUNNEL ---');
    buffer.writeln('Stage,Conversion Rate,Candidates Count');
    for (final stage in analytics.placementFunnel) {
      buffer.writeln('${stage.stage},${stage.percent}%,${stage.count}');
    }
    buffer.writeln('');

    buffer.writeln('--- 4. TOP CONTENT ROADMAPS ENROLLMENTS ---');
    buffer.writeln('Roadmap Track,Enrolled Candidates,Active Benchmark');
    for (final track in analytics.contentRoadmaps) {
      buffer.writeln('${track.fullLabel},${track.value},${track.isActive ? "ACTIVE BENCHMARK" : "STANDARD"}');
    }
    buffer.writeln('');

    buffer.writeln('--- 5. WEEKLY USER GROWTH TRAJECTORY ---');
    buffer.writeln('Timeline,Registrations,Count');
    for (final point in analytics.growthTrajectory) {
      buffer.writeln('${point.week},${point.label},${point.count}');
    }

    return buffer.toString();
  }

  /// Exports Platform Analytics to a CSV file in the local device Documents folder
  static Future<ExportResult> exportPlatformAnalyticsToCsv(
    AdminPlatformAnalyticsDto analytics,
  ) async {
    try {
      final csvData = generateAnalyticsCsv(analytics);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'admin_platform_analytics_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: analytics.placementFunnel.length + analytics.contentRoadmaps.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  /// Generates CSV string for Support Tickets
  static String generateSupportTicketsCsv(List<AdminSupportTicketModel> tickets) {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Requester,Organization,Priority,Type,Status,SLA,Created,Assigned To');

    for (final t in tickets) {
      final id = _escapeCsv(t.id);
      final title = _escapeCsv(t.title);
      final req = _escapeCsv(t.requester);
      final org = _escapeCsv(t.organization);
      final priority = _escapeCsv(t.priority);
      final type = _escapeCsv(t.type);
      final status = _escapeCsv(t.status);
      final sla = _escapeCsv(t.sla);
      final created = _escapeCsv(t.created);
      final assigned = _escapeCsv(t.assignedTo ?? 'Unassigned');

      buffer.writeln('$id,$title,$req,$org,$priority,$type,$status,$sla,$created,$assigned');
    }

    return buffer.toString();
  }

  /// Exports Support Tickets to CSV file
  static Future<ExportResult> exportSupportTicketsToCsvFile(
    List<AdminSupportTicketModel> tickets,
  ) async {
    try {
      final csvData = generateSupportTicketsCsv(tickets);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'admin_support_tickets_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: tickets.length,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  /// Generates CSV data for Executive Dashboard Weekly Report
  static String generateDashboardWeeklyReportCsv({
    required AdminAnalyticsDto analytics,
    required PendingApprovalsDto approvals,
    required List<AdminActivityLogDto> activities,
    required List<TrafficDataPointDto> traffic,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('CAMPUS2CORPORATE - EXECUTIVE WEEKLY DASHBOARD REPORT');
    buffer.writeln('Generated At,${DateTime.now().toIso8601String()}');
    buffer.writeln('Data Source,${analytics.isMock ? "Simulated Baseline Dataset (*)" : "Live MongoDB Atlas"}');
    buffer.writeln('');

    buffer.writeln('--- 1. CORE PLATFORM METRICS ---');
    buffer.writeln('Metric,Count,Growth / Benchmark');
    buffer.writeln('Total Students,${analytics.totalStudents},${analytics.studentsGrowth}');
    buffer.writeln('Colleges Onboarded,${analytics.totalColleges},Verified Partners');
    buffer.writeln('Recruiter Accounts,${analytics.totalRecruiters},${analytics.recruitersGrowth}');
    buffer.writeln('Active Job Postings,${analytics.totalProjects},Live Listings');
    buffer.writeln('Roadmaps Completed,${analytics.roadmapsDone},Platform Track');
    buffer.writeln('Platform MRR Revenue,${analytics.mrrRevenue},Enterprise Run-Rate');
    buffer.writeln('');

    buffer.writeln('--- 2. PENDING OVERSIGHT QUEUE ---');
    buffer.writeln('Queue Category,Pending Count,Priority Level');
    buffer.writeln('New College Onboarding,${approvals.collegePending},High Priority');
    buffer.writeln('Recruiter Verification,${approvals.recruiterUrgent},Urgent');
    buffer.writeln('Broadcast Drafts,${approvals.broadcastDrafts},Standard');
    buffer.writeln('');

    buffer.writeln('--- 3. 30-DAY TRAFFIC VOLUME ---');
    buffer.writeln('Timeline / Label,Platform Traffic Volume');
    for (final point in traffic) {
      buffer.writeln('${point.label},${point.displayVal.isNotEmpty ? point.displayVal : point.value}');
    }
    buffer.writeln('');

    buffer.writeln('--- 4. LIVE PLATFORM ACTIVITY STREAM ---');
    buffer.writeln('Timestamp / Recency,Activity Event');
    for (final act in activities) {
      final msgEscaped = '"${act.message.replaceAll('"', '""')}"';
      buffer.writeln('${act.timeAgo},$msgEscaped');
    }

    return buffer.toString();
  }

  /// Exports Executive Weekly Dashboard Report to CSV file
  static Future<ExportResult> exportDashboardWeeklyReportToCsv({
    required AdminAnalyticsDto analytics,
    required PendingApprovalsDto approvals,
    required List<AdminActivityLogDto> activities,
    required List<TrafficDataPointDto> traffic,
  }) async {
    try {
      final csvData = generateDashboardWeeklyReportCsv(
        analytics: analytics,
        approvals: approvals,
        activities: activities,
        traffic: traffic,
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'executive_dashboard_report_$timestamp.csv';

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      return ExportResult(
        success: true,
        filePath: file.path,
        fileName: fileName,
        count: activities.length + traffic.length + 6,
        csvContent: csvData,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        filePath: '',
        fileName: '',
        count: 0,
        csvContent: '',
        errorMessage: 'Failed to export CSV: ${e.toString()}',
      );
    }
  }

  /// Opens the exported file with the native system app (Excel / Sheets / CSV viewer)
  static Future<void> openExportedFile(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (_) {}
  }

  /// Copies CSV content to clipboard
  static Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  static String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
