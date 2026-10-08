class ApiEndpoints {
  static const String _overrideUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Backend base URL (Render backend).
  ///
  /// Override anytime with `--dart-define=API_BASE_URL=http://<LAN-IP>:5000/api`
  /// (e.g. for a physical device or when testing locally).
  static String get baseUrl {
    if (_overrideUrl.isNotEmpty) return _overrideUrl;
    return 'https://c2c-latest-backend-000333.onrender.com/api';
  }

  // Auth Endpoints (Student / General)
  static const String login = '/auth/login';
  static const String login2faVerify = '/auth/2fa/verify';
  static const String loginReactivate = '/auth/reactivate';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Admin Auth Endpoints
  static const String adminLogin = '/admin/login';
  static const String adminRegister = '/admin/register';

  // College Auth Endpoints
  static const String collegeLogin = '/college/login';
  static const String collegeRegister = '/college/register';

  // Student
  static const String studentProfile = '/student/profile';
  static const String aiResume = '/student/ai-resume';
  static const String assessments = '/student/assessments';

  // College TPO
  static const String collegeDashboard = '/college/dashboard';
  static const String collegeStudents = '/college/students';
  static const String collegeEligibleStudents = '/college/students/eligible';
  static const String collegeProjects = '/college/projects';
  static const String collegeApplications = '/college/applications';

  // College Analytics - Assessments
  static const String collegeAssessments = '/college/analytics/assessments';
  static const String collegeAssessmentDetail = '/college/analytics/assessments/detail';

  // College Operations - Communication
  static const String collegeCommunication = '/college/operations/communication';
  static const String collegeBroadcast = '/college/operations/communication/broadcast';

  // College Operations - Configuration / Profile
  static const String collegeConfig = '/college/profile';
  static const String collegeConfigBranding = '/college/profile';
  static const String collegeConfigSecurity = '/college/profile';

  // College Recruiter Coordination
  // NOTE: The college role has no recruiter routes in `backend/src/routes/collegeRoutes.js`
  // yet. The service below still attempts these routes and gracefully falls back
  // to the seed dataset (mirroring the web RecruiterManagement.tsx demo records).
  static const String collegeRecruiters = '/college/recruiters';
  static const String collegeRecruiterScheduleDrive = '/college/recruiters/drive';

  // College Reports & Analytics
  static const String collegeReports = '/college/reports';
  static const String collegeReportsExport = '/college/reports/export';

  // College Batch Groups
  static const String collegeBatches = '/college/batches';

  // Recruiter Endpoints
  static const String recruiterDashboard = '/recruiter/dashboard';
  static const String recruiterJobs = '/recruiter/jobs';
  static const String recruiterMyPostings = '/recruiter/jobs';
  static const String recruiterPostJob = '/recruiter/jobs';
  static const String recruiterPublishJob = '/recruiter/jobs/publish';
  static const String recruiterPipeline = '/recruiter/pipeline';
  static const String recruiterCandidates = '/recruiter/candidates';
  static const String recruiterApplications = '/recruiter/applications';
  static const String recruiterMessages = '/recruiter/messages';
  static const String recruiterSettings = '/recruiter/settings';
  static const String recruiterRequestEdit = '/recruiter/settings/request-edit';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminProfile = '/admin/profile';
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminStudents = '/admin/students';
  static const String adminColleges = '/admin/colleges';
  static const String adminRecruiters = '/admin/recruiters';
  static const String adminProjects = '/admin/projects';
  static const String adminRoadmaps = '/admin/roadmaps';
  static const String adminResources = '/admin/resources';
  static const String adminContent = '/admin/content';

  // Admin Placement Oversight Endpoints
  static const String adminPlacements = '/admin/placements';
  static const String adminPlacementDrives = '/admin/placements/drives';
  static const String adminPlacementEvents = '/admin/placements/events';
  static const String adminPlacementExport = '/admin/placements/export';

  // Admin Verification Queue Endpoints
  static const String adminVerifications = '/admin/verifications';
  static const String adminVerificationQueueStatus = '/admin/verifications/status';
  static const String adminVerificationApprove = '/admin/verifications/approve';
  static const String adminVerificationReject = '/admin/verifications/reject';
  static const String adminVerificationExport = '/admin/verifications/export';

  // Admin Broadcast Control Endpoints
  static const String adminBroadcasts = '/admin/broadcasts';
  static const String adminBroadcastSend = '/admin/broadcasts/send';
  static const String adminBroadcastDrafts = '/admin/broadcasts/drafts';
  static const String adminBroadcastCollegeOversight = '/admin/broadcasts/college-oversight';
  static const String adminBroadcastStats = '/admin/broadcasts/stats';
  static const String adminBroadcastExport = '/admin/broadcasts/export';

  // Admin Support Center Endpoints
  static const String adminSupport = '/admin/support';
  static const String adminSupportTickets = '/admin/support/tickets';
  static const String adminSupportReply = '/admin/support/tickets/reply';
  static const String adminSupportResolve = '/admin/support/tickets/resolve';
  static const String adminSupportExport = '/admin/support/export';

  // Admin Employability Matrix Endpoints
  static const String adminEmployabilityMatrix = '/admin/employability-matrix';
  static const String adminEmployabilityEvaluations = '/admin/employability/evaluations';
  static const String adminEmployabilityExport = '/admin/employability/export';

  // Admin Settings & Configuration Endpoints
  static const String adminSettings = '/admin/settings';
  static const String adminSettingsAiWeights = '/admin/settings/ai-weights';
  static const String adminSettingsMaintenance = '/admin/settings/maintenance';
  static const String adminSettingsIntegrations = '/admin/settings/integrations';
  static const String adminSettingsAuditLogs = '/admin/settings/audit-logs';

  // Mentor Module Endpoints
  static const String mentorDashboard = '/mentor/dashboard';
  static const String mentorStudents = '/mentor/students';
  static const String mentorSessions = '/mentor/sessions';
  static const String mentorFeedback = '/mentor/feedback';
  static const String mentorAnnouncements = '/mentor/announcements';
  static const String mentorResources = '/mentor/resources';
  static const String mentorAnalytics = '/mentor/analytics';
  static const String mentorEmployabilityMatrix = '/mentor/employability-matrix';
  static const String mentorEmployabilityEvaluate = '/mentor/employability/evaluate';
  static const String mentorActivityLeaderboard = '/mentor/activity-leaderboard';
  static const String mentorActivity = '/mentor/activity';
  static const String mentorLeaderboard = '/mentor/leaderboard';
  static const String mentorLeaderboardEvaluate = '/mentor/leaderboard/evaluate';
  static const String mentorCommunication = '/mentor/communication';
  static const String mentorMessages = '/mentor/messages';
  static const String mentorProfile = '/mentor/profile';
  static const String mentorProfileAvailability = '/mentor/profile/availability';
  static const String mentorSettings = '/mentor/settings';
  static const String mentorPasswordReset = '/mentor/settings/password-reset';
}



