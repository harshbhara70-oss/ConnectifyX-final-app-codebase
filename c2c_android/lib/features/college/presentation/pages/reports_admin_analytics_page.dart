import 'dart:math' as math;
import 'dart:ui' show clampDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/components/custom_bottom_nav.dart';
import '../../bloc/college_report_bloc.dart';
import '../../domain/models/reports_analytics_model.dart';
import '../widgets/college_drawer.dart';

extension _StringExt on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class ReportsAdminAnalyticsPage extends StatelessWidget {
  const ReportsAdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollegeReportBloc()..add(const FetchReportsEvent(session: '2023-24')),
      child: const _ReportsContentView(),
    );
  }
}

class _ReportsContentView extends StatefulWidget {
  const _ReportsContentView();

  @override
  State<_ReportsContentView> createState() => _ReportsContentViewState();
}

class _ReportsContentViewState extends State<_ReportsContentView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _navIndex = 1; 
  String? _hoveredTier;
  String? _selectedDeptDetail;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? AppColors.textPrimary : AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(
              isSuccess ? LucideIcons.checkCircle2 : LucideIcons.alertCircle,
              color: isSuccess ? AppColors.success : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return BlocConsumer<CollegeReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportLoaded && state.toastMessage != null) {
          _showToast(state.toastMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: const CollegeNavigationDrawer(currentRoute: '/college/reports'),
          appBar: _buildTopAppBar(context, screenWidth),
          floatingActionButton: _buildFloatingQuickActionButton(context),
          body: SafeArea(
            bottom: true,
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                final currentSession =
                    (state is ReportLoaded) ? state.selectedSession : '2023-24';
                context.read<CollegeReportBloc>().add(FetchReportsEvent(session: currentSession));
              },
              child: _buildBody(context, screenWidth, bottomInset, state),
            ),
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _navIndex,
            onTap: (index) {
              setState(() => _navIndex = index);
              _handleNavigation(index);
            },
            onFabPressed: () => _openGenerateReportWizard(context, state),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // CLEAN APP BAR (NO TRUNCATION - ACTIONS RELOCATED TO BODY)
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildTopAppBar(BuildContext context, double screenWidth) {
    final titleFontSize = clampDouble(screenWidth * 0.048, 17.0, 20.0);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
        onPressed: () {
          HapticFeedback.lightImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text(
        'Analytics',
        style: GoogleFonts.plusJakartaSans(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: AppColors.textSecondary, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.go('/college/operations/communication');
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BODY
  // ---------------------------------------------------------------------------
  Widget _buildBody(
    BuildContext context,
    double screenWidth,
    double bottomInset,
    ReportState state,
  ) {
    if (state is ReportLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is ReportError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to Load Reports',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<CollegeReportBloc>().add(const FetchReportsEvent(session: '2023-24'));
                },
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! ReportLoaded) {
      return const SizedBox.shrink();
    }

    final data = state.data;
    final isMock = data.isMock;
    final asterisk = isMock ? '*' : '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(
        left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
        right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
        top: 14.0,
        bottom: bottomInset == 0 ? 24.0 : bottomInset + 18.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Relocated Top Search & Export Action Bar
          _buildSearchAndActionBar(context, state),
          const SizedBox(height: 16),

          // 2. Top Session Toolbar & Soon/Preview Badge
          _buildSessionToolbar(context, screenWidth, state, isMock),
          const SizedBox(height: 16),

          // 3. Card 1: Overall Placement Gauge
          RepaintBoundary(
            child: _buildOverallPlacementCard(context, screenWidth, data, asterisk),
          ),
          const SizedBox(height: 16),

          // 4. Card 2: Placement by Department (Scrollable to prevent overflow)
          RepaintBoundary(
            child: _buildDepartmentPlacementCard(context, screenWidth, data, asterisk),
          ),
          const SizedBox(height: 16),

          // 5. Card 3: Salary Bands / Company Tier Distribution Bar
          RepaintBoundary(
            child: _buildCompanyTierCard(context, screenWidth, data, asterisk),
          ),
          const SizedBox(height: 16),

          // 6. Card 4: Active Students Trend Card
          RepaintBoundary(
            child: _buildActiveStudentsCard(context, screenWidth, data, asterisk),
          ),
          const SizedBox(height: 16),

          // 7. Card 5: Average AI Mastery Score Card
          RepaintBoundary(
            child: _buildAiMasteryCard(context, screenWidth, data, asterisk),
          ),
          const SizedBox(height: 16),

          // 8. Card 6: Hiring Drive Performance Section
          RepaintBoundary(
            child: _buildHiringDrivesSection(context, screenWidth, state, asterisk),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. RELOCATED TOP SEARCH & REPORT GENERATE BAR
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndActionBar(BuildContext context, ReportLoaded state) {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.8),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<CollegeReportBloc>().add(SearchReportsEvent(val));
              },
              decoration: InputDecoration(
                hintText: 'Search analytics...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.textMuted, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, color: AppColors.textMuted, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          context.read<CollegeReportBloc>().add(const SearchReportsEvent(''));
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Generate Report Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              HapticFeedback.lightImpact();
              _openGenerateReportWizard(context, state);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.fileText, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Export',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
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
    );
  }

  // ---------------------------------------------------------------------------
  // 2. SESSION TOOLBAR & MOCK BADGE
  // ---------------------------------------------------------------------------
  Widget _buildSessionToolbar(
    BuildContext context,
    double screenWidth,
    ReportLoaded state,
    bool isMock,
  ) {
    final headerFontSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final subFontSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Placement Intel',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Academic Session ${state.selectedSession}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: subFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isMock)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Preview Mode*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Session Selector Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: ['2023-24', '2024-25', '2025-26'].map((session) {
              final isSelected = state.selectedSession == session;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<CollegeReportBloc>().add(ChangeSessionEvent(session));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : const [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 13,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Session $session',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. CARD 1: OVERALL PLACEMENT GAUGE
  // ---------------------------------------------------------------------------
  Widget _buildOverallPlacementCard(
    BuildContext context,
    double screenWidth,
    ReportsAnalyticsDataModel data,
    String asterisk,
  ) {
    final sectionTitleSize = clampDouble(screenWidth * 0.033, 11.0, 12.0);
    final statCounterSize = clampDouble(screenWidth * 0.065, 22.0, 26.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
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
                'OVERALL PLACEMENT',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+12% vs LY$asterisk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Donut Radial Progress
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(140, 140),
                    painter: _DonutGaugePainter(
                      progress: data.placedPct / 100.0,
                      trackColor: const Color(0xFFF3E8FF),
                      progressColor: AppColors.primary,
                      strokeWidth: 13,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.placedPct}%$asterisk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: statCounterSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'PLACED',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Footer Counts: Eligible & Offers
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ELIGIBLE STUDENTS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.eligibleCount.toString()}$asterisk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: AppColors.border),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL OFFERS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.offersCount.toString()}$asterisk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CARD 2: PLACEMENT BY DEPARTMENT (ZERO OVERFLOW SCROLLABLE)
  // ---------------------------------------------------------------------------
  Widget _buildDepartmentPlacementCard(
    BuildContext context,
    double screenWidth,
    ReportsAnalyticsDataModel data,
    String asterisk,
  ) {
    final sectionTitleSize = clampDouble(screenWidth * 0.033, 11.0, 12.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
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
                'DEPT BREAKDOWN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Placed', AppColors.primary),
                  const SizedBox(width: 10),
                  _buildLegendItem('Total', const Color(0xFFF3E8FF)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Scrollable Department Bars to guarantee zero horizontal overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.departments.map((dept) {
                  final double placedRatio =
                      dept.total > 0 ? (dept.placed / dept.total).clamp(0.0, 1.0) : 0.0;
                  final double placedHeight = 110 * placedRatio;
                  const double totalHeight = 110.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedDeptDetail =
                              '${dept.dept}: ${dept.placed} Placed / ${dept.total} Total (${dept.pct}%$asterisk)';
                        });
                        _showToast('${dept.dept}: ${dept.placed}/${dept.total} Placed (${dept.pct}%)');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${dept.pct}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 14,
                                height: math.max(placedHeight, 6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Container(
                                width: 14,
                                height: totalHeight,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dept.dept,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_selectedDeptDetail != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedDeptDetail!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. CARD 3: SALARY BANDS / COMPANY TIER DISTRIBUTION
  // ---------------------------------------------------------------------------
  Widget _buildCompanyTierCard(
    BuildContext context,
    double screenWidth,
    ReportsAnalyticsDataModel data,
    String asterisk,
  ) {
    final sectionTitleSize = clampDouble(screenWidth * 0.033, 11.0, 12.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
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
                'SALARY BANDS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionTitleSize,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Tier Breakdown$asterisk',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Multi-segmented Horizontal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 28,
              child: Row(
                children: [
                  Flexible(
                    flex: math.max((data.tierDist.tier1 * 10).toInt(), 1),
                    child: _buildTierSegment('Tier 1', data.tierDist.tier1, AppColors.primary),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: math.max((data.tierDist.tier2 * 10).toInt(), 1),
                    child: _buildTierSegment('Tier 2', data.tierDist.tier2, const Color(0xFF8B5CF6)),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: math.max((data.tierDist.tier3 * 10).toInt(), 1),
                    child: _buildTierSegment('Tier 3', data.tierDist.tier3, const Color(0xFFC4B5FD)),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: math.max((data.tierDist.others * 10).toInt(), 1),
                    child: _buildTierSegment('Others', data.tierDist.others, const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Interactive Legend Wrap with Shorter Synonyms
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTierLegendChip('Tier 1: 12-40L', '${data.tierDist.tier1.toInt()}%', AppColors.primary),
              _buildTierLegendChip('Tier 2: 7-12L', '${data.tierDist.tier2.toInt()}%', const Color(0xFF8B5CF6)),
              _buildTierLegendChip('Tier 3: 4-7L', '${data.tierDist.tier3.toInt()}%', const Color(0xFFC4B5FD)),
              _buildTierLegendChip('Others: Startup/NGO', '${data.tierDist.others.toInt()}%', const Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierSegment(String tier, double pct, Color color) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _hoveredTier = '$tier (${pct.toInt()}%)');
      },
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: Text(
          '${pct.toInt()}%',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color == const Color(0xFFCBD5E1) ? AppColors.textPrimary : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTierLegendChip(String label, String pct, Color color) {
    final isSelected = _hoveredTier?.startsWith(label.split(':')[0]) ?? false;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _hoveredTier = isSelected ? null : label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($pct)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. CARD 4: ACTIVE STUDENTS TREND
  // ---------------------------------------------------------------------------
  Widget _buildActiveStudentsCard(
    BuildContext context,
    double screenWidth,
    ReportsAnalyticsDataModel data,
    String asterisk,
  ) {
    final sectionTitleSize = clampDouble(screenWidth * 0.033, 11.0, 12.0);
    final counterSize = clampDouble(screenWidth * 0.065, 20.0, 24.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE STUDENTS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${data.monthlyAvg.toString()}$asterisk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: counterSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Monthly Avg',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.trendingUp, color: AppColors.primary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Bézier Trend Curve Area Graph
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _ActiveTrendGraphPainter(
                gradientColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Month Footer
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'].map((m) {
                return Text(
                  m,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. CARD 5: AVERAGE AI MASTERY SCORE
  // ---------------------------------------------------------------------------
  Widget _buildAiMasteryCard(
    BuildContext context,
    double screenWidth,
    ReportsAnalyticsDataModel data,
    String asterisk,
  ) {
    final scoreSize = clampDouble(screenWidth * 0.075, 26.0, 32.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Color(0xFFFDE047), size: 16),
              const SizedBox(width: 6),
              Text(
                'AI MASTERY INDEX',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFECE6FE),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.aiMastery.toStringAsFixed(1)}$asterisk',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: scoreSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ 100',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFECE6FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Competency Progress Bars
          _buildCompetencyBar('Code Quality', data.codeQuality),
          const SizedBox(height: 10),
          _buildCompetencyBar('Architecture Design', data.archDesign),
          const SizedBox(height: 10),
          _buildCompetencyBar('Scalability Analysis', data.scalability),
        ],
      ),
    );
  }

  Widget _buildCompetencyBar(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFECE6FE),
              ),
            ),
            Text(
              '$value%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100.0,
            minHeight: 6,
            backgroundColor: const Color(0xFF4338CA).withValues(alpha: 0.6),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 8. CARD 6: HIRING DRIVE PERFORMANCE TABLE & LIST
  // ---------------------------------------------------------------------------
  Widget _buildHiringDrivesSection(
    BuildContext context,
    double screenWidth,
    ReportLoaded state,
    String asterisk,
  ) {
    final titleSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Hiring Drives',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.slidersHorizontal, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Filter Status',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showStatusFilterSheet(context, state.statusFilter);
                  },
                ),
                IconButton(
                  icon: const Icon(LucideIcons.download, size: 18, color: AppColors.textSecondary),
                  tooltip: 'Export CSV',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CollegeReportBloc>().add(const ExportDrivesCsvEvent());
                  },
                ),
              ],
            ),
          ),

          // Active Status Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['ALL', 'CLOSED', 'IN PROGRESS', 'UPCOMING'].map((status) {
                  final isSelected = state.statusFilter.toUpperCase() == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ChoiceChip(
                      label: Text(
                        status == 'ALL' ? 'All Drives' : status.toTitleCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        context.read<CollegeReportBloc>().add(FilterDriveStatusEvent(status));
                      },
                      selectedColor: AppColors.primaryLight,
                      backgroundColor: AppColors.inputFill,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Drives List
          if (state.filteredDrives.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
              child: Center(
                child: Text(
                  'No hiring drive records match your criteria.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredDrives.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final drive = state.filteredDrives[index];
                return _buildDriveItemTile(context, screenWidth, drive, asterisk);
              },
            ),

          // Footer Link to Full Drives Management
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/college/drives');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All Active Drives',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.arrowRight, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveItemTile(
    BuildContext context,
    double screenWidth,
    DrivePerformanceRow drive,
    String asterisk,
  ) {
    final titleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 13.0);

    Color statusBg;
    Color statusText;
    if (drive.status.toUpperCase() == 'CLOSED') {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
    } else if (drive.status.toUpperCase() == 'IN PROGRESS') {
      statusBg = AppColors.primaryLight;
      statusText = AppColors.primary;
    } else {
      statusBg = const Color(0xFFFFFBEB);
      statusText = const Color(0xFFD97706);
    }

    IconData logoIcon;
    Color logoBgColor;
    Color logoIconColor;
    if (drive.logoType == 'cloud') {
      logoIcon = LucideIcons.cloud;
      logoBgColor = const Color(0xFFEDE9FE);
      logoIconColor = const Color(0xFF7C3AED);
    } else if (drive.logoType == 'atlassian') {
      logoIcon = LucideIcons.layers;
      logoBgColor = const Color(0xFFE0F2FE);
      logoIconColor = const Color(0xFF0284C7);
    } else if (drive.logoType == 'bank') {
      logoIcon = LucideIcons.dollarSign;
      logoBgColor = const Color(0xFFE0E7FF);
      logoIconColor = const Color(0xFF4F46E5);
    } else {
      logoIcon = LucideIcons.zap;
      logoBgColor = const Color(0xFFFCE7F3);
      logoIconColor = const Color(0xFFDB2777);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDriveDetailsModal(context, drive, asterisk);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: logoBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(logoIcon, color: logoIconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drive.companyName.toTitleCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          drive.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
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
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      drive.status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Metrics Tier with Shorter Synonyms
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    'App: ${drive.applicants}$asterisk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Sel: ${drive.selected}$asterisk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Conv: ${drive.conversionPct}%$asterisk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'CTC: ${drive.avgCtcLpa}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. DRIVE DETAILS MODAL (WITH COMPLETE SAFE AREA & BOTTOM INSET PADDING)
  // ---------------------------------------------------------------------------
  void _showDriveDetailsModal(
    BuildContext context,
    DrivePerformanceRow drive,
    String asterisk,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final safeBottom = MediaQuery.paddingOf(ctx).bottom;

        return SafeArea(
          bottom: true,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: safeBottom > 0 ? safeBottom + 12 : 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          drive.companyName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    drive.role,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),
                  _buildDetailRow('Status', drive.status),
                  _buildDetailRow('Total Applicants', '${drive.applicants}$asterisk'),
                  _buildDetailRow('Selected Candidates', '${drive.selected}$asterisk'),
                  _buildDetailRow('Conversion Rate', '${drive.conversionPct}%$asterisk'),
                  _buildDetailRow('Average CTC Offered', drive.avgCtcLpa),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/college/drives');
                      },
                      child: const Text('View Drive Pipeline'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 10. STATUS FILTER SHEET (WITH COMPLETE SAFE AREA PADDING)
  // ---------------------------------------------------------------------------
  void _showStatusFilterSheet(BuildContext context, String currentFilter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final safeBottom = MediaQuery.paddingOf(ctx).bottom;

        return SafeArea(
          bottom: true,
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: safeBottom > 0 ? safeBottom + 12 : 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Drives by Status',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...['ALL', 'CLOSED', 'IN PROGRESS', 'UPCOMING'].map((s) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s == 'ALL' ? 'All Drives' : s.toTitleCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: currentFilter.toUpperCase() == s
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: currentFilter.toUpperCase() == s
                        ? const Icon(LucideIcons.check, color: AppColors.primary, size: 18)
                        : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      context.read<CollegeReportBloc>().add(FilterDriveStatusEvent(s));
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 11. GENERATE REPORT WIZARD (SAFE FROM ANDROID NAV BAR & WORKING CLIENT-SIDE)
  // ---------------------------------------------------------------------------
  void _openGenerateReportWizard(BuildContext context, ReportState state) {
    final currentSession = (state is ReportLoaded) ? state.selectedSession : '2023-24';
    String selectedSession = currentSession;
    String format = 'pdf';
    bool includeAiScores = true;
    final List<String> selectedDepts = ['CS/IT', 'ECE', 'Mech', 'MBA', 'Civil'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final viewInsetsBottom = MediaQuery.of(ctx).viewInsets.bottom;
            final safeBottom = MediaQuery.paddingOf(ctx).bottom;

            return SafeArea(
              bottom: true,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
                ),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: viewInsetsBottom > 0 ? viewInsetsBottom + 16 : (safeBottom > 0 ? safeBottom + 16 : 24),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.fileText, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Generate Report',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Target Session Selector
                      Text(
                        'Target Academic Session',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSession,
                            isExpanded: true,
                            items: ['2023-24', '2024-25', '2025-26'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  'Academic Year $s',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedSession = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Include Departments Toggle Chips
                      Text(
                        'Include Departments',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['CS/IT', 'ECE', 'Mech', 'MBA', 'Civil'].map((dept) {
                          final isIncluded = selectedDepts.contains(dept);
                          return FilterChip(
                            label: Text(
                              dept,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: isIncluded ? FontWeight.w700 : FontWeight.w600,
                                color: isIncluded ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            selected: isIncluded,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  selectedDepts.add(dept);
                                } else {
                                  selectedDepts.remove(dept);
                                }
                              });
                            },
                            selectedColor: AppColors.primaryLight,
                            backgroundColor: AppColors.inputFill,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: BorderSide.none,
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Include AI Scores Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: includeAiScores,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setModalState(() => includeAiScores = val ?? true);
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() => includeAiScores = !includeAiScores);
                              },
                              child: Text(
                                'Include AI Mastery & Competency Scores',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Export Format Toggle
                      Text(
                        'Export Format',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => format = 'pdf'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: format == 'pdf' ? AppColors.primary : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.fileText,
                                      size: 16,
                                      color: format == 'pdf' ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PDF Report',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: format == 'pdf' ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => format = 'excel'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: format == 'excel' ? const Color(0xFF059669) : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.sheet,
                                      size: 16,
                                      color: format == 'excel' ? Colors.white : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Excel / CSV',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: format == 'excel' ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Actions: Cancel / Submit
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(modalCtx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(modalCtx);
                                context.read<CollegeReportBloc>().add(
                                      GenerateExecutiveReportEvent(
                                        session: selectedSession,
                                        format: format,
                                        departments: selectedDepts,
                                        includeAiScores: includeAiScores,
                                      ),
                                    );
                              },
                              child: const Text('Generate & Download'),
                            ),
                          ),
                        ],
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

  // ---------------------------------------------------------------------------
  // 12. FLOATING QUICK ACTION BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildFloatingQuickActionButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'reports_quick_fab',
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onPressed: () {
        HapticFeedback.lightImpact();
        _showToast('Placement Intelligence Drawer ready.');
      },
      child: const Icon(LucideIcons.barChart3, size: 22),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        // Already on Reports / Analytics
        break;
      case 2:
        context.go('/college/drives');
        break;
      case 3:
        context.go('/college/students');
        break;
      case 4:
        context.go('/college/settings');
        break;
    }
  }
}

// ---------------------------------------------------------------------------
// CUSTOM PAINTER: DONUT RADIAL PROGRESS GAUGE
// ---------------------------------------------------------------------------
class _DonutGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _DonutGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background circle
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// ---------------------------------------------------------------------------
// CUSTOM PAINTER: BÉZIER TREND CURVE AREA GRAPH
// ---------------------------------------------------------------------------
class _ActiveTrendGraphPainter extends CustomPainter {
  final Color gradientColor;

  _ActiveTrendGraphPainter({required this.gradientColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final linePath = Path();
    linePath.moveTo(0, h * 0.65);
    linePath.quadraticBezierTo(w * 0.18, h * 0.45, w * 0.35, h * 0.65);
    linePath.quadraticBezierTo(w * 0.55, h * 0.25, w * 0.75, h * 0.75);
    linePath.quadraticBezierTo(w * 0.88, h * 0.40, w, h * 0.45);

    final areaPath = Path.from(linePath);
    areaPath.lineTo(w, h);
    areaPath.lineTo(0, h);
    areaPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          gradientColor.withValues(alpha: 0.35),
          gradientColor.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = gradientColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, strokePaint);

    // End circle indicator
    final endPoint = Offset(w, h * 0.45);
    final circlePaint = Paint()..color = gradientColor;
    canvas.drawCircle(endPoint, 4.0, circlePaint);
  }

  @override
  bool shouldRepaint(covariant _ActiveTrendGraphPainter oldDelegate) {
    return oldDelegate.gradientColor != gradientColor;
  }
}