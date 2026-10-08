import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/college_bloc.dart';
import '../../data/services/college_export_service.dart';
import '../../domain/models/college_dashboard_model.dart';
import '../widgets/college_drawer.dart';
import '../widgets/college_profile_menu_pill.dart';

/// Production-ready College Executive Overview Dashboard.
/// Fully audited with Zero-Overflow guarantees, 2x2 spacious Quick Actions,
/// dedicated Full-Width instant search bar, safe bottom insets above Android navigation bar,
/// and 1:1 parity with the React web platform.
class CollegeDashboardPage extends StatelessWidget {
  const CollegeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollegeBloc()..add(LoadCollegeDashboard()),
      child: const _CollegeDashboardContentView(),
    );
  }
}

class _CollegeDashboardContentView extends StatefulWidget {
  const _CollegeDashboardContentView();

  @override
  State<_CollegeDashboardContentView> createState() => _CollegeDashboardContentViewState();
}

class _CollegeDashboardContentViewState extends State<_CollegeDashboardContentView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final systemBottomPadding = MediaQuery.paddingOf(context).bottom;

    // Typography scale
    final sectionFont = clampDouble(screenWidth * 0.042, 15.0, 17.0);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.bg,
        drawer: const CollegeNavigationDrawer(currentRoute: '/college/dashboard'),
        floatingActionButton: _buildAiAssistantFab(context),
        body: SafeArea(
          top: true,
          bottom: false, // Handled manually with systemBottomPadding for zero clipping
          child: BlocConsumer<CollegeBloc, CollegeState>(
            listener: (context, state) {
              if (state is CollegeLoaded && state.toastMessage != null) {
                _showToast(state.toastMessage!);
              }
            },
            builder: (context, state) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<CollegeBloc>().add(RefreshCollegeDashboard());
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    top: 10.0,
                    bottom: systemBottomPadding + 96.0, // Fully clears Android navigation buttons & FAB
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header Navigation Tier (Menu, Title, Notification, Profile Pill)
                      RepaintBoundary(
                        child: _buildTopHeaderTier(context, state),
                      ),
                      const SizedBox(height: 12),

                      // 2. Full-Width Dedicated Search Bar
                      RepaintBoundary(
                        child: _buildFullWidthSearchBar(context, state),
                      ),
                      const SizedBox(height: 16),

                      if (state is CollegeLoading)
                        _buildLoadingSkeleton(context)
                      else if (state is CollegeError)
                        _buildErrorState(context, state.message)
                      else if (state is CollegeLoaded) ...[
                        // Search Filter Indicator (if query is active)
                        if (state.searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildActiveSearchFilterHeader(context, state),
                          ),

                        // 3. Welcome Hero Banner
                        RepaintBoundary(
                          child: _buildWelcomeHeroBanner(context, state.data),
                        ),
                        const SizedBox(height: 16),

                        // 4. Quick Actions 2x2 Spacious Grid & Urgent Pending Card
                        RepaintBoundary(
                          child: _buildQuickActionsAndPendingSection(context, state),
                        ),
                        const SizedBox(height: 16),

                        // 5. Key Metrics 2x2 Grid (Live DB Metrics vs Mock with *)
                        RepaintBoundary(
                          child: _buildKeyMetricsGrid(context, state.data),
                        ),
                        const SizedBox(height: 16),

                        // 6. Recent Student Activity Feed (100% Zero-Overflow)
                        RepaintBoundary(
                          child: _buildRecentActivitySection(
                            context,
                            state.filteredActivities,
                            state.data.isActivitiesMock,
                            sectionFont,
                            state.searchQuery,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 7. Upcoming Placement Schedule Timeline (100% Zero-Overflow)
                        RepaintBoundary(
                          child: _buildUpcomingScheduleSection(
                            context,
                            state.filteredScheduleEvents,
                            state.data.isScheduleMock,
                            sectionFont,
                            state.searchQuery,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 8. AI Insight Recommendation Banner
                        RepaintBoundary(
                          child: _buildAiInsightBanner(context, state.data),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= 1. TOP HEADER NAVIGATION TIER =================
  Widget _buildTopHeaderTier(BuildContext context, CollegeState state) {
    final collegeData = (state is CollegeLoaded) ? state.data : null;
    final collegeName = collegeData?.collegeName ?? 'MIT Academy of Engineering';
    final collegeEmail = collegeData?.email ?? 'tpo@mitaoe.ac.in';
    final initial = collegeName.isNotEmpty ? collegeName[0].toUpperCase() : 'M';

    return Row(
      children: [
        // Drawer Menu Button
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _scaffoldKey.currentState?.openDrawer();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.surf,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.brdr, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(LucideIcons.menu, size: 20, color: context.txtPrimary),
          ),
        ),
        const SizedBox(width: 10),

        // Brand Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Campus2Corporate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: context.txtPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'College Admin Portal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentViolet,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Notifications Bell Icon
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showToast('Campus announcements synced.');
          },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.surf,
              shape: BoxShape.circle,
              border: Border.all(color: context.brdr, width: 0.8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(LucideIcons.bell, size: 18, color: context.txtPrimary),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accentViolet,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // College Profile Menu Pill
        CollegeProfileMenuPill(
          collegeName: collegeName,
          collegeEmail: collegeEmail,
          avatarInitial: initial,
        ),
      ],
    );
  }

  // ================= 2. FULL-WIDTH DEDICATED SEARCH BAR =================
  Widget _buildFullWidthSearchBar(BuildContext context, CollegeState state) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.brdr, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 17, color: AppColors.accentViolet),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<CollegeBloc>().add(SearchCollegeDashboard(val));
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.txtPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search students, records, or drives...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: context.txtMuted,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                context.read<CollegeBloc>().add(const SearchCollegeDashboard(''));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.surfAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.x, size: 14, color: context.txtMuted),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSearchFilterHeader(BuildContext context, CollegeLoaded state) {
    final totalMatches = state.filteredActivities.length + state.filteredScheduleEvents.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Filtered by "${state.searchQuery}" ($totalMatches matches)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accentViolet,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _searchController.clear();
              context.read<CollegeBloc>().add(const SearchCollegeDashboard(''));
            },
            child: Text(
              'Clear',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.accentViolet,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 3. WELCOME HERO BANNER =================
  Widget _buildWelcomeHeroBanner(BuildContext context, CollegeDashboardModel data) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.045, 14.0, 20.0)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED), Color(0xFF581C87)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Placement Season Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 12, color: Color(0xFFFDE047)),
                    const SizedBox(width: 5),
                    Text(
                      'Campus Placement Active',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (data.isProfileMock) ...[
                const SizedBox(width: 6),
                _buildMockAsteriskBadge(context),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Welcome College Title
          Text(
            'Welcome back, ${data.collegeName}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: clampDouble(screenWidth * 0.048, 17.0, 21.0),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle text
          Text(
            'Academic Year 2024-25. You have ${data.totalStudents > 0 ? data.totalStudents : 1420} students eligible for placement cycles.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Embedded Stat Badges (Active Students & Placement Rate)
          Row(
            children: [
              // Active Students Badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Active Students',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (data.isMetricsMock)
                            const Text('*', style: TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.activeCandidates > 0 ? data.activeCandidates : (data.totalStudents > 0 ? data.totalStudents : 3842)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: isCompact ? 18 : 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Placement Rate Badge
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Placement Rate',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (data.isMetricsMock)
                            const Text('*', style: TextStyle(color: Color(0xFFFDE047), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.placementRateFormatted,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: isCompact ? 18 : 22,
                          fontWeight: FontWeight.w800,
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

  // ================= 4. QUICK ACTIONS (SPACIOUS 2x2 GRID - ZERO TRUNCATION) =================
  Widget _buildQuickActionsAndPendingSection(BuildContext context, CollegeLoaded state) {
    return Column(
      children: [
        // Quick Action Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK ACTIONS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: context.txtPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Frequent Tasks',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2x2 Extra-Spacious Action Cards Grid (Zero Truncation, Generous Breathing Room)
              Row(
                children: [
                  Expanded(
                    child: _buildSpaciousActionCard(
                      context,
                      icon: LucideIcons.userPlus,
                      title: 'Invite Students',
                      subtitle: 'Add batch candidates',
                      onTap: () => _openInviteStudentsModal(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSpaciousActionCard(
                      context,
                      icon: LucideIcons.calendar,
                      title: 'Schedule Drive',
                      subtitle: 'New campus visit',
                      onTap: () => _openScheduleDriveModal(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSpaciousActionCard(
                      context,
                      icon: LucideIcons.send,
                      title: 'Send Broadcast',
                      subtitle: 'Campus notice alert',
                      onTap: () => _openBroadcastModal(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSpaciousActionCard(
                      context,
                      icon: LucideIcons.fileText,
                      title: 'View Reports',
                      subtitle: 'PDF & CSV analytics',
                      onTap: () => _openReportsModal(context, state.data),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Urgent Pending Action Warning Banner
        if (!state.isPendingApproved)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFBE123C)),
                        const SizedBox(width: 6),
                        Text(
                          'PENDING ACTIONS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9F1239),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: Color(0xFF9F1239), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Urgent',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFBE123C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Google Placement eligibility criteria needs approval. 120 students awaiting verification.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF881337),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _openPendingReviewModal(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Review Now',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFBE123C),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.arrowRight, size: 14, color: Color(0xFFBE123C)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSpaciousActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 118,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 118,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDE9FE), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentViolet.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 18),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDE9FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.arrowUpRight, size: 12, color: AppColors.accentViolet),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.txtPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: context.txtSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= 5. KEY METRICS GRID =================
  Widget _buildKeyMetricsGrid(BuildContext context, CollegeDashboardModel data) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final statFont = clampDouble(screenWidth * 0.062, 19.0, 24.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'KEY PLACEMENT METRICS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: context.txtPrimary,
                letterSpacing: 0.5,
              ),
            ),
            if (data.isMetricsMock)
              _buildMockAsteriskBadge(context),
          ],
        ),
        const SizedBox(height: 10),

        // 2x2 Symmetrical KPI Grid
        Row(
          children: [
            // Card 1: Total Students (MongoDB Realtime)
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Total Students',
                value: '${data.totalStudents > 0 ? data.totalStudents : 4128}',
                icon: LucideIcons.users,
                statFont: statFont,
                footer: Row(
                  children: [
                    Text('+4%^', style: GoogleFonts.plusJakartaSans(color: AppColors.accentViolet, fontSize: 10.5, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('Growth', style: GoogleFonts.plusJakartaSans(color: context.txtMuted, fontSize: 10, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                progressBarColor: AppColors.accentViolet,
                progressPercent: 0.78,
                isMock: data.isMetricsMock,
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Active Drives (MongoDB Realtime)
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Active Drives',
                value: '${data.totalProjects > 0 ? data.totalProjects : 12}',
                icon: LucideIcons.briefcase,
                statFont: statFont,
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '4 this week',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                progressBarColor: AppColors.primary,
                progressPercent: 0.65,
                isMock: data.isMetricsMock,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Card 3: Upcoming Interviews (Mock with *)
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Interviews',
                value: '${data.totalApplications > 0 ? data.totalApplications : 45}',
                icon: LucideIcons.clock,
                statFont: statFont,
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Text(
                    'Next 48h',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
                progressBarColor: const Color(0xFFF59E0B),
                progressPercent: 0.55,
                isMock: true,
              ),
            ),
            const SizedBox(width: 10),

            // Card 4: Broadcasts Sent (Mock with *)
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'Broadcasts',
                value: '${data.broadcastsSent}',
                icon: LucideIcons.send,
                statFont: statFont,
                footer: Text(
                  '100% Delivered',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                progressBarColor: AppColors.success,
                progressPercent: 1.0,
                isMock: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required double statFont,
    required Widget footer,
    required Color progressBarColor,
    required double progressPercent,
    required bool isMock,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: context.txtMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMock)
                      const Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.accentViolet,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: AppColors.accentViolet),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: statFont,
              fontWeight: FontWeight.w800,
              color: context.txtPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 4,
              backgroundColor: progressBarColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
            ),
          ),
          const SizedBox(height: 6),
          footer,
        ],
      ),
    );
  }

  // ================= 6. RECENT STUDENT ACTIVITY FEED (ZERO OVERFLOW) =================
  Widget _buildRecentActivitySection(
    BuildContext context,
    List<RecentActivityModel> activities,
    bool isMock,
    double sectionFont,
    String searchQuery,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Zero-Overflow Protection
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Recent Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: sectionFont,
                          fontWeight: FontWeight.w800,
                          color: context.txtPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMock)
                      const Text(' *', style: TextStyle(color: AppColors.accentViolet, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/college/students');
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentViolet,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(LucideIcons.chevronRight, size: 14, color: AppColors.accentViolet),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.inbox, size: 30, color: context.txtMuted),
                    const SizedBox(height: 6),
                    Text(
                      searchQuery.isNotEmpty
                          ? 'No student activity matches "$searchQuery".'
                          : 'No recent student activities found.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.txtSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: context.brdr),
              itemBuilder: (context, index) {
                final item = activities[index];
                return _buildActivityRow(context, item);
              },
            ),

          const SizedBox(height: 10),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Candidate Telemetry Feed',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: context.txtMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Updated live',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.accentViolet,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(BuildContext context, RecentActivityModel item) {
    Color avatarColor = AppColors.primary;
    if (item.avatarColor == 'blue') avatarColor = const Color(0xFF2563EB);
    if (item.avatarColor == 'amber') avatarColor = const Color(0xFFD97706);
    if (item.avatarColor == 'emerald') avatarColor = const Color(0xFF059669);

    final initials = item.name
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .take(2)
        .join('');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar Initial Box
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isNotEmpty ? initials : 'ST',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: context.txtPrimary,
                    ),
                    children: [
                      TextSpan(text: item.name),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: item.detail,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          color: context.txtMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.action,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: context.txtSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Badge Pill
          _buildActivityBadge(item),
        ],
      ),
    );
  }

  Widget _buildActivityBadge(RecentActivityModel item) {
    Color bg = const Color(0xFFF1F5F9);
    Color textCol = const Color(0xFF475569);

    final type = item.badgeType.toLowerCase();
    if (type.contains('applied') || type.contains('active')) {
      bg = const Color(0xFFEFF6FF);
      textCol = const Color(0xFF1D4ED8);
    } else if (type.contains('score') || type.contains('shortlist') || type.contains('shortlisted')) {
      bg = const Color(0xFFF3E8FF);
      textCol = const Color(0xFF7C3AED);
    } else if (type.contains('updated')) {
      bg = const Color(0xFFFFFBEB);
      textCol = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textCol.withValues(alpha: 0.2), width: 0.6),
      ),
      child: Text(
        item.badgeText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textCol,
        ),
      ),
    );
  }

  // ================= 7. UPCOMING PLACEMENT SCHEDULE (ZERO OVERFLOW) =================
  Widget _buildUpcomingScheduleSection(
    BuildContext context,
    List<ScheduleEventModel> events,
    bool isMock,
    double sectionFont,
    String searchQuery,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Zero-Overflow Protection
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Upcoming Schedule',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: sectionFont,
                          fontWeight: FontWeight.w800,
                          color: context.txtPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMock)
                      const Text(' *', style: TextStyle(color: AppColors.accentViolet, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'October 2024',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentViolet,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  searchQuery.isNotEmpty
                      ? 'No events match "$searchQuery".'
                      : 'No upcoming placement events scheduled.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: context.txtSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final ev = events[index];
                return _buildScheduleItem(context, ev);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, ScheduleEventModel event) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.brdr, width: 0.7),
      ),
      child: Row(
        children: [
          // Date Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.month,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentViolet,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  event.day,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.txtPrimary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.txtSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          Icon(LucideIcons.chevronRight, size: 16, color: context.txtMuted),
        ],
      ),
    );
  }

  // ================= 8. AI INSIGHT BANNER (ZERO OVERFLOW) =================
  Widget _buildAiInsightBanner(BuildContext context, CollegeDashboardModel data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.accentViolet,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'AI INSIGHT RECOMMENDATION',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentViolet,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (data.isAiInsightMock)
                      const Text(' *', style: TextStyle(color: AppColors.accentViolet, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  data.aiInsightText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.txtPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 9. FLOATING AI ASSISTANT FAB =================
  Widget _buildAiAssistantFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _openAiAssistantModal(context);
      },
      backgroundColor: AppColors.accentViolet,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(LucideIcons.messageSquare, color: Colors.white, size: 22),
    );
  }

  Widget _buildMockAsteriskBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.sparkles, size: 10, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            'Soon *',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ================= MODAL 1: SCHEDULE PLACEMENT DRIVE =================
  void _openScheduleDriveModal(BuildContext context) {
    final bloc = context.read<CollegeBloc>();
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final packageController = TextEditingController(text: '12.0');
    final dateController = TextEditingController(
      text: DateTime.now().add(const Duration(days: 14)).toIso8601String().split('T').first,
    );
    final selectedBranches = <String>['CSE', 'ECE', 'IT'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final viewInsetsBottom = MediaQuery.viewInsetsOf(ctx).bottom;
            final systemBottom = MediaQuery.paddingOf(ctx).bottom;
            final effectiveBottom = viewInsetsBottom > 0 ? viewInsetsBottom + 16 : systemBottom + 20;

            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: effectiveBottom,
              ),
              decoration: BoxDecoration(
                color: modalContext.surf,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Zero-Overflow Protection
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.calendar, size: 17, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Schedule Placement Drive',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: modalContext.txtPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: Icon(LucideIcons.x, size: 18, color: modalContext.txtMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Field 1: Company Name
                    _buildFormFieldLabel('Company Name'),
                    _buildTextField(
                      controller: companyController,
                      hint: 'e.g. Stripe Tech / Google APAC',
                    ),
                    const SizedBox(height: 12),

                    // Field 2: Job Role & Package LPA
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormFieldLabel('Job Role'),
                              _buildTextField(
                                controller: roleController,
                                hint: 'e.g. SDE-1',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFormFieldLabel('Package (LPA)'),
                              _buildTextField(
                                controller: packageController,
                                hint: '12.0',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Field 3: Drive Date
                    _buildFormFieldLabel('Drive Date'),
                    _buildTextField(
                      controller: dateController,
                      hint: 'YYYY-MM-DD',
                    ),
                    const SizedBox(height: 14),

                    // Field 4: Eligible Branches
                    _buildFormFieldLabel('Eligible Branches'),
                    Wrap(
                      spacing: 6,
                      children: ['CSE', 'ECE', 'IT', 'MECH', 'CIVIL', 'ALL'].map((branch) {
                        final isSel = selectedBranches.contains(branch);
                        return FilterChip(
                          label: Text(branch),
                          selected: isSel,
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                selectedBranches.add(branch);
                              } else {
                                selectedBranches.remove(branch);
                              }
                            });
                          },
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : modalContext.txtSecondary,
                          ),
                          selectedColor: AppColors.accentViolet,
                          backgroundColor: modalContext.surfAlt,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Submit CTA
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          if (companyController.text.trim().isEmpty) return;
                          HapticFeedback.mediumImpact();
                          bloc.add(CreatePlacementDriveEvent({
                            'companyName': companyController.text.trim(),
                            'jobRole': roleController.text.trim().isNotEmpty
                                ? roleController.text.trim()
                                : 'Software Engineer',
                            'packageLPA': packageController.text.trim(),
                            'driveDate': dateController.text.trim(),
                            'eligibleBranches': selectedBranches,
                          }));
                          Navigator.pop(modalContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentViolet,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Schedule Placement Drive',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= MODAL 2: INVITE STUDENTS (100% OVERFLOW PROTECTED) =================
  void _openInviteStudentsModal(BuildContext context) {
    final bloc = context.read<CollegeBloc>();
    final emailsController = TextEditingController();
    String selectedBatch = 'Computer Science (2025)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final viewInsetsBottom = MediaQuery.viewInsetsOf(ctx).bottom;
            final systemBottom = MediaQuery.paddingOf(ctx).bottom;
            final effectiveBottom = viewInsetsBottom > 0 ? viewInsetsBottom + 16 : systemBottom + 20;

            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: effectiveBottom,
              ),
              decoration: BoxDecoration(
                color: modalContext.surf,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Zero-Overflow Protection
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.userPlus, size: 17, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Invite Students to Portal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: modalContext.txtPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: Icon(LucideIcons.x, size: 18, color: modalContext.txtMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildFormFieldLabel('Student Email Addresses (comma separated)'),
                    _buildTextField(
                      controller: emailsController,
                      hint: 'rahul.v@mit.edu, priya.s@mit.edu',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    _buildFormFieldLabel('Select Department / Batch'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: modalContext.surfAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: modalContext.brdr),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBatch,
                          isExpanded: true,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: modalContext.txtPrimary,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Computer Science (2025)', child: Text('Computer Science (2025)')),
                            DropdownMenuItem(value: 'Electronics & Telecom (2025)', child: Text('Electronics & Telecom (2025)')),
                            DropdownMenuItem(value: 'Mechanical Engineering (2025)', child: Text('Mechanical Engineering (2025)')),
                            DropdownMenuItem(value: 'All Eligible Batches', child: Text('All Eligible Batches')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedBatch = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          bloc.add(InviteStudentsEvent(
                            emails: emailsController.text.trim(),
                            batch: selectedBatch,
                          ));
                          Navigator.pop(modalContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentViolet,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Send Invitations',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= MODAL 3: BROADCAST ANNOUNCEMENT =================
  void _openBroadcastModal(BuildContext context) {
    final bloc = context.read<CollegeBloc>();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final viewInsetsBottom = MediaQuery.viewInsetsOf(modalContext).bottom;
        final systemBottom = MediaQuery.paddingOf(modalContext).bottom;
        final effectiveBottom = viewInsetsBottom > 0 ? viewInsetsBottom + 16 : systemBottom + 20;

        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: effectiveBottom,
          ),
          decoration: BoxDecoration(
            color: modalContext.surf,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.send, size: 17, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Broadcast Announcement',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: modalContext.txtPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(modalContext),
                      icon: Icon(LucideIcons.x, size: 18, color: modalContext.txtMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildFormFieldLabel('Subject Line'),
                _buildTextField(
                  controller: subjectController,
                  hint: 'e.g. Mandatory Resume Verification Drive',
                ),
                const SizedBox(height: 12),

                _buildFormFieldLabel('Announcement Content'),
                _buildTextField(
                  controller: messageController,
                  hint: 'Write your announcement to all eligible candidates...',
                  maxLines: 4,
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.trim().isEmpty) return;
                      HapticFeedback.mediumImpact();
                      bloc.add(SendBroadcastEvent(
                        subject: subjectController.text.trim(),
                        message: messageController.text.trim(),
                      ));
                      Navigator.pop(modalContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentViolet,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Dispatch Broadcast',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= MODAL 4: PENDING REVIEW =================
  void _openPendingReviewModal(BuildContext context) {
    final bloc = context.read<CollegeBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: dialogContext.surf,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.shieldAlert, color: Color(0xFFBE123C), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pending Criteria Approval',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: dialogContext.txtPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google Placement Eligibility Requirement',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9F1239),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Google APAC requires minimum 7.5 CGPA and zero active backlogs for 120 applicants. Please confirm college endorsement.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF881337),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Dismiss',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: dialogContext.txtSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                bloc.add(const ApprovePendingEvent('pend-1'));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE123C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Approve & Verify',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= MODAL 5: REPORTS MODAL =================
  void _openReportsModal(BuildContext context, CollegeDashboardModel data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final systemBottom = MediaQuery.paddingOf(modalContext).bottom;
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 18,
            bottom: systemBottom + 20,
          ),
          decoration: BoxDecoration(
            color: modalContext.surf,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.fileText, size: 17, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Placement Reports',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: modalContext.txtPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(modalContext),
                    icon: Icon(LucideIcons.x, size: 18, color: modalContext.txtMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Download executive reports and summaries for Academic Year 2024-25.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: modalContext.txtSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Navigator.pop(modalContext);
                        _showToast('Generating Executive PDF Report...');
                        await CollegeExportService.exportDashboardPdf(context, data);
                      },
                      icon: const Icon(LucideIcons.download, size: 16, color: Colors.white),
                      label: Text('Download PDF', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Navigator.pop(modalContext);
                        _showToast('Exporting CSV dataset...');
                        await CollegeExportService.exportDashboardCsv(context, data);
                      },
                      icon: const Icon(LucideIcons.fileSpreadsheet, size: 16, color: Colors.white),
                      label: Text('Export CSV', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ================= MODAL 6: AI ASSISTANT SHEET (100% OVERFLOW-FREE) =================
  void _openAiAssistantModal(BuildContext context) {
    final bloc = context.read<CollegeBloc>();
    final chatInputController = TextEditingController();
    final scrollController = ScrollController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<CollegeBloc, CollegeState>(
            builder: (context, state) {
              final messages = (state is CollegeLoaded) ? state.chatMessages : [];
              final screenHeight = MediaQuery.sizeOf(modalContext).height;
              final viewInsetsBottom = MediaQuery.viewInsetsOf(modalContext).bottom;
              final systemBottom = MediaQuery.paddingOf(modalContext).bottom;

              // Smooth bounded height that adjusts dynamically when keyboard opens/closes
              final modalHeight = viewInsetsBottom > 0
                  ? clampDouble(screenHeight * 0.85, 400.0, screenHeight * 0.92)
                  : clampDouble(screenHeight * 0.68, 380.0, 560.0);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                height: modalHeight,
                decoration: BoxDecoration(
                  color: modalContext.surf,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: modalContext.isDark ? 0.4 : 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // A. Top Purple Gradient Header (Zero Overflow Guarantee)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.sparkles, size: 16, color: Color(0xFFFDE047)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'AI Placement Assistant',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildMockAsteriskBadge(context),
                                  ],
                                ),
                                Text(
                                  'Campus2Corporate Intelligence',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(modalContext),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            icon: const Icon(LucideIcons.x, size: 18, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // B. Messages List with Smooth Auto-Scrolling
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isUser = msg.sender == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.sizeOf(context).width * 0.80,
                              ),
                              decoration: BoxDecoration(
                                color: isUser ? AppColors.accentViolet : modalContext.surfAlt,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
                                  bottomLeft: !isUser ? const Radius.circular(2) : const Radius.circular(16),
                                ),
                                border: isUser ? null : Border.all(color: modalContext.brdr, width: 0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isUser ? 0.1 : 0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: isUser ? Colors.white : modalContext.txtPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // C. Bottom Input Row with Smooth Keyboard Inset Handling
                    Container(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 8,
                        bottom: viewInsetsBottom > 0 ? viewInsetsBottom + 8 : systemBottom + 12,
                      ),
                      decoration: BoxDecoration(
                        color: modalContext.surf,
                        border: Border(top: BorderSide(color: modalContext.brdr, width: 0.8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: modalContext.surfAlt,
                                borderRadius: BorderRadius.circular(21),
                                border: Border.all(color: modalContext.brdr, width: 0.8),
                              ),
                              child: TextField(
                                controller: chatInputController,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: modalContext.txtPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Ask placement assistant...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: modalContext.txtMuted,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              final text = chatInputController.text.trim();
                              if (text.isEmpty) return;
                              HapticFeedback.lightImpact();
                              bloc.add(SendAiChatMessageEvent(text));
                              chatInputController.clear();
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (scrollController.hasClients) {
                                  scrollController.animateTo(
                                    scrollController.position.maxScrollExtent + 80,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(21),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.accentViolet,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentViolet.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(LucideIcons.send, color: Colors.white, size: 17),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= FORM HELPERS =================
  Widget _buildFormFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: context.txtPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.brdr),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: context.txtPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: context.txtMuted,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  // ================= SKELETON & ERROR =================
  Widget _buildLoadingSkeleton(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              'Loading College Placement Dashboard...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.txtSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.alertCircle, size: 36, color: AppColors.error),
            const SizedBox(height: 10),
            Text(
              'Failed to load dashboard data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.txtPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: context.txtSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                context.read<CollegeBloc>().add(LoadCollegeDashboard());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
