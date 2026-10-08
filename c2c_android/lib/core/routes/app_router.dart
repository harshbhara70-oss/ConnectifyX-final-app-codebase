import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';

import '../../features/student/presentation/pages/student_dashboard_page.dart';
import '../../features/student/presentation/pages/ai_resume_page.dart';
import '../../features/student/presentation/pages/student_notifications_page.dart';
import '../../features/student/presentation/pages/student_applied_projects_page.dart';
import '../../features/student/presentation/pages/student_hiring_process_page.dart';
import '../../features/student/presentation/pages/student_certificates_page.dart';
import '../../features/student/presentation/pages/student_settings_page.dart';
import '../../features/student/presentation/pages/student_profile_page.dart';
import '../../features/student/presentation/pages/student_project_list_page.dart';
import '../../features/student/presentation/pages/ask_ai_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_user_management_page.dart';
import '../../features/admin/presentation/pages/admin_content_hub_page.dart';
import '../../features/admin/presentation/pages/admin_placement_oversight_page.dart';
import '../../features/admin/presentation/pages/admin_verification_queue_page.dart';
import '../../features/admin/presentation/pages/admin_broadcast_control_page.dart';
import '../../features/admin/presentation/pages/admin_platform_analytics_page.dart';
import '../../features/admin/presentation/pages/admin_support_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/mentor/presentation/pages/mentor_dashboard_page.dart';
import '../../features/mentor/presentation/pages/mentor_student_analytics_page.dart';
import '../../features/mentor/presentation/pages/mentor_session_timeline_page.dart';
import '../../features/mentor/presentation/pages/mentor_employability_matrix_page.dart';
import '../../features/mentor/presentation/pages/mentor_activity_leaderboard_page.dart';
import '../../features/mentor/presentation/pages/mentor_study_material_page.dart';
import '../../features/mentor/presentation/pages/mentor_career_roadmaps_page.dart';
import '../../features/mentor/presentation/pages/mentor_communication_page.dart';
import '../../features/mentor/presentation/pages/mentor_feedback_page.dart';
import '../../features/mentor/presentation/pages/mentor_profile_page.dart';
import '../../features/mentor/presentation/pages/mentor_settings_page.dart';
import '../../features/recruiter/presentation/pages/recruiter_dashboard_page.dart';
import '../../features/recruiter/presentation/pages/post_job_page.dart';
import '../../features/recruiter/presentation/pages/my_job_postings_page.dart';
import '../../features/recruiter/presentation/pages/applications_reports_page.dart';
import '../../features/recruiter/presentation/pages/pipeline_management_page.dart';
import '../../features/recruiter/presentation/pages/recruiter_messages_page.dart';
import '../../features/recruiter/presentation/pages/recruiter_settings_page.dart';
import '../../features/recruiter/presentation/pages/company_profile_admin_review_page.dart';

// College Module Page Imports
import '../../features/college/presentation/pages/college_dashboard_page.dart';
import '../../features/college/presentation/pages/student_records_page.dart';
import '../../features/college/presentation/pages/college_student_detail_page.dart';
import '../../features/college/presentation/pages/placement_hub_page.dart';
import '../../features/college/presentation/pages/job_pipeline_page.dart';
import '../../features/college/presentation/pages/company_insights_page.dart';
import '../../features/college/presentation/pages/departmental_analytics_page.dart';
import '../../features/college/presentation/pages/department_comparison_page.dart';
import '../../features/college/presentation/pages/student_readiness_analytics_page.dart';
import '../../features/college/presentation/pages/at_risk_students_page.dart';
import '../../features/college/presentation/pages/placement_intelligence_page.dart';
import '../../features/college/presentation/pages/assessments_learning_page.dart';
import '../../features/college/presentation/pages/broadcast_center_page.dart';
import '../../features/college/presentation/pages/college_settings_page.dart';
import '../../features/college/presentation/pages/reports_admin_analytics_page.dart';
import '../../features/college/presentation/pages/recruiter_coordination_page.dart';
import '../../features/college/presentation/pages/batch_group_page.dart';
import '../../features/college/presentation/pages/batch_group_detail_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/auth/role-select',
    routes: [
      // Authentication Routes
      GoRoute(
        path: '/auth/role-select',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/auth/register/:role',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'student';
          return RegisterPage(role: role);
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // Role Dashboards & Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementPage(),
      ),
      GoRoute(
        path: '/admin/user-management',
        builder: (context, state) => const AdminUserManagementPage(),
      ),
      GoRoute(
        path: '/admin/content',
        builder: (context, state) => const AdminContentHubPage(),
      ),
      GoRoute(
        path: '/admin/content-hub',
        builder: (context, state) => const AdminContentHubPage(),
      ),
      GoRoute(
        path: '/admin/placements',
        builder: (context, state) => const AdminPlacementOversightPage(),
      ),
      GoRoute(
        path: '/admin/placement',
        builder: (context, state) => const AdminPlacementOversightPage(),
      ),
      GoRoute(
        path: '/admin/placement-oversight',
        builder: (context, state) => const AdminPlacementOversightPage(),
      ),
      GoRoute(
        path: '/admin/verifications',
        builder: (context, state) => const AdminVerificationQueuePage(),
      ),
      GoRoute(
        path: '/admin/verification',
        builder: (context, state) => const AdminVerificationQueuePage(),
      ),
      GoRoute(
        path: '/admin/verification-queue',
        builder: (context, state) => const AdminVerificationQueuePage(),
      ),
      GoRoute(
        path: '/admin/broadcast',
        builder: (context, state) => const AdminBroadcastControlPage(),
      ),
      GoRoute(
        path: '/admin/broadcast-control',
        builder: (context, state) => const AdminBroadcastControlPage(),
      ),
      GoRoute(
        path: '/admin/communications',
        builder: (context, state) => const AdminBroadcastControlPage(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminPlatformAnalyticsPage(),
      ),
      GoRoute(
        path: '/admin/platform-analytics',
        builder: (context, state) => const AdminPlatformAnalyticsPage(),
      ),
      GoRoute(
        path: '/admin/support',
        builder: (context, state) => const AdminSupportPage(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsPage(),
      ),
      // Mentor Module Routes (11 Views)
      GoRoute(
        path: '/mentor/dashboard',
        builder: (context, state) => const MentorDashboardPage(),
      ),
      GoRoute(
        path: '/mentor/students',
        builder: (context, state) => const MentorStudentAnalyticsPage(),
      ),
      GoRoute(
        path: '/mentor/student-analytics',
        builder: (context, state) => const MentorStudentAnalyticsPage(),
      ),
      GoRoute(
        path: '/mentor/analytics',
        builder: (context, state) => const MentorStudentAnalyticsPage(),
      ),
      GoRoute(
        path: '/mentor/sessions',
        builder: (context, state) => const MentorSessionTimelinePage(),
      ),
      GoRoute(
        path: '/mentor/session-timeline',
        builder: (context, state) => const MentorSessionTimelinePage(),
      ),
      GoRoute(
        path: '/mentor/timeline',
        builder: (context, state) => const MentorSessionTimelinePage(),
      ),
      GoRoute(
        path: '/mentor/employability',
        builder: (context, state) => const MentorEmployabilityMatrixPage(),
      ),
      GoRoute(
        path: '/mentor/skills',
        builder: (context, state) => const MentorEmployabilityMatrixPage(),
      ),
      GoRoute(
        path: '/mentor/activity',
        builder: (context, state) => const MentorActivityLeaderboardPage(),
      ),
      GoRoute(
        path: '/mentor/leaderboard',
        builder: (context, state) => const MentorActivityLeaderboardPage(),
      ),
      GoRoute(
        path: '/mentor/activity-leaderboard',
        builder: (context, state) => const MentorActivityLeaderboardPage(),
      ),
      GoRoute(
        path: '/mentor/resources',
        builder: (context, state) => const MentorStudyMaterialPage(),
      ),
      GoRoute(
        path: '/mentor/study-material',
        builder: (context, state) => const MentorStudyMaterialPage(),
      ),
      GoRoute(
        path: '/mentor/roadmaps',
        builder: (context, state) => const MentorCareerRoadmapsPage(),
      ),
      GoRoute(
        path: '/mentor/career-roadmaps',
        builder: (context, state) => const MentorCareerRoadmapsPage(),
      ),
      GoRoute(
        path: '/mentor/communication',
        builder: (context, state) => const MentorCommunicationPage(),
      ),
      GoRoute(
        path: '/mentor/communications',
        builder: (context, state) => const MentorCommunicationPage(),
      ),
      GoRoute(
        path: '/mentor/feedback',
        builder: (context, state) => const MentorFeedbackPage(),
      ),
      GoRoute(
        path: '/mentor/profile',
        builder: (context, state) => const MentorProfilePage(),
      ),
      GoRoute(
        path: '/mentor/settings',
        builder: (context, state) => const MentorSettingsPage(),
      ),
      GoRoute(
        path: '/recruiter/dashboard',
        builder: (context, state) => const RecruiterDashboardPage(),
      ),
      GoRoute(
        path: '/recruiter-dashboard',
        builder: (context, state) => const RecruiterDashboardPage(),
      ),
      GoRoute(
        path: '/recruiter/post-job',
        builder: (context, state) => const PostJobPage(),
      ),
      GoRoute(
        path: '/recruiter/my-postings',
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'];
          return MyJobPostingsPage(jobId: jobId);
        },
      ),
      // Alias for deep-link parity with jobId param route on mobile
      GoRoute(
        path: '/recruiter/my-postings/:jobId',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId'];
          return MyJobPostingsPage(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/recruiter/applications',
        builder: (context, state) => const ApplicationsReportsPage(),
      ),
      GoRoute(
        path: '/recruiter/applications-reports',
        builder: (context, state) => const ApplicationsReportsPage(),
      ),
      GoRoute(
        path: '/recruiter-applications',
        builder: (context, state) => const ApplicationsReportsPage(),
      ),
      GoRoute(
        path: '/recruiter/shortlisted-candidates',
        builder: (context, state) => const PipelineManagementPage(),
      ),
      GoRoute(
        path: '/recruiter/pipeline',
        builder: (context, state) => const PipelineManagementPage(),
      ),
      GoRoute(
        path: '/recruiter-shortlisted',
        builder: (context, state) => const PipelineManagementPage(),
      ),
      GoRoute(
        path: '/recruiter/messages',
        builder: (context, state) => const RecruiterMessagesPage(),
      ),
      GoRoute(
        path: '/recruiter-messages',
        builder: (context, state) => const RecruiterMessagesPage(),
      ),
      GoRoute(
        path: '/recruiter/settings',
        builder: (context, state) => const RecruiterSettingsPage(),
      ),
      GoRoute(
        path: '/recruiter-settings',
        builder: (context, state) => const RecruiterSettingsPage(),
      ),
      GoRoute(
        path: '/recruiter/admin-review',
        builder: (context, state) => const CompanyProfileAdminReviewPage(),
      ),
      GoRoute(
        path: '/recruiter/under-review',
        builder: (context, state) => const CompanyProfileAdminReviewPage(),
      ),
      GoRoute(
        path: '/recruiter/verification',
        builder: (context, state) => const CompanyProfileAdminReviewPage(),
      ),

      // Student Module Routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardPage(),
      ),
      GoRoute(
        path: '/student/projects',
        builder: (context, state) => const StudentProjectListPage(),
      ),
      GoRoute(
        path: '/student/project-list',
        builder: (context, state) => const StudentProjectListPage(),
      ),
      GoRoute(
        path: '/student/directory',
        builder: (context, state) => const StudentRecordsPage(),
      ),
      GoRoute(
        path: '/student/ai-resume',
        builder: (context, state) => const StudentAIResumePage(),
      ),
      GoRoute(
        path: '/student/ai-resume-builder',
        builder: (context, state) => const StudentAIResumePage(),
      ),
      GoRoute(
        path: '/student/notifications',
        builder: (context, state) => const StudentNotificationsPage(),
      ),
      GoRoute(
        path: '/student/applied-projects',
        builder: (context, state) => const StudentAppliedProjectsPage(),
      ),
      GoRoute(
        path: '/student/hiring-process',
        builder: (context, state) => const StudentHiringProcessPage(),
      ),
      GoRoute(
        path: '/student/certificates',
        builder: (context, state) => const StudentCertificatesPage(),
      ),
      GoRoute(
        path: '/student/settings',
        builder: (context, state) => const StudentSettingsPage(),
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) => const StudentProfilePage(),
      ),
      GoRoute(
        path: '/student/ask-ai',
        builder: (context, state) => const AskAiPage(),
      ),
      GoRoute(
        path: '/student/ai-coach',
        builder: (context, state) => const AskAiPage(),
      ),

      // ==========================================
      // College Module Routes (Screens 1 to 15)
      // ==========================================

      // Screen 1: Executive Overview / College Dashboard
      GoRoute(
        path: '/college/dashboard',
        builder: (context, state) => const CollegeDashboardPage(),
      ),

      // Screen 2: Student Records — recreated from web StudentRecordsView
      GoRoute(
        path: '/college/students',
        builder: (context, state) => const StudentRecordsPage(),
      ),

      // Screen 10: At-Risk Students (Registered before :id parameter route)
      GoRoute(
        path: '/college/students/at-risk',
        builder: (context, state) => const AtRiskStudentsPage(),
      ),

      // Screen 3: Student Profile & AI Resume Detail — hero + fastOutSlowIn
      GoRoute(
        path: '/college/students/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 's1';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: CollegeStudentDetailPage(studentId: id),
            transitionsBuilder: (ctx, animation, secondary, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      // Screen 4: Placement Hub / Coordinator Hub
      GoRoute(
        path: '/college/drives',
        builder: (context, state) => const PlacementHubPage(),
      ),
      GoRoute(
        path: '/college/placements',
        builder: (context, state) => const PlacementHubPage(),
      ),
      GoRoute(
        path: '/college/placement-management',
        builder: (context, state) => const PlacementHubPage(),
      ),

      // Screen 5: Job Pipeline Tracker
      GoRoute(
        path: '/college/drives/:id/pipeline',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'd1';
          return JobPipelinePage(driveId: id);
        },
      ),

      // Screen 6: Company & Recruiter Insights
      GoRoute(
        path: '/college/companies/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'c1';
          return CompanyInsightsPage(companyId: id);
        },
      ),

      // Screen 7: Departmental Analytics
      GoRoute(
        path: '/college/analytics/department',
        builder: (context, state) => const DepartmentalAnalyticsPage(),
      ),

      // Screen 8: Department Comparison
      GoRoute(
        path: '/college/analytics/compare',
        builder: (context, state) => const DepartmentComparisonPage(),
      ),

      // Screen 9: Student Readiness Analytics
      GoRoute(
        path: '/college/analytics/readiness',
        builder: (context, state) => const StudentReadinessAnalyticsPage(),
      ),

      // Screen 11: Placement Intelligence
      GoRoute(
        path: '/college/analytics/intelligence',
        builder: (context, state) => const PlacementIntelligencePage(),
      ),

      // Screen 12: Assessments & Learning Analytics
      GoRoute(
        path: '/college/analytics/assessments',
        builder: (context, state) => const AssessmentsLearningPage(),
      ),

      // Screen 13: Communication / Broadcast Center
      GoRoute(
        path: '/college/operations/communication',
        builder: (context, state) => const BroadcastCenterPage(),
      ),
      GoRoute(
        path: '/college/broadcast',
        builder: (context, state) => const BroadcastCenterPage(),
      ),

      // Screen 14: Institutional Configuration / Settings
      GoRoute(
        path: '/college/operations/config',
        builder: (context, state) => const CollegeSettingsPage(),
      ),
      GoRoute(
        path: '/college/settings',
        builder: (context, state) => const CollegeSettingsPage(),
      ),

      // Screen 15: Reports & Admin Analytics
      GoRoute(
        path: '/college/reports',
        builder: (context, state) => const ReportsAdminAnalyticsPage(),
      ),

      // Route 5: Recruiter Coordination (fully redesigned screen)
      GoRoute(
        path: '/college/recruiters',
        builder: (context, state) => const RecruiterCoordinationPage(),
      ),
      GoRoute(
        path: '/college/recruiter-coordination',
        builder: (context, state) => const RecruiterCoordinationPage(),
      ),
      GoRoute(
        path: '/college/corporate-partners',
        builder: (context, state) => const RecruiterCoordinationPage(),
      ),

      // Route 6: Batch Groups
      GoRoute(
        path: '/college/batches',
        builder: (context, state) => const BatchGroupPage(),
      ),
      GoRoute(
        path: '/college/batches/:batchId',
        builder: (context, state) {
          final batchId = state.pathParameters['batchId'] ?? '';
          return BatchGroupDetailPage(batchId: batchId);
        },
      ),

      // Placements Alias
      GoRoute(
        path: '/college/placements',
        builder: (context, state) => const PlacementHubPage(),
      ),
    ],
  );
}
