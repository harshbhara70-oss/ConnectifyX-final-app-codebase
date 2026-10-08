import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_overview_bloc.dart';
import '../../bloc/mentor_overview_event.dart';
import '../../bloc/mentor_overview_state.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/mentor_drawer.dart';

class MentorDashboardPage extends StatelessWidget {
  const MentorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorOverviewBloc()..add(const FetchMentorOverviewEvent()),
      child: const _MentorDashboardView(),
    );
  }
}

class _MentorDashboardView extends StatefulWidget {
  const _MentorDashboardView();

  @override
  State<_MentorDashboardView> createState() => _MentorDashboardViewState();
}

class _MentorDashboardViewState extends State<_MentorDashboardView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _selectedPipelineStage = 'All';

  /// Shorter synonyms for pipeline stages ensuring zero text truncation on any screen size
  String _getStageShortLabel(String stage) {
    switch (stage.trim()) {
      case 'Skill Assessment':
        return 'Skills';
      case 'Learning Path':
        return 'Learning';
      case 'Mock Interview':
        return 'Mock Prep';
      case 'Placement Ready':
        return 'Job Ready';
      case 'Mentorship':
        return 'Mentorship';
      case 'Enrolled':
        return 'Enrolled';
      case 'Hired':
        return 'Placed';
      default:
        return stage;
    }
  }

  /// Contextual icon per pipeline stage
  IconData _getStageIcon(String stage) {
    switch (stage.trim()) {
      case 'Enrolled':
        return LucideIcons.userCheck;
      case 'Skill Assessment':
        return LucideIcons.clipboardCheck;
      case 'Learning Path':
        return LucideIcons.bookOpen;
      case 'Mentorship':
        return LucideIcons.messageSquare;
      case 'Mock Interview':
        return LucideIcons.video;
      case 'Placement Ready':
        return LucideIcons.award;
      case 'Hired':
        return LucideIcons.badgeCheck;
      default:
        return LucideIcons.circle;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openScheduleSessionSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<MentorOverviewBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ScheduleSessionSheet(
        onSubmit: (newSession) {
          bloc.add(CreateSessionSlotEvent(newSession));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Session scheduled with ${newSession.studentName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFeedbackDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.star, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Student Evaluation*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Evaluation and feedback tools are synced. Navigate to the Feedback Section to submit complete candidate scoring rubrics.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Close',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/mentor/feedback');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Open Feedback*',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNotificationsSheet(BuildContext context, List<MentorAnnouncementModel> announcements) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.bell, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Live Alerts & Bulletins*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                ann.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ann.category,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ann.content,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ann.date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const MentorNavigationDrawer(currentRoute: '/mentor/dashboard'),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (drawerContext) => IconButton(
            icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              Scaffold.of(drawerContext).openDrawer();
            },
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'C2C',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mentor Portal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Dashboard Overview*',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<MentorOverviewBloc, MentorOverviewState>(
            builder: (context, state) {
              final announcements = state is MentorOverviewLoaded ? state.data.announcements : <MentorAnnouncementModel>[];
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.bell, color: AppColors.textPrimary, size: 20),
                    onPressed: () => _openNotificationsSheet(context, announcements),
                  ),
                  if (announcements.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            HapticFeedback.lightImpact();
            context.read<MentorOverviewBloc>().add(const RefreshMentorOverviewEvent());
          },
          child: BlocBuilder<MentorOverviewBloc, MentorOverviewState>(
            builder: (context, state) {
              if (state is MentorOverviewLoading) {
                return _buildShimmerLoading(context);
              } else if (state is MentorOverviewError) {
                return _buildErrorView(context, state.message);
              } else if (state is MentorOverviewLoaded) {
                return _buildLoadedContent(context, state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, MentorOverviewLoaded state) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPad = clampDouble(screenWidth * 0.045, 14.0, 20.0);
    final data = state.data;
    final isSmallScreen = screenWidth < 360;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 16.0,
        bottom: MediaQuery.paddingOf(context).bottom == 0 ? 24.0 : MediaQuery.paddingOf(context).bottom + 16.0,
        left: horizontalPad,
        right: horizontalPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ultra Professional Search Bar
          _buildSearchBar(context, state),
          const SizedBox(height: 16),

          // 2. Personalized Hero & Action Zone
          RepaintBoundary(
            child: _buildHeroActionZone(context, data),
          ),
          const SizedBox(height: 20),

          // 3. Mentor Performance Overview Counters Grid
          RepaintBoundary(
            child: _buildCountersGrid(context, data, isSmallScreen),
          ),
          const SizedBox(height: 24),

          // 4. Interactive Student Pipeline Journey
          RepaintBoundary(
            child: _buildStudentPipelineJourney(context, state),
          ),
          const SizedBox(height: 24),

          // 5. Live Bulletins & Announcements Feed
          RepaintBoundary(
            child: _buildAnnouncementsFeed(context, data.announcements),
          ),
          const SizedBox(height: 24),

          // 6. AI Quick Insights & Personal Targets Tracker
          RepaintBoundary(
            child: _buildAiInsightsAndGoals(context, data),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- 1. Search Bar Widget ---
  Widget _buildSearchBar(BuildContext context, MentorOverviewLoaded state) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search mentees by name, skill, college...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                context.read<MentorOverviewBloc>().add(FilterMentorOverviewEvent(val));
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.xCircle, size: 18, color: AppColors.textMuted),
              onPressed: () {
                _searchController.clear();
                context.read<MentorOverviewBloc>().add(const FilterMentorOverviewEvent(''));
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  // --- 2. Hero & Quick Actions ---
  Widget _buildHeroActionZone(BuildContext context, MentorOverviewData data) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag / Sparkle Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    "${data.mentorName.split(' ')[0]}'s Workspace",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (data.isMock)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 11, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Demo Sync*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Description (No awkward ellipsis truncation)
          Text(
            'Welcome Back, Dr. Sarah! Guide students and shape the next generation.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.046, 17.0, 20.0),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Access live evaluations, project check-ins, and candidate metrics from the student queue.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons Tier
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Schedule Session CTA
              ElevatedButton.icon(
                onPressed: () => _openScheduleSessionSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.calendar, size: 15),
                label: Text(
                  'Schedule Session*',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // View Students CTA
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/mentor/students');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.users, size: 15, color: AppColors.textSecondary),
                label: Text(
                  'View Students',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Add Feedback CTA
              OutlinedButton.icon(
                onPressed: () => _openFeedbackDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(LucideIcons.star, size: 15, color: AppColors.textSecondary),
                label: Text(
                  'Add Feedback*',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Counters Grid ---
  Widget _buildCountersGrid(BuildContext context, MentorOverviewData data, bool isSmallScreen) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMock = data.isMock;
    final asterisk = isMock ? '*' : '';

    final isSmall = screenWidth < 360;
    final isMedium = screenWidth >= 360 && screenWidth < 414;
    final isTablet = screenWidth > 600;

    final crossAxisCount = isTablet ? 3 : 2;
    final childAspectRatio = isTablet
        ? 1.35
        : (isSmall ? 1.02 : (isMedium ? 1.12 : 1.20));

    final cardPadding = clampDouble(screenWidth * 0.035, 10.0, 14.0);
    final iconBoxSize = clampDouble(screenWidth * 0.09, 32.0, 38.0);
    final iconSize = clampDouble(screenWidth * 0.045, 16.0, 19.0);

    final stats = [
      {
        'label': 'Students Assigned',
        'value': '${data.students.length} Total$asterisk',
        'sub': 'Active cohorts',
        'icon': LucideIcons.users,
        'iconColor': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'Sessions This Week',
        'value': '${data.sessions.length} Slots$asterisk',
        'sub': 'Scheduled mock trials',
        'icon': LucideIcons.calendar,
        'iconColor': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'label': 'Average Rating',
        'value': '${data.averageRating.toStringAsFixed(2)} / 5.0$asterisk',
        'sub': 'Calculated this term',
        'icon': LucideIcons.star,
        'iconColor': const Color(0xFFD97706),
        'bg': const Color(0xFFFFFBEB),
      },
      {
        'label': 'Placement-Ready',
        'value': '${data.students.where((s) => s.progress >= 80).length} Candidates$asterisk',
        'sub': 'Readiness >= 80%',
        'icon': LucideIcons.award,
        'iconColor': AppColors.primary,
        'bg': AppColors.primaryLight,
      },
      {
        'label': 'Feedback Pending',
        'value': '${data.tasks.where((t) => t.status == 'Pending').length} Reviews$asterisk',
        'sub': 'Needs feedback checks',
        'icon': LucideIcons.clock,
        'iconColor': const Color(0xFFDB2777),
        'bg': const Color(0xFFFDF2F8),
      },
      {
        'label': 'Students Placed',
        'value': '${data.students.where((s) => s.pipelineStage == 'Hired').length} Hired$asterisk',
        'sub': 'Matched successfully',
        'icon': LucideIcons.shieldCheck,
        'iconColor': const Color(0xFF0891B2),
        'bg': const Color(0xFFECFEFF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mentor Performance Overview',
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: stats.length,
          itemBuilder: (context, idx) {
            final item = stats[idx];
            return Container(
              padding: EdgeInsets.all(cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x04000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
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
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: item['bg'] as Color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          item['icon'] as IconData,
                          size: iconSize,
                          color: item['iconColor'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item['value'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.048, 16.0, 20.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['label'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          item['sub'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
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
      ],
    );
  }

  // --- 4. Interactive Student Pipeline Journal ---
  Widget _buildStudentPipelineJourney(BuildContext context, MentorOverviewLoaded state) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final allStudents = state.filteredStudents;

    const stages = [
      'Enrolled',
      'Skill Assessment',
      'Learning Path',
      'Mentorship',
      'Mock Interview',
      'Placement Ready',
      'Hired',
    ];

    final currentStageStudents = _selectedPipelineStage == 'All'
        ? allStudents
        : allStudents.where((s) => s.pipelineStage == _selectedPipelineStage).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with 100% Full Width (Zero Truncation)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.gitCommit, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pipeline Journey*',
                      softWrap: true,
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.042, 15.5, 17.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Milestone progression tracking*',
                      softWrap: true,
                      maxLines: 1,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Pipeline Stage Cards (Spacious, Zero-Truncation, Touch-Selectable)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(stages.length, (idx) {
                final stage = stages[idx];
                final shortName = _getStageShortLabel(stage);
                final stageIcon = _getStageIcon(stage);
                final matchedStudents = allStudents.where((s) => s.pipelineStage == stage).toList();
                final count = matchedStudents.length;
                final isSelected = _selectedPipelineStage == stage;
                final isPopulated = count > 0;

                return Padding(
                  padding: EdgeInsets.only(right: idx == stages.length - 1 ? 0 : 10),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedPipelineStage = isSelected ? 'All' : stage;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: clampDouble(screenWidth * 0.32, 120.0, 138.0),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : (isPopulated ? AppColors.inputFill : AppColors.surface),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isPopulated ? AppColors.border : AppColors.border.withValues(alpha: 0.5)),
                          width: isSelected ? 1.5 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top Row: Step Index Badge & Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isPopulated ? AppColors.primaryLight : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '0${idx + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : (isPopulated ? AppColors.primary : AppColors.textMuted),
                                  ),
                                ),
                              ),
                              Icon(
                                stageIcon,
                                size: 15,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isPopulated ? AppColors.primary : AppColors.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Stage Counter Bubble
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isPopulated ? AppColors.primaryLight : const Color(0xFFF1F5F9)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : (isPopulated ? AppColors.primary : AppColors.textMuted),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Stage Short Name (Guaranteed Zero Truncation)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              shortName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isPopulated ? AppColors.textPrimary : AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Subtitle / Full Stage Context
                          Text(
                            count == 1 ? '1 mentee' : '$count mentees',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Avatar Stack or Placeholder
                          if (matchedStudents.isNotEmpty)
                            Wrap(
                              spacing: 3,
                              runSpacing: 3,
                              alignment: WrapAlignment.center,
                              children: matchedStudents.take(3).map((st) {
                                return Tooltip(
                                  message: '${st.name} • ${st.college}',
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(st.avatarBg.replaceFirst('#', '0xFF'))),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      st.avatar,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Active Stage Mentee Roster Section (Expandable / Interactive)
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedPipelineStage == 'All'
                      ? 'Pipeline Mentees (${allStudents.length})*'
                      : '$_selectedPipelineStage Mentees (${currentStageStudents.length})*',
                  softWrap: true,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_selectedPipelineStage != 'All')
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedPipelineStage = 'All');
                  },
                  child: Text(
                    'Show All',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (currentStageStudents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No students currently in this stage.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentStageStudents.take(4).length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, sIdx) {
                final student = currentStageStudents[sIdx];
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/mentor/students');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(int.parse(student.avatarBg.replaceFirst('#', '0xFF'))),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            student.avatar,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Student Name & College (Multi-line, Zero Truncation)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${student.role} • ${student.college}',
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Stage Tag or Score Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${student.progress}% Ready*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 14),

          // Bottom Full-Width "View All Students" Navigation Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/mentor/students');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 0.8),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View All Students in Roster',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.arrowRight, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Announcements Bulletin Feed ---
  Widget _buildAnnouncementsFeed(BuildContext context, List<MentorAnnouncementModel> announcements) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Announcements Bulletin Feed*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.5),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(LucideIcons.megaphone, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final ann = announcements[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${ann.title}*',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ann.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ann.content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ann.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 6. AI Insights & Personal Targets ---
  Widget _buildAiInsightsAndGoals(BuildContext context, MentorOverviewData data) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'AI Insights & Targets*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.5),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AI Insight Cards
          Column(
            children: data.insights.map((insight) {
              final isOptimal = insight.status == 'optimal';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isOptimal ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOptimal ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOptimal ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
                      size: 16,
                      color: isOptimal ? const Color(0xFF059669) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${insight.text}*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isOptimal ? const Color(0xFF065F46) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Goals Tracker
          Text(
            'Sarah Jenkins Target Metrics*',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: data.goals.map((goal) {
              final pct = (goal.progress / goal.total).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${goal.label}*',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${goal.progress} / ${goal.total}*',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: AppColors.inputFill,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  // --- Shimmer Loading View ---
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF1F5F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Error View ---
  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Mentor Dashboard',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<MentorOverviewBloc>().add(const FetchMentorOverviewEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Schedule Session Modal Sheet with zero-overflow & smooth keyboard support ---
class _ScheduleSessionSheet extends StatefulWidget {
  final ValueChanged<MentorSessionModel> onSubmit;

  const _ScheduleSessionSheet({required this.onSubmit});

  @override
  State<_ScheduleSessionSheet> createState() => _ScheduleSessionSheetState();
}

class _ScheduleSessionSheetState extends State<_ScheduleSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  String _selectedStudent = 'Rahul Sharma';
  String _sessionType = 'Resume Review';
  String _timeSlot = '10:00 AM - 11:00 AM';
  String _date = 'Today';
  String _day = 'Mon';
  final TextEditingController _linkController = TextEditingController(
    text: 'https://teams.microsoft.com/mock-link',
  );

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      final session = MentorSessionModel(
        id: 's_${DateTime.now().millisecondsSinceEpoch}',
        studentName: _selectedStudent,
        type: _sessionType,
        time: _timeSlot,
        date: _date,
        day: _day,
        meetingLink: _linkController.text.trim(),
        isMock: true,
      );
      widget.onSubmit(session);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomSafe = mediaQuery.padding.bottom;
    final isCompactScreen = screenWidth < 360;

    final horizontalPadding = clampDouble(screenWidth * 0.05, 16.0, 24.0);
    final verticalPadding = clampDouble(screenHeight * 0.02, 14.0, 20.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset > 0 ? bottomInset + 10.0 : (bottomSafe > 0 ? bottomSafe + 12.0 : 20.0),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: clampDouble(screenWidth * 0.1, 32.0, 42.0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with expanded title and close button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Schedule Mentorship Slot*',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.044, 15.0, 17.5),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // Select Student
                  Text(
                    'SELECT STUDENT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStudent,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      'Rahul Sharma',
                      'Priya Singh',
                      'Anjali Gupta',
                      'Gaurav Verma',
                      'Divya Nair',
                      'Sandeep Singh',
                      'Yash Vardhan',
                    ].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStudent = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Session Type
                  Text(
                    'SESSION TYPE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _sessionType,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      'Resume Review',
                      'Mock Interview',
                      'Career Guidance',
                      'Technical Deep Dive',
                      'Project Code Review',
                    ].map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _sessionType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Time Slot
                  Text(
                    'TIME SLOT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _timeSlot,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      '10:00 AM - 11:00 AM',
                      '11:30 AM - 12:30 PM',
                      '2:00 PM - 3:00 PM',
                      '4:00 PM - 5:00 PM',
                      '5:00 PM - 6:00 PM',
                    ].map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        t,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _timeSlot = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Day & Date Selection (Adapts to column if screen is very compact, row otherwise)
                  if (isCompactScreen) ...[
                    // Stacked layout for small screens
                    Text(
                      'DAY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _day,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _day = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'DATE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _date,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: AppColors.inputFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['Today', 'Tomorrow', 'This Week', 'Next Week']
                          .map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _date = val);
                      },
                    ),
                  ] else ...[
                    // Side-by-side layout for standard & large screens
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _day,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: clampDouble(screenWidth * 0.030, 8.0, 12.0),
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                    .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(
                                            d,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _day = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: clampDouble(screenWidth * 0.03, 8.0, 12.0)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _date,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: clampDouble(screenWidth * 0.030, 8.0, 12.0),
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.inputFill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: ['Today', 'Tomorrow', 'This Week', 'Next Week']
                                    .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(
                                            d,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _date = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Meeting Link Field
                  Text(
                    'MEETING LINK (OPTIONAL)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.028, 10.5, 11.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _linkController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: clampDouble(screenWidth * 0.035, 10.0, 14.0),
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(LucideIcons.link, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: clampDouble(screenHeight * 0.016, 12.0, 15.0),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Confirm & Schedule Slot*',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.038, 13.0, 14.5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
