import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/admin_dashboard_bloc.dart';
import '../../bloc/admin_dashboard_event.dart';
import '../../bloc/admin_dashboard_state.dart';
import '../widgets/admin_activity_stream.dart';
import '../widgets/admin_command_center_modal.dart';
import '../widgets/admin_metric_card.dart';
import '../widgets/admin_pending_approvals_card.dart';
import '../widgets/admin_quick_actions_card.dart';
import '../widgets/admin_shimmer_skeleton.dart';
import '../widgets/admin_sidebar_drawer.dart';
import '../widgets/admin_system_health_banner.dart';
import '../widgets/admin_traffic_chart.dart';
import '../../data/services/admin_csv_exporter.dart';

/// Production-ready, highly optimized Admin Dashboard Page for Campus2Corporate.
/// Implements responsive grid architectures, zero-overflow RenderBox safety,
/// side navigation panel, and dynamic Asterisk (*) indicators for pending backend endpoints.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc()..add(const FetchAdminDashboardData()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to end your current administrator session?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.lightImpact();
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/auth/role-select');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  void _showExportSuccessSheet(BuildContext context, ExportResult result) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.paddingOf(ctx).bottom;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: EdgeInsets.only(
                left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                top: 14,
                bottom: bottomInset > 0 ? 8 : 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.fileSpreadsheet, color: Color(0xFF16A34A), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report Generated!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              result.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // File Location Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAVED LOCATION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.filePath,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.firaCode(
                            fontSize: 11,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Open File Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.openExportedFile(result.filePath);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: Text(
                        'Open in Excel / CSV Viewer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Copy to Clipboard Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        AdminCsvExporter.copyToClipboard(result.csvContent);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'CSV data copied to clipboard!',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.copy, size: 16),
                      label: Text(
                        'Copy CSV to Clipboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/auth/role-select');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AdminSidebarDrawer(),
        body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
          listener: (context, state) {
            if (state is AdminDashboardLoaded) {
              if (state.exportResult != null) {
                _showExportSuccessSheet(context, state.exportResult!);
              } else if (state.toastNotification != null) {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.toastNotification!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.cardDark,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            if (state is AdminDashboardLoading || state is AdminDashboardInitial) {
              return const SafeArea(bottom: true, child: AdminShimmerSkeleton());
            }

            if (state is AdminDashboardError) {
              return SafeArea(
                bottom: true,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          size: 44,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Unable to Load Dashboard',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context
                                .read<AdminDashboardBloc>()
                                .add(const FetchAdminDashboardData());
                          },
                          icon: const Icon(LucideIcons.refreshCw, size: 15),
                          label: Text(
                            'Try Again',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final loaded = state as AdminDashboardLoaded;
            final analytics = loaded.analytics;
            final approvals = loaded.pendingApprovals;

            return SafeArea(
              bottom: true,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context
                      .read<AdminDashboardBloc>()
                      .add(const FetchAdminDashboardData(isRefresh: true));
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: bottomPadding == 0 ? 16.0 : bottomPadding,
                    top: 16.0,
                    left: (screenWidth * 0.045).clamp(12.0, 20.0),
                    right: (screenWidth * 0.045).clamp(12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Admin Header Bar with Hamburger Drawer & Back Navigation
                      _buildHeaderBar(context, screenWidth: screenWidth),
                      const SizedBox(height: 14),

                      // 2. Command / Search Trigger Modal
                      _buildSearchTrigger(context),
                      const SizedBox(height: 14),

                      // 3. System Health Banner (Atlas Live Connectivity)
                      AdminSystemHealthBanner(screenWidth: screenWidth),
                      const SizedBox(height: 16),

                      // 4. Section Heading: Core Platform Metrics
                      _buildSectionHeader('CORE PLATFORM METRICS', LucideIcons.layoutGrid, screenWidth: screenWidth),
                      const SizedBox(height: 10),

                      // 5. Equal Dimensions KPI Metrics Grid (2x3 responsive cards with ample breathing room)
                      _buildEqualDimensionsMetricsGrid(
                        context,
                        analytics: analytics,
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 16),

                      // 6. Pending Verifications Oversight Card
                      AdminPendingApprovalsCard(approvals: approvals),
                      const SizedBox(height: 16),

                      // 7. Quick Operations & Simulated Broadcast Actions Card
                      AdminQuickActionsCard(
                        isApprovedAll: loaded.isApprovedAll,
                        isExporting: loaded.isExporting,
                        onApproveAll: () {
                          context
                              .read<AdminDashboardBloc>()
                              .add(const ApproveAllRequested());
                        },
                        onSendBroadcast: (msg) {
                          context
                              .read<AdminDashboardBloc>()
                              .add(SendBroadcastRequested(msg));
                        },
                        onExportReport: () {
                          context
                              .read<AdminDashboardBloc>()
                              .add(const ExportReportRequested());
                        },
                      ),
                      const SizedBox(height: 16),

                      // 8. Traffic Overview (30 Days) Line Chart
                      AdminTrafficChart(
                        trafficData: loaded.trafficData,
                        selectedPlatform: loaded.selectedPlatform,
                        onPlatformChanged: (platform) {
                          context
                              .read<AdminDashboardBloc>()
                              .add(ChangePlatformFilter(platform));
                        },
                      ),
                      const SizedBox(height: 16),

                      // 9. Live Activity Stream Audit Log
                      AdminActivityStream(activities: loaded.activities),
                      const SizedBox(height: 20),

                      // 10. Footer Metadata & Copyright
                      _buildFooterMetadata(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {required double screenWidth}) {
    final sectionFontSize = (screenWidth * 0.042).clamp(14.0, 16.0);
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: sectionFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBar(BuildContext context, {required double screenWidth}) {
    final headerFontSize = (screenWidth * 0.052).clamp(18.0, 22.0);

    return Row(
      children: [
        // Side Navigation Drawer Toggle Button (Hamburger Menu)
        Builder(
          builder: (drawerCtx) => Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Scaffold.of(drawerCtx).openDrawer();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.menu,
                    size: 19,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Title Branding & Overview Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'C2C PLATFORM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Overview Dashboard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: headerFontSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Action Icons: Logout
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => _showLogoutDialog(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.logOut,
                  size: 17,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTrigger(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          AdminCommandCenterModal.show(
            context,
            onSelectRoute: (route, title) {
              if (route == '/admin/dashboard') return;
              context.go(route);
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x04000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.search,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search platform directory...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.command,
                      size: 10,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'K',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Responsive Grid of 6 KPI cards with equal dimensions, comfortable space, and zero-overflow guarantees.
  Widget _buildEqualDimensionsMetricsGrid(
    BuildContext context, {
    required dynamic analytics,
    required double screenWidth,
  }) {
    final isMockAnalytics = analytics.isMock as bool;
    final studentsDisplay = isMockAnalytics
        ? '142.5k'
        : _formatCount(analytics.totalStudents as int);
    final collegesDisplay = isMockAnalytics
        ? '342'
        : (analytics.totalColleges as int).toString();
    final recruitersDisplay = isMockAnalytics
        ? '1,284'
        : _formatCount(analytics.totalRecruiters as int);
    final jobsDisplay = isMockAnalytics
        ? '8,492'
        : _formatCount(analytics.activeProjects as int);

    // Cards data definition
    final List<Map<String, dynamic>> kpis = [
      {
        'label': 'Students',
        'value': studentsDisplay,
        'subtitle': analytics.studentsGrowth,
        'icon': LucideIcons.graduationCap,
        'showTrendIcon': true,
        'isTrendPositive': true,
        'isMock': isMockAnalytics, // Realtime from MongoDB Atlas (/admin/dashboard)
        'onTap': () => context.go('/admin/users'),
      },
      {
        'label': 'Colleges',
        'value': collegesDisplay,
        'subtitle': 'Active partners',
        'icon': LucideIcons.landmark,
        'showTrendIcon': false,
        'isTrendPositive': false,
        'isMock': isMockAnalytics, // Realtime from MongoDB Atlas (/admin/dashboard)
        'onTap': () => context.go('/admin/users'),
      },
      {
        'label': 'Recruiters',
        'value': recruitersDisplay,
        'subtitle': analytics.recruitersGrowth,
        'icon': LucideIcons.briefcase,
        'showTrendIcon': true,
        'isTrendPositive': true,
        'isMock': isMockAnalytics, // Realtime from MongoDB Atlas (/admin/dashboard)
        'onTap': () => context.go('/admin/users'),
      },
      {
        'label': 'Active Jobs',
        'value': jobsDisplay,
        'subtitle': 'Across 45 sectors',
        'icon': LucideIcons.clipboardList,
        'showTrendIcon': false,
        'isTrendPositive': false,
        'isMock': isMockAnalytics, // Realtime from MongoDB Atlas (/admin/dashboard)
        'onTap': () => context.go('/admin/placement-oversight'),
      },
      {
        'label': 'Roadmaps',
        'value': analytics.roadmapsDone,
        'subtitle': 'High completion',
        'icon': LucideIcons.bookOpen,
        'showTrendIcon': false,
        'isTrendPositive': true,
        'isMock': true, // Mock (No /admin/roadmaps aggregation endpoint yet)
        'onTap': () => context.go('/admin/content'),
      },
      {
        'label': 'MRR Revenue',
        'value': analytics.mrrRevenue,
        'subtitle': 'Target exceeded',
        'icon': LucideIcons.dollarSign,
        'showTrendIcon': true,
        'isTrendPositive': true,
        'isMock': true, // Mock (No /admin/financials endpoint yet)
        'onTap': null,
      },
    ];

    // Responsive aspect ratio calibrated for tall, spacious cards with 0 truncation
    final isSmallScreen = screenWidth < 360;
    final childAspectRatio = isSmallScreen ? 0.94 : 1.02;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final item = kpis[index];
        return AdminMetricCard(
          label: item['label'] as String,
          value: item['value'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          showTrendIcon: item['showTrendIcon'] as bool,
          isTrendPositive: item['isTrendPositive'] as bool,
          isMock: item['isMock'] as bool,
          onTap: item['onTap'] as VoidCallback?,
        );
      },
    );
  }

  Widget _buildFooterMetadata(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 14),
        Center(
          child: Text(
            '© 2026 Campus2Corporate • Administration & Oversight Network',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('Privacy Policy'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
            _buildFooterLink('Terms of Service'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
            _buildFooterLink('Atlas API Status'),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
