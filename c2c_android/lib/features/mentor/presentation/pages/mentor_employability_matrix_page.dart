import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_employability_matrix_bloc.dart';
import '../../bloc/mentor_employability_matrix_event.dart';
import '../../bloc/mentor_employability_matrix_state.dart';
import '../../data/models/mentor_employability_matrix_model.dart';
import '../widgets/mentor_drawer.dart';

extension StringTitleCase on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Production-grade Employability Matrix Screen for Campus2Corporate Mentor Module.
/// 1:1 Parity with MentorDashboard.tsx Tab 4 (Skill Gap & Matrix) & Tab 5 (Leaderboard & Activity Ticker).
class MentorEmployabilityMatrixPage extends StatelessWidget {
  const MentorEmployabilityMatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorEmployabilityMatrixBloc()
        ..add(const FetchMentorEmployabilityMatrixEvent()),
      child: const _MentorEmployabilityMatrixView(),
    );
  }
}

class _MentorEmployabilityMatrixView extends StatefulWidget {
  const _MentorEmployabilityMatrixView();

  @override
  State<_MentorEmployabilityMatrixView> createState() =>
      _MentorEmployabilityMatrixViewState();
}

class _MentorEmployabilityMatrixViewState
    extends State<_MentorEmployabilityMatrixView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCandidateDiagnosticSheet(
    BuildContext context,
    MentorLeaderboardEntry student,
    String mockSuffix,
  ) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MentorCandidateDiagnosticSheet(
        student: student,
        mockSuffix: mockSuffix,
      ),
    );
  }

  void _openRecordEvaluationSheet(BuildContext context, String mockSuffix) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MentorRecordEvaluationSheet(
        mockSuffix: mockSuffix,
        onSubmit: (name, score, notes) {
          context.read<MentorEmployabilityMatrixBloc>().add(
                RecordEvaluationEvent(
                  studentName: name,
                  score: score,
                  notes: notes,
                ),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.primary,
              content: Text(
                'Mentee Diagnostic Evaluation Recorded Successfully$mockSuffix',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Standard clamped typography & dimensions
    final screenHeaderSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const MentorNavigationDrawer(
        currentRoute: '/mentor/employability',
      ),
      body: SafeArea(
        bottom: true,
        child: BlocBuilder<MentorEmployabilityMatrixBloc,
            MentorEmployabilityMatrixState>(
          builder: (context, state) {
            if (state is MentorEmployabilityMatrixLoading ||
                state is MentorEmployabilityMatrixInitial) {
              return _buildShimmerLoading(context, screenWidth);
            }

            if (state is MentorEmployabilityMatrixError) {
              return _buildErrorState(context, state.message);
            }

            if (state is MentorEmployabilityMatrixLoaded) {
              final data = state.data;
              final isMock = data.isMock;
              final mockSuffix = isMock ? '*' : '';

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context.read<MentorEmployabilityMatrixBloc>().add(
                        const FetchMentorEmployabilityMatrixEvent(),
                      );
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    top: 16.0,
                    bottom: bottomInset == 0 ? 80.0 : bottomInset + 70.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Header Bar
                      _buildHeaderBar(
                        context,
                        screenWidth,
                        screenHeaderSize,
                        subtitleSize,
                        mockSuffix,
                      ),
                      const SizedBox(height: 14),

                      // 2. Quick Assessment CTA Banner
                      _buildQuickBanner(context, screenWidth, mockSuffix),
                      const SizedBox(height: 16),

                      // 3. 4-Tile Responsive KPI Metrics Grid
                      RepaintBoundary(
                        child: _buildSummaryMetrics(
                          context,
                          screenWidth,
                          data,
                          mockSuffix,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Employability Profile Radial Scorecard (1:1 Web Parity)
                      RepaintBoundary(
                        child: _buildScorecard(
                          context,
                          screenWidth,
                          data,
                          mockSuffix,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. Live Skill Gap Bar Chart
                      RepaintBoundary(
                        child: _buildSkillGapChart(
                          context,
                          screenWidth,
                          data,
                          mockSuffix,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Recent Activity Ticker Feed (Submission Logs with Interactive Checks)
                      RepaintBoundary(
                        child: _buildActivityTicker(
                          context,
                          screenWidth,
                          data,
                          mockSuffix,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. Search & Branch Filter Chips
                      _buildSearchAndFilters(
                        context,
                        screenWidth,
                        state,
                        mockSuffix,
                      ),
                      const SizedBox(height: 14),

                      // 8. High-Achiever Leaderboard Matrix
                      RepaintBoundary(
                        child: _buildLeaderboardSection(
                          context,
                          screenWidth,
                          state,
                          mockSuffix,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final state = context.read<MentorEmployabilityMatrixBloc>().state;
          final mockSuffix =
              (state is MentorEmployabilityMatrixLoaded && state.data.isMock)
                  ? '*'
                  : '';
          _openRecordEvaluationSheet(context, mockSuffix);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Add Rating${(context.read<MentorEmployabilityMatrixBloc>().state is MentorEmployabilityMatrixLoaded && (context.read<MentorEmployabilityMatrixBloc>().state as MentorEmployabilityMatrixLoaded).data.isMock) ? '*' : ''}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(MediaQuery.sizeOf(context).width * 0.034, 12.5, 13.5),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // --- 1. Top Header Bar (Uncrowded, Zero Truncation Layout) ---
  Widget _buildHeaderBar(
    BuildContext context,
    double screenWidth,
    double screenHeaderSize,
    double subtitleSize,
    String mockSuffix,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Accessible Drawer Toggle
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: const Icon(
                LucideIcons.menu,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Uncrowded Vertical Title Tier
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skill Matrix$mockSuffix',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: screenHeaderSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Competency overview',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Cohort Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.award, size: 13, color: AppColors.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Cohort 26$mockSuffix',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Quick Assessment CTA Banner ---
  Widget _buildQuickBanner(
    BuildContext context,
    double screenWidth,
    String mockSuffix,
  ) {
    return InkWell(
      onTap: () => _openRecordEvaluationSheet(context, mockSuffix),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Rating$mockSuffix',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Submit score & feedback',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. 4-Tile Responsive KPI Metrics Grid ---
  Widget _buildSummaryMetrics(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixData data,
    String mockSuffix,
  ) {
    final cardWidth = clampDouble(screenWidth * 0.42, 140.0, 190.0);

    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
            context,
            width: cardWidth,
            screenWidth: screenWidth,
            label: 'Cohort Index$mockSuffix',
            value: '${data.overallEmployabilityIndex}%',
            sublabel: 'Readiness average',
            icon: LucideIcons.activity,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            context,
            width: cardWidth,
            screenWidth: screenWidth,
            label: 'Mentees Assessed$mockSuffix',
            value: '${data.totalMenteesEvaluated}',
            sublabel: 'Active candidates',
            icon: LucideIcons.users,
            iconColor: const Color(0xFF0D9488),
            iconBg: const Color(0xFFCCFBF1),
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            context,
            width: cardWidth,
            screenWidth: screenWidth,
            label: 'Elite Ready$mockSuffix',
            value: '${data.eliteReadyCount}',
            sublabel: 'Score >= 85%',
            icon: LucideIcons.award,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFECE6FE),
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            context,
            width: cardWidth,
            screenWidth: screenWidth,
            label: 'Skill Gaps$mockSuffix',
            value: '${data.criticalGapsCount}',
            sublabel: 'Needs attention',
            icon: LucideIcons.alertTriangle,
            iconColor: AppColors.warning,
            iconBg: AppColors.warningLight,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required double width,
    required double screenWidth,
    required String label,
    required String value,
    required String sublabel,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.055, 18.0, 22.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 4. Employability Profile Radial Scorecard (1:1 Web Parity) ---
  Widget _buildScorecard(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixData data,
    String mockSuffix,
  ) {
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Readiness Ring$mockSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Readiness score',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.overallEmployabilityIndex}% Index',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Radial Ring Scoring (Matching Web SVG Circular Gauge)
          Center(
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputFill,
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      value: (data.overallEmployabilityIndex / 100).clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7C3AED),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${data.overallEmployabilityIndex}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.065, 22.0, 26.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'EMPLOYABILITY INDEX',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dimensional Vector Progress Bars (Full Width - Zero Truncation)
          Column(
            children: [
              for (final vec in data.vectors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vec.label.toTitleCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${vec.val} / 100',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (vec.val / 100).clamp(0.0, 1.0),
                          minHeight: 5.5,
                          backgroundColor: AppColors.inputFill,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 5. Live Skill Gap Bar Chart ---
  Widget _buildSkillGapChart(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixData data,
    String mockSuffix,
  ) {
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill Gaps$mockSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Domain mastery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.barChart3,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Skill Bars with Full Width Rendering
          Column(
            children: [
              for (final skill in data.skillGapBars)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Builder(
                    builder: (context) {
                      final color = Color(
                        int.parse(skill.colorHex.replaceFirst('#', '0xFF')),
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  skill.name.toTitleCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${skill.val}% Mastery',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (skill.val / 100).clamp(0.0, 1.0),
                              minHeight: 6.5,
                              backgroundColor: AppColors.inputFill,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 6. Recent Activity Ticker Feed ---
  Widget _buildActivityTicker(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixData data,
    String mockSuffix,
  ) {
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Feed$mockSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Logs & status',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.clipboardCheck,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ticker Items
          Column(
            children: [
              for (final item in data.activityTicker)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<MentorEmployabilityMatrixBloc>().add(
                            ToggleActivityTickerEvent(item.id),
                          );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: item.done
                            ? AppColors.primaryLight.withValues(alpha: 0.5)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.done
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              item.done
                                  ? LucideIcons.checkSquare
                                  : LucideIcons.square,
                              size: 16,
                              color: item.done
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.text,
                                  softWrap: true,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                                    fontWeight: item.done
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: item.done
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    decoration: item.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.time,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w400,
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
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 7. Search & Branch Filter Chips ---
  Widget _buildSearchAndFilters(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixLoaded state,
    String mockSuffix,
  ) {
    final branches = const ['All', 'CSE', 'IT', 'ECE'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ultra-Professional Search Bar – MediaQuery-driven, zero-overflow, clear results
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    // Trigger BLoC filter – shows clear results instantly
                    context.read<MentorEmployabilityMatrixBloc>().add(SearchLeaderboardEvent(val));
                    setState(() {}); // refresh suffixIcon visibility
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.035, 12.5, 14.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search mentee, skill...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: clampDouble(screenWidth * 0.03, 10, 13),
                    ),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Material(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _searchController.clear();
                        context.read<MentorEmployabilityMatrixBloc>().add(const SearchLeaderboardEvent(''));
                        setState(() {});
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(LucideIcons.x, size: 14, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 6),
              const SizedBox(width: 6),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Branch Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final b in branches)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      b,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                        fontWeight: state.selectedBranch.toUpperCase() ==
                                b.toUpperCase()
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: state.selectedBranch.toUpperCase() ==
                                b.toUpperCase()
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    selected:
                        state.selectedBranch.toUpperCase() == b.toUpperCase(),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: state.selectedBranch.toUpperCase() ==
                                b.toUpperCase()
                            ? AppColors.primary
                            : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.lightImpact();
                      context.read<MentorEmployabilityMatrixBloc>().add(
                            FilterLeaderboardBranchEvent(b),
                          );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 8. High-Achiever Leaderboard Matrix ---
  Widget _buildLeaderboardSection(
    BuildContext context,
    double screenWidth,
    MentorEmployabilityMatrixLoaded state,
    String mockSuffix,
  ) {
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Leaderboard$mockSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ranked by score',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.filteredLeaderboard.length} Ranked',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Leaderboard Items
          if (state.filteredLeaderboard.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.searchX,
                    size: 28,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No candidates match your search filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final student in state.filteredLeaderboard)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildCandidateCard(
                      context,
                      screenWidth,
                      student,
                      mockSuffix,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    double screenWidth,
    MentorLeaderboardEntry student,
    String mockSuffix,
  ) {
    final avatarColor =
        Color(int.parse(student.avatarBg.replaceFirst('#', '0xFF')));

    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _showCandidateDiagnosticSheet(context, student, mockSuffix),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Rank & Name + Score Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Box
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name
                              .substring(0, math.min(2, student.name.length))
                              .toUpperCase()
                          : 'ST',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Student Name & Rank
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              student.rank,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                student.name.toTitleCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.038, 13.0, 14.5),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${student.college.toTitleCase()} • ${student.branch.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Score Pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: student.score >= 85
                          ? const Color(0xFFECFDF5)
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: student.score >= 85
                            ? const Color(0xFF059669).withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${student.score}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                            color: student.score >= 85
                                ? const Color(0xFF059669)
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '/100',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bottom Row: Placement Fit + Trailing Chevron
              Row(
                children: [
                  const Icon(
                    LucideIcons.briefcase,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Fit: ${student.fit.toTitleCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Shimmer Loading View ---
  Widget _buildShimmerLoading(BuildContext context, double screenWidth) {
    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ],
      ),
    );
  }

  // --- Error State View ---
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertOctagon, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Matrix Data Load Failed',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<MentorEmployabilityMatrixBloc>().add(
                      const FetchMentorEmployabilityMatrixEvent(),
                    );
              },
              icon: const Icon(LucideIcons.refreshCw, size: 15),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed Candidate Diagnostic Sheet on Tap
class _MentorCandidateDiagnosticSheet extends StatelessWidget {
  final MentorLeaderboardEntry student;
  final String mockSuffix;

  const _MentorCandidateDiagnosticSheet({
    required this.student,
    required this.mockSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name.toTitleCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${student.college.toTitleCase()} • ${student.branch.toUpperCase()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${student.score} / 100',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // Target Placement Fit
              Text(
                'TARGET PLACEMENT FIT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Text(
                  student.fit.toTitleCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Verified Skills
              Text(
                'VERIFIED SKILLS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in student.skills)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        s.toTitleCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Skill Gaps & Focus
              Text(
                'IDENTIFIED SKILL GAP AREAS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  student.gapAreas,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Close CTA
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close Diagnostic',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Evaluation Modal Bottom Sheet with Dynamic Insets & Zero Keyboard Overflow
class _MentorRecordEvaluationSheet extends StatefulWidget {
  final String mockSuffix;
  final void Function(String name, double score, String notes) onSubmit;

  const _MentorRecordEvaluationSheet({
    required this.mockSuffix,
    required this.onSubmit,
  });

  @override
  State<_MentorRecordEvaluationSheet> createState() =>
      _MentorRecordEvaluationSheetState();
}

class _MentorRecordEvaluationSheetState
    extends State<_MentorRecordEvaluationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _studentController = TextEditingController();
  final _notesController = TextEditingController();
  double _score = 88;

  @override
  void dispose() {
    _studentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: clampDouble(screenWidth * 0.045, 16.0, 20.0),
              vertical: 14.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Title Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.award,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Rating${widget.mockSuffix}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: clampDouble(screenWidth * 0.040, 15.0, 17.0),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Mentee Technical Audit',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),

                  // Mentee Name
                  Text(
                    'MENTEE NAME *',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _studentController,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Enter mentee name'
                            : null,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Rahul Sharma, Priya Singh',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      prefixIcon: const Icon(
                        LucideIcons.user,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Score Slider
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rating *',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.032, 12.0, 13.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${_score.round()} / 100',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _score,
                          min: 50,
                          max: 100,
                          divisions: 50,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _score = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Observations
                  Text(
                    'NOTES',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    minLines: 2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Enter diagnostic notes, strengths, and gap areas...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pop(context);
                          widget.onSubmit(
                            _studentController.text.trim(),
                            _score,
                            _notesController.text.trim(),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Confirm${widget.mockSuffix}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.035, 13.5, 14.5),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
