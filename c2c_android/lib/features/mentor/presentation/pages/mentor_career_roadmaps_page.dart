import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_career_roadmaps_bloc.dart';
import '../../bloc/mentor_career_roadmaps_event.dart';
import '../../bloc/mentor_career_roadmaps_state.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/career_roadmaps_shimmer.dart';
import '../widgets/mentor_drawer.dart';

/// Career Roadmaps Screen for Mentor Module.
/// 1:1 feature parity with web (MentorDashboard.tsx roadmaps tab).
/// Zero-truncation across every text line using shorter synonyms.
/// isMock flag drives the `*` badge and "Soon" pill.
class MentorCareerRoadmapsPage extends StatelessWidget {
  const MentorCareerRoadmapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorCareerRoadmapsBloc()
        ..add(const FetchCareerRoadmapsEvent()),
      child: const _MentorCareerRoadmapsView(),
    );
  }
}

class _MentorCareerRoadmapsView extends StatefulWidget {
  const _MentorCareerRoadmapsView();

  @override
  State<_MentorCareerRoadmapsView> createState() =>
      _MentorCareerRoadmapsViewState();
}

class _MentorCareerRoadmapsViewState extends State<_MentorCareerRoadmapsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _pipelineStages = [
    'All',
    'Mentorship',
    'Mock Interview',
    'Placement Ready',
    'Learning Path',
    'Skill Assessment',
    'Hired',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _toTitleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((w) =>
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const MentorNavigationDrawer(
        currentRoute: '/mentor/roadmaps',
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            _buildAppBar(context, topPadding, screenWidth),
            Expanded(
              child: BlocConsumer<MentorCareerRoadmapsBloc,
                  MentorCareerRoadmapsState>(
                listener: (context, state) {
                  if (state is MentorCareerRoadmapsError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: GoogleFonts.plusJakartaSans(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is MentorCareerRoadmapsLoading ||
                      state is MentorCareerRoadmapsInitial) {
                    return const CareerRoadmapsShimmer();
                  }
                  if (state is MentorCareerRoadmapsError) {
                    return _buildErrorState(context, state.message);
                  }
                  if (state is MentorCareerRoadmapsLoaded) {
                    return _buildLoadedContent(
                      context,
                      state,
                      screenWidth,
                      bottomPadding,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // AppBar
  // ────────────────────────────────────────────────────────────────────
  Widget _buildAppBar(
    BuildContext context,
    double topPadding,
    double screenWidth,
  ) {
    final hPadding = math.max(16.0, screenWidth * 0.045);

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 10,
        bottom: 12,
        left: hPadding,
        right: hPadding,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(
              LucideIcons.menu,
              size: 22,
              color: AppColors.textPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<MentorCareerRoadmapsBloc,
                MentorCareerRoadmapsState>(
              builder: (context, state) {
                final isMock = state is MentorCareerRoadmapsLoaded
                    ? state.isMock
                    : false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Career Roadmaps',
                              maxLines: 1,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: math.max(15.0,
                                    math.min(18.0, screenWidth * 0.052)),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        if (isMock) ...[
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Mentee stepper checklists',
                        maxLines: 1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context
                  .read<MentorCareerRoadmapsBloc>()
                  .add(const RefreshCareerRoadmapsEvent());
            },
            icon: const Icon(
              LucideIcons.refreshCw,
              size: 20,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Loaded Content with zero truncation
  // ────────────────────────────────────────────────────────────────────
  Widget _buildLoadedContent(
    BuildContext context,
    MentorCareerRoadmapsLoaded state,
    double screenWidth,
    double bottomPadding,
  ) {
    final hPadding = math.max(14.0, screenWidth * 0.045);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        context
            .read<MentorCareerRoadmapsBloc>()
            .add(const RefreshCareerRoadmapsEvent());
      },
      color: AppColors.primaryPurple,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: hPadding,
          right: hPadding,
          bottom: bottomPadding == 0 ? 24.0 : bottomPadding + 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mock badge banner
            if (state.isMock) _buildMockBanner(context, screenWidth),
            if (state.isMock) const SizedBox(height: 12),

            // Metrics grid
            _buildMetricsGrid(state, screenWidth),
            const SizedBox(height: 16),

            // Search bar
            _buildSearchBar(context, state, screenWidth),
            const SizedBox(height: 14),

            // Pipeline filter chips
            _buildPipelineFilterChips(context, state, screenWidth),
            const SizedBox(height: 18),

            // Results header
            _buildResultsHeader(state, screenWidth),
            const SizedBox(height: 12),

            // Student cards
            if (state.filteredStudents.isEmpty)
              _buildEmptySearchResults(context, screenWidth)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.filteredStudents.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final student = state.filteredStudents[index];
                  return _buildStudentRoadmapCard(
                    context,
                    student,
                    screenWidth,
                    isUpdating: state.isUpdating &&
                        state.updatingStudentId == student.id,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockBanner(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: math.max(12.0, screenWidth * 0.04),
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightLavender,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.sparkles,
            size: 16,
            color: AppColors.primaryPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Mock data (online once API is live)',
                maxLines: 1,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(
    MentorCareerRoadmapsLoaded state,
    double screenWidth,
  ) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Active Checklists (${state.filteredStudents.length})',
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                fontSize: math.max(13.0, math.min(15.0, screenWidth * 0.04)),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Tap item to toggle',
            maxLines: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Metrics Grid
  // ────────────────────────────────────────────────────────────────────
  Widget _buildMetricsGrid(
    MentorCareerRoadmapsLoaded state,
    double screenWidth,
  ) {
    final isSmall = screenWidth < 360;
    final gap = isSmall ? 8.0 : 12.0;

    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Tracks',
                  value: '${state.allStudents.length}',
                  icon: LucideIcons.users,
                  accentColor: AppColors.primaryPurple,
                  bgColor: AppColors.lightLavender,
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _buildMetricCard(
                  title: 'Completed',
                  value: '${state.completedMilestones}',
                  icon: LucideIcons.checkCircle2,
                  accentColor: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'In Progress',
                  value: '${state.inProgressMilestones}',
                  icon: LucideIcons.clock,
                  accentColor: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  screenWidth: screenWidth,
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: _buildMetricCard(
                  title: 'Ready',
                  value: '${state.placementReadyCount}',
                  icon: LucideIcons.award,
                  accentColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF3E8FF),
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    required double screenWidth,
  }) {
    final iconBoxSize = screenWidth < 360 ? 32.0 : 38.0;
    final iconPadding = math.max(14.0, screenWidth * 0.035);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: iconPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: screenWidth < 360 ? 17 : 19,
              color: accentColor,
            ),
          ),
          SizedBox(width: screenWidth < 360 ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: math.max(16.0, math.min(20.0, screenWidth * 0.055)),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Professional Search Bar
  // ────────────────────────────────────────────────────────────────────
  Widget _buildSearchBar(
    BuildContext context,
    MentorCareerRoadmapsLoaded state,
    double screenWidth,
  ) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          context
              .read<MentorCareerRoadmapsBloc>()
              .add(SearchCareerRoadmapsEvent(val));
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search name, role, or milestone',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(
              LucideIcons.search,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  color: AppColors.textMuted,
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<MentorCareerRoadmapsBloc>()
                        .add(const SearchCareerRoadmapsEvent(''));
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Pipeline Filter Chips
  // ────────────────────────────────────────────────────────────────────
  Widget _buildPipelineFilterChips(
    BuildContext context,
    MentorCareerRoadmapsLoaded state,
    double screenWidth,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _pipelineStages.map((stage) {
          final isSelected = state.selectedStage == stage;
          final chipPadding = screenWidth < 360 ? 10.0 : 14.0;
          final chipVertical = screenWidth < 360 ? 6.0 : 7.0;
          final fontSize = screenWidth < 360 ? 11.0 : 12.0;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: isSelected ? AppColors.primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<MentorCareerRoadmapsBloc>()
                      .add(FilterCareerRoadmapsByStageEvent(stage));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: chipPadding,
                    vertical: chipVertical,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.border,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    stage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: fontSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Student Roadmap Card
  // ────────────────────────────────────────────────────────────────────
  Widget _buildStudentRoadmapCard(
    BuildContext context,
    MentorStudentModel student,
    double screenWidth, {
    required bool isUpdating,
  }) {
    final avatarColor = _parseAvatarColor(student.avatarBg);
    final completedCount =
        student.milestones.where((m) => m.status == 'done').length;
    final totalCount = student.milestones.length;
    final isSmall = screenWidth < 360;
    final cardPadding = isSmall ? 14.0 : 16.0;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0x060F172A),
              blurRadius: 12,
              offset: Offset(0, isSmall ? 2 : 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name/meta
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isSmall ? 40 : 44,
                  height: isSmall ? 40 : 44,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    student.avatar,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: isSmall ? 14 : 15,
                    ),
                  ),
                ),
                SizedBox(width: isSmall ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _toTitleCase(student.name),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: math.max(13.0, math.min(15.0, screenWidth * 0.041)),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isUpdating) ...[
                            const SizedBox(width: 6),
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_toTitleCase(student.college)} - ${_toTitleCase(student.role)}',
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmall ? 11 : 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 12 : 14),

            // Progress card
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 10 : 12,
                vertical: isSmall ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEDF2F7), width: 0.8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: isSmall ? 4 : 6,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Career Progress',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isSmall ? 11.5 : 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE6FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _toTitleCase(student.pipelineStage),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${student.progress}% ($completedCount/$totalCount)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: isSmall ? 11.5 : 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (student.progress / 100).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmall ? 12 : 14),

            // Milestone checklist header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Milestone Checklist',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isSmall ? 11.5 : 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: InkWell(
                    onTap: () => _showAddMilestoneSheet(context, student),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.plusCircle,
                            size: 13,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Add',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSmall ? 11 : 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Milestone rows
            if (student.milestones.isEmpty)
              Padding(
                padding: EdgeInsets.all(isSmall ? 8 : 10),
                child: Text(
                  'No milestones yet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: student.milestones.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, mIdx) {
                  final milestone = student.milestones[mIdx];
                  return _buildMilestoneRow(
                    context,
                    student,
                    milestone,
                    mIdx,
                    screenWidth,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _parseAvatarColor(String avatarBg) {
    try {
      if (avatarBg.startsWith('0xFF') || avatarBg.startsWith('0xff')) {
        return Color(int.parse(avatarBg));
      } else if (avatarBg.contains('blue')) {
        return const Color(0xFF2563EB);
      } else if (avatarBg.contains('emerald') || avatarBg.contains('green')) {
        return const Color(0xFF059669);
      } else if (avatarBg.contains('purple')) {
        return const Color(0xFF7C3AED);
      }
      return AppColors.primaryPurple;
    } catch (_) {
      return AppColors.primaryPurple;
    }
  }

  Widget _buildMilestoneRow(
    BuildContext context,
    MentorStudentModel student,
    MilestoneModel milestone,
    int milestoneIndex,
    double screenWidth,
  ) {
    final isDone = milestone.status == 'done';
    final isProgress = milestone.status == 'progress';
    final isSmall = screenWidth < 360;

    late Color cardBg;
    late Color borderColor;
    late Color statusTextColor;
    late String statusLabel;
    late IconData statusIcon;

    if (isDone) {
      cardBg = const Color(0xFFF5F3FF);
      borderColor = const Color(0xFFDDD6FE);
      statusTextColor = const Color(0xFF059669);
      statusLabel = 'Completed';
      statusIcon = LucideIcons.checkCheck;
    } else if (isProgress) {
      cardBg = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      statusTextColor = const Color(0xFFD97706);
      statusLabel = 'In Progress';
      statusIcon = LucideIcons.clock;
    } else {
      cardBg = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      statusTextColor = AppColors.textSecondary;
      statusLabel = 'Pending';
      statusIcon = LucideIcons.circle;
    }

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.read<MentorCareerRoadmapsBloc>().add(
                ToggleCareerMilestoneEvent(
                  studentId: student.id,
                  milestoneIndex: milestoneIndex,
                ),
              );
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 10,
            vertical: isSmall ? 7 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: Row(
            children: [
              // Checkbox / state indicator
              Container(
                width: isSmall ? 20 : 22,
                height: isSmall ? 20 : 22,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primaryPurple
                      : isProgress
                          ? const Color(0xFFD97706)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDone
                        ? AppColors.primaryPurple
                        : isProgress
                            ? const Color(0xFFD97706)
                            : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(
                        LucideIcons.check,
                        size: 13,
                        color: Colors.white,
                      )
                    : isProgress
                        ? const Icon(
                            LucideIcons.clock,
                            size: 11,
                            color: Colors.white,
                          )
                        : null,
              ),
              SizedBox(width: isSmall ? 8 : 10),

              // Milestone name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _toTitleCase(milestone.name),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmall ? 12 : 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDone
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 11,
                          color: statusTextColor,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              statusLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusTextColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ────────────────────────────────────────────────────────────────────
  // Add Milestone Bottom Sheet (keyboard-safe)
  // ────────────────────────────────────────────────────────────────────
  void _showAddMilestoneSheet(
    BuildContext context,
    MentorStudentModel student,
  ) {
    HapticFeedback.lightImpact();
    final milestoneController = TextEditingController();
    String selectedStatus = 'pending';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final screenWidth = MediaQuery.sizeOf(sheetContext).width;
            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
            final navBarPad = MediaQuery.paddingOf(sheetContext).bottom;

            return Padding(
              padding: EdgeInsets.only(
                bottom: bottomInset > 0 ? bottomInset : 0,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A0F172A),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(
                  top: 20,
                  left: math.max(16.0, screenWidth * 0.05),
                  right: math.max(16.0, screenWidth * 0.05),
                  bottom:
                      bottomInset > 0 ? 12.0 : navBarPad + 20.0,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sheet header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.checkCircle2,
                              color: AppColors.primaryPurple,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Add Career Milestone',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Mentee: ${_toTitleCase(student.name)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title label
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Milestone Title',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title textfield
                      TextField(
                        controller: milestoneController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. AWS Cloud Cert',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.target,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Status selector
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Initial Status',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildStatusChip(
                            label: 'Pending',
                            icon: LucideIcons.circle,
                            isSelected: selectedStatus == 'pending',
                            color: AppColors.textSecondary,
                            onTap: () =>
                                setModalState(() => selectedStatus = 'pending'),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(
                            label: 'Progress',
                            icon: LucideIcons.clock,
                            isSelected: selectedStatus == 'progress',
                            color: const Color(0xFFD97706),
                            onTap: () => setModalState(
                                () => selectedStatus = 'progress'),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(
                            label: 'Done',
                            icon: LucideIcons.checkCheck,
                            isSelected: selectedStatus == 'done',
                            color: const Color(0xFF059669),
                            onTap: () =>
                                setModalState(() => selectedStatus = 'done'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = milestoneController.text.trim();
                            if (name.isEmpty) {
                              HapticFeedback.heavyImpact();
                              ScaffoldMessenger.of(
                                builderContext,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text('Enter milestone title'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            HapticFeedback.mediumImpact();
                            context.read<MentorCareerRoadmapsBloc>().add(
                                  AddCareerMilestoneEvent(
                                    studentId: student.id,
                                    milestoneName: name,
                                    status: selectedStatus,
                                  ),
                                );
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Milestone added for ${_toTitleCase(student.name)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.primaryPurple,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.plus, size: 18),
                              const SizedBox(width: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Assign Milestone',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildStatusChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: isSelected
            ? color.withValues(alpha: 0.12)
            : AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Empty State
  // ────────────────────────────────────────────────────────────────────
  Widget _buildEmptySearchResults(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: math.max(24.0, screenWidth * 0.06),
        horizontal: 20,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.lightLavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.searchX,
              size: 28,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Roadmaps Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: math.max(8.0, screenWidth * 0.04)),
            child: Text(
              'No mentee matches your search or filter.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              context
                  .read<MentorCareerRoadmapsBloc>()
                  .add(const FilterCareerRoadmapsByStageEvent('All'));
              context
                  .read<MentorCareerRoadmapsBloc>()
                  .add(const SearchCareerRoadmapsEvent(''));
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Reset Filters',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Error State
  // ────────────────────────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Failed to Load Roadmaps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: math.max(8.0, MediaQuery.sizeOf(context).width * 0.05),
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context
                    .read<MentorCareerRoadmapsBloc>()
                    .add(const FetchCareerRoadmapsEvent());
              },
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
