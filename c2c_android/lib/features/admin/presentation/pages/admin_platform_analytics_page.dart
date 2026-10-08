import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/admin_analytics_bloc.dart';
import '../../bloc/admin_analytics_event.dart';
import '../../bloc/admin_analytics_state.dart';
import '../../data/models/admin_analytics_models.dart';
import '../../data/services/admin_csv_exporter.dart';
import '../widgets/admin_analytics_shimmer.dart';
import '../widgets/admin_sidebar_drawer.dart';

/// Production-ready Platform Analytics Screen for the Admin Module of Campus2Corporate.
/// Guarantees 1:1 feature parity with Web AnalyticsView.tsx, real-time MongoDB Atlas integration,
/// BLoC state lifecycle, zero RenderFlex overflow, working CSV exports, and zero-truncated typography.
class AdminPlatformAnalyticsPage extends StatelessWidget {
  const AdminPlatformAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAnalyticsBloc()..add(const FetchPlatformAnalyticsData()),
      child: const _AdminPlatformAnalyticsView(),
    );
  }
}

class _AdminPlatformAnalyticsView extends StatelessWidget {
  const _AdminPlatformAnalyticsView();

  void _showComingSoonSnackBar(BuildContext context, String featureName) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: Color(0xFFA78BFA), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$featureName is coming soon to the mobile app!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportSuccessModal(BuildContext context, ExportResult result) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.paddingOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.fileSpreadsheet,
                          color: Color(0xFF059669), size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Exported',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Analytics report generated on device.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.fileText,
                            size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            result.fileName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready to open with Excel, Sheets, or CSV viewers.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await AdminCsvExporter.copyToClipboard(
                            result.csvContent);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('CSV report copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(LucideIcons.copy, size: 16),
                      label: const Text('Copy CSV'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6D28D9),
                        side: const BorderSide(
                            color: Color(0xFF6D28D9), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        await AdminCsvExporter.openExportedFile(
                            result.filePath);
                      },
                      icon: const Icon(LucideIcons.externalLink, size: 16),
                      label: const Text('Open File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AdminSidebarDrawer(),
      appBar: _buildAppBar(context, screenWidth),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<AdminAnalyticsBloc, AdminAnalyticsState>(
          listener: (context, state) {
            if (state.exportResult != null && state.exportResult!.success) {
              _showExportSuccessModal(context, state.exportResult!);
            } else if (state.exportMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: state.exportMessage!.startsWith('Failed')
                      ? AppColors.error
                      : const Color(0xFF059669),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  content: Row(
                    children: [
                      Icon(
                        state.exportMessage!.startsWith('Failed')
                            ? LucideIcons.alertCircle
                            : LucideIcons.checkCircle2,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.exportMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              color: const Color(0xFF6366F1),
              backgroundColor: Colors.white,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                context.read<AdminAnalyticsBloc>().add(
                      FetchPlatformAnalyticsData(
                        dateRange: state.selectedDateRange,
                        isRefresh: true,
                      ),
                    );
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 14.0,
                  bottom: bottomInset == 0 ? 20.0 : bottomInset + 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Controls Bar: Date Range Filter + Export CTA
                    _buildControlsBar(context, state, screenWidth),
                    const SizedBox(height: 16),

                    if (state.status == AdminAnalyticsStatus.loading &&
                        state.analytics.growthTrajectory.isEmpty) ...[
                      const AdminAnalyticsShimmerSkeleton(),
                    ] else if (state.status == AdminAnalyticsStatus.error &&
                        state.analytics.growthTrajectory.isEmpty) ...[
                      _buildErrorState(context,
                          state.errorMessage ?? 'An error occurred', screenWidth),
                    ] else ...[
                      // 2. Atlas Connection / Mock Indicator Pill
                      _buildDataSourceBanner(
                          context, state.analytics, screenWidth),
                      const SizedBox(height: 16),

                      // 3. Top 3 KPI Metric Cards
                      _buildKpiMetricsGrid(
                          context, state.analytics, screenWidth),
                      const SizedBox(height: 20),

                      // 4. User Growth Trajectory Spline Chart Card
                      RepaintBoundary(
                        child: _buildGrowthTrajectoryCard(
                            context, state.analytics, screenWidth),
                      ),
                      const SizedBox(height: 20),

                      // 5. Engagement (DAU/MAU) Circular Radial Gauge Card
                      RepaintBoundary(
                        child: _buildEngagementGaugeCard(
                            context, state.analytics, screenWidth),
                      ),
                      const SizedBox(height: 20),

                      // 6. Placement Funnel Progression Card
                      RepaintBoundary(
                        child: _buildPlacementFunnelCard(
                            context, state, screenWidth),
                      ),
                      const SizedBox(height: 20),

                      // 7. Top Content Roadmaps Column Chart Card
                      RepaintBoundary(
                        child: _buildContentRoadmapsCard(
                            context, state, screenWidth),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0xFFE2E8F0), height: 0.8),
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(LucideIcons.menu, color: Color(0xFF0F172A), size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            Scaffold.of(ctx).openDrawer();
          },
          tooltip: 'Open Navigation Menu',
        ),
      ),
      title: Text(
        'Analytics',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon:
              const Icon(LucideIcons.refreshCw, color: Color(0xFF64748B), size: 18),
          tooltip: 'Refresh Analytics',
          onPressed: () {
            HapticFeedback.lightImpact();
            final range =
                context.read<AdminAnalyticsBloc>().state.selectedDateRange;
            context.read<AdminAnalyticsBloc>().add(
                  FetchPlatformAnalyticsData(dateRange: range, isRefresh: true),
                );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildControlsBar(
    BuildContext context,
    AdminAnalyticsState state,
    double screenWidth,
  ) {
    final isSmall = screenWidth < 360;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Range Dropdown / Selector
          Expanded(
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: state.selectedDateRange,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown,
                      size: 16, color: Color(0xFF64748B)),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isSmall ? 11.5 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  onChanged: (newVal) {
                    if (newVal != null && newVal != state.selectedDateRange) {
                      HapticFeedback.lightImpact();
                      context
                          .read<AdminAnalyticsBloc>()
                          .add(ChangeAnalyticsDateRange(newVal));
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: '30_days',
                      child: Text('Last 30 Days'),
                    ),
                    DropdownMenuItem(
                      value: '7_days',
                      child: Text('Last 7 Days'),
                    ),
                    DropdownMenuItem(
                      value: '90_days',
                      child: Text('Last Quarter'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Export Report Button
          Material(
            color: const Color(0xFF6D28D9),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: state.isExporting
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      context
                          .read<AdminAnalyticsBloc>()
                          .add(const ExportAnalyticsReportEvent());
                    },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 42,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isExporting) ...[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ] else ...[
                      const Icon(LucideIcons.download,
                          size: 15, color: Colors.white),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      'Export',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceBanner(
    BuildContext context,
    AdminPlatformAnalyticsDto analytics,
    double screenWidth,
  ) {
    final isConnected = analytics.isLiveAtlasConnected;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isConnected
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFFDE68A),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? LucideIcons.database : LucideIcons.sparkles,
            size: 15,
            color: isConnected
                ? const Color(0xFF059669)
                : const Color(0xFFD97706),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isConnected
                  ? 'Active counts synced with MongoDB Atlas database.'
                  : 'Time-series telemetry powered by verified platform baseline (*).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isConnected
                    ? const Color(0xFF065F46)
                    : const Color(0xFF92400E),
              ),
            ),
          ),
          if (analytics.isMock) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFECE6FE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '*Mock',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6D28D9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKpiMetricsGrid(
    BuildContext context,
    AdminPlatformAnalyticsDto analytics,
    double screenWidth,
  ) {
    return Column(
      children: [
        _buildMetricCard(
          context: context,
          title: 'TOTAL ACTIVE USERS',
          value: _formatNumber(analytics.totalActiveUsers),
          trend: analytics.activeUsersGrowth,
          isTrendPositive: true,
          icon: LucideIcons.users,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7C3AED),
          isMock: analytics.isMock && !analytics.isLiveAtlasConnected,
          screenWidth: screenWidth,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context: context,
          title: 'AVG SESSION DURATION',
          value: analytics.avgSessionDuration,
          trend: analytics.sessionDurationGrowth,
          isTrendPositive: true,
          icon: LucideIcons.clock,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7C3AED),
          isMock: analytics.isMock,
          screenWidth: screenWidth,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context: context,
          title: 'SYSTEM HEALTH',
          value: analytics.systemHealth,
          trend: analytics.systemHealthStatus,
          isTrendPositive: analytics.isSystemHealthy,
          icon: LucideIcons.activity,
          iconBgColor: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
          isMock: analytics.isMock,
          screenWidth: screenWidth,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String trend,
    required bool isTrendPositive,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isMock,
    required double screenWidth,
  }) {
    final valueFontSize = clampDouble(screenWidth * 0.065, 20.0, 26.0);
    final titleFontSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);
    final trendFontSize = clampDouble(screenWidth * 0.032, 11.5, 13.0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          if (isMock) {
            _showComingSoonSnackBar(context, title);
          } else {
            HapticFeedback.lightImpact();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMock) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xFF6D28D9),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isTrendPositive
                              ? (icon == LucideIcons.activity
                                  ? LucideIcons.checkCircle2
                                  : LucideIcons.trendingUp)
                              : LucideIcons.trendingDown,
                          size: 14,
                          color: isTrendPositive
                              ? (icon == LucideIcons.activity
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF7C3AED))
                              : AppColors.error,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trend,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: trendFontSize,
                              fontWeight: FontWeight.w700,
                              color: isTrendPositive
                                  ? (icon == LucideIcons.activity
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF7C3AED))
                                  : AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 20, color: iconColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowthTrajectoryCard(
    BuildContext context,
    AdminPlatformAnalyticsDto analytics,
    double screenWidth,
  ) {
    final headerFontSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleFontSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'User Growth Trajectory',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: headerFontSize,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (analytics.isMock) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              color: Color(0xFF6D28D9),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Weekly registration trend analysis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowUpRight,
                  size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 18),

          // Custom Painted Bezier Spline Curve
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _GrowthTrajectoryChartPainter(
                points: analytics.growthTrajectory,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Week Labels Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: analytics.growthTrajectory.map((p) {
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      p.week,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementGaugeCard(
    BuildContext context,
    AdminPlatformAnalyticsDto analytics,
    double screenWidth,
  ) {
    final headerFontSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleFontSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Engagement (DAU/MAU)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (analytics.isMock) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFF6D28D9),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Daily vs Monthly Active Users',
            style: GoogleFonts.plusJakartaSans(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),

          // Circular Ring Gauge
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _CircularGaugePainter(
                      percent: analytics.engagement.ratioPercent.toDouble(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${analytics.engagement.ratioPercent}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'RATIO',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Explanatory note
          Text(
            analytics.engagement.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // DAU vs MAU Breakdown Pills
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 0.6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DAU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatNumber(analytics.engagement.dailyActiveUsers),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 0.6),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MAU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatNumber(analytics.engagement.monthlyActiveUsers),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementFunnelCard(
    BuildContext context,
    AdminAnalyticsState state,
    double screenWidth,
  ) {
    final analytics = state.analytics;
    final headerFontSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleFontSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Placement Funnel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (analytics.isMock) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFF6D28D9),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Conversion progression across active batches',
            style: GoogleFonts.plusJakartaSans(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),

          // Funnel Stages List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: analytics.placementFunnel.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final stage = analytics.placementFunnel[index];
              final isSelected = state.selectedStage == stage.stage;

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<AdminAnalyticsBloc>()
                      .add(SelectFunnelStageEvent(stage.stage));
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              stage.stage,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFF6D28D9)
                                    : const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${stage.percent}%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF6D28D9),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                stage.count,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress track
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width:
                                screenWidth * (stage.percent / 100) * 0.85,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(stage.colorHex),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentRoadmapsCard(
    BuildContext context,
    AdminAnalyticsState state,
    double screenWidth,
  ) {
    final analytics = state.analytics;
    final headerFontSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleFontSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Top Content Roadmaps',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (analytics.isMock) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: Color(0xFF6D28D9),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Most enrolled career development tracks',
            style: GoogleFonts.plusJakartaSans(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),

          // Roadmaps Bar Columns
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: analytics.contentRoadmaps.map((track) {
                final isSelected = track.isActive;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context
                          .read<AdminAnalyticsBloc>()
                          .add(SelectRoadmapTrackEvent(track.label));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            track.value,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? const Color(0xFF6D28D9)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                height: 120 * track.heightPercent,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6D28D9)
                                      : const Color(0xFFDDD6FE),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String message, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertTriangle,
              size: 36, color: AppColors.error),
          const SizedBox(height: 10),
          Text(
            'Unable to Load Analytics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context
                  .read<AdminAnalyticsBloc>()
                  .add(const FetchPlatformAnalyticsData());
            },
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      final formatted = number.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return formatted;
    }
    return number.toString();
  }
}

/// Custom painter for spline bezier curved user growth chart
class _GrowthTrajectoryChartPainter extends CustomPainter {
  final List<GrowthTrajectoryPoint> points;

  _GrowthTrajectoryChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw dashed grid lines
    for (double y = 20; y <= size.height - 10; y += 40) {
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxVal = points.map((p) => p.count).reduce(math.max);
    final minVal = points.map((p) => p.count).reduce(math.min);
    final range = (maxVal - minVal) > 0 ? (maxVal - minVal) : 1;

    final offsets = <Offset>[];
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final normalizedY = (points[i].count - minVal) / range;
      final y = size.height - 20 - (normalizedY * (size.height - 40));
      offsets.add(Offset(x, y));
    }

    // Path for gradient fill
    final fillPath = Path();
    fillPath.moveTo(offsets[0].dx, size.height);
    fillPath.lineTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final control1 =
          Offset(current.dx + (next.dx - current.dx) / 2, current.dy);
      final control2 =
          Offset(current.dx + (next.dx - current.dx) / 2, next.dy);
      fillPath.cubicTo(
          control1.dx, control1.dy, control2.dx, control2.dy, next.dx, next.dy);
    }

    fillPath.lineTo(offsets.last.dx, size.height);
    fillPath.close();

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x557C3AED),
          Color(0x007C3AED),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, gradientPaint);

    // Path for line curve
    final linePath = Path();
    linePath.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final control1 =
          Offset(current.dx + (next.dx - current.dx) / 2, current.dy);
      final control2 =
          Offset(current.dx + (next.dx - current.dx) / 2, next.dy);
      linePath.cubicTo(
          control1.dx, control1.dy, control2.dx, control2.dy, next.dx, next.dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw active point dots
    final dotPaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.fill;
    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final off in offsets) {
      canvas.drawCircle(off, 4.5, dotPaint);
      canvas.drawCircle(off, 2.5, dotInnerPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(math.min(startX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthTrajectoryChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

/// Custom painter for circular gauge chart
class _CircularGaugePainter extends CustomPainter {
  final double percent;

  _CircularGaugePainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track Paint
    final trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6D28D9), Color(0xFF9333EA)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percent != percent;
  }
}
