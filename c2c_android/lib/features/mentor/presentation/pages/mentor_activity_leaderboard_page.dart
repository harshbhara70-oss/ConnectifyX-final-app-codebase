import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_activity_leaderboard_bloc.dart';
import '../../bloc/mentor_activity_leaderboard_event.dart';
import '../../bloc/mentor_activity_leaderboard_state.dart';
import '../../data/models/mentor_activity_leaderboard_model.dart';
import '../widgets/mentor_drawer.dart';

/// Production-ready Activity & Leaderboard Screen for Mentor Module
/// Guaranteed ZERO truncation, zero ellipsis, responsive layout & full Android navigation bar safety.
class MentorActivityLeaderboardPage extends StatelessWidget {
  const MentorActivityLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorActivityLeaderboardBloc()
        ..add(const FetchActivityLeaderboardEvent()),
      child: const _MentorActivityLeaderboardView(),
    );
  }
}

class _MentorActivityLeaderboardView extends StatefulWidget {
  const _MentorActivityLeaderboardView();

  @override
  State<_MentorActivityLeaderboardView> createState() =>
      _MentorActivityLeaderboardViewState();
}

class _MentorActivityLeaderboardViewState
    extends State<_MentorActivityLeaderboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int _selectedSegmentIndex = 0; // 0: All, 1: Activity Feed, 2: Leaderboard

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogActivityBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final screenHeight = MediaQuery.sizeOf(sheetContext).height;
        final screenWidth = MediaQuery.sizeOf(sheetContext).width;
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        final navBarPadding = MediaQuery.paddingOf(sheetContext).bottom;

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: math.max(bottomInset, navBarPadding) + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Handle Bar
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
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightLavender,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.listPlus,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log New Activity',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(
                                    screenWidth * 0.046, 16.0, 19.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Record mentee submission or milestone event',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Text field
                  Text(
                    'Activity Description',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    autofocus: true,
                    maxLines: 3,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Rahul Sharma submitted Java Mock Evaluation',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryPurple,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          HapticFeedback.mediumImpact();
                          context
                              .read<MentorActivityLeaderboardBloc>()
                              .add(CreateActivityLogEvent(text));
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Activity Log',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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

  void _showEvaluateCandidateBottomSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final nameController = TextEditingController();
    final fitController = TextEditingController();
    final notesController = TextEditingController();
    final collegeController = TextEditingController();
    final branchController = TextEditingController();
    double currentScore = 88;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setModalState) {
            final screenHeight = MediaQuery.sizeOf(sheetContext).height;
            final screenWidth = MediaQuery.sizeOf(sheetContext).width;
            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
            final navBarPadding = MediaQuery.paddingOf(sheetContext).bottom;

            return Container(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.90,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: math.max(bottomInset, navBarPadding) + 24,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SafeArea(
                top: false,
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle Bar
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
                      const SizedBox(height: 16),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.award,
                              color: AppColors.primaryPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Evaluate Candidate',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(
                                        screenWidth * 0.046, 16.0, 19.0),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Record aggregate employability index',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Student Name
                      Text(
                        'Student Name *',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Rahul Sharma',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Placement Fit
                      Text(
                        'Target Role / Company Fit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: fitController,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Stripe (React) or Atlassian (Backend)',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // College & Branch Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'College',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: collegeController,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. IIT Delhi',
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Branch',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: branchController,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. CSE',
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Score Slider Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Diagnostic Score Index',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: currentScore >= 85
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: currentScore >= 85
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${currentScore.round()} / 100',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: currentScore >= 85
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(builderContext).copyWith(
                          activeTrackColor: AppColors.primaryPurple,
                          inactiveTrackColor: const Color(0xFFE2E8F0),
                          thumbColor: AppColors.primaryPurple,
                          overlayColor: AppColors.primaryPurple
                              .withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: currentScore,
                          min: 40,
                          max: 100,
                          divisions: 60,
                          onChanged: (val) {
                            setModalState(() {
                              currentScore = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Notes / Gap Areas
                      Text(
                        'Identified Gap Areas / Mentor Memos',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Distributed key-value cache tuning',
                          filled: true,
                          fillColor: AppColors.inputFill,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0), width: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            if (name.isNotEmpty) {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<MentorActivityLeaderboardBloc>()
                                  .add(RecordCandidateEvaluationEvent(
                                    studentName: name,
                                    score: currentScore,
                                    fit: fitController.text.trim().isNotEmpty
                                        ? fitController.text.trim()
                                        : 'Tech Fit',
                                    notes: notesController.text.trim(),
                                    college: collegeController
                                            .text.trim().isNotEmpty
                                        ? collegeController.text.trim()
                                        : 'Campus Candidate',
                                    branch: branchController
                                            .text.trim().isNotEmpty
                                        ? branchController.text.trim()
                                        : 'CSE',
                                  ));
                              Navigator.pop(sheetContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Submit & Update Leaderboard',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const MentorNavigationDrawer(currentRoute: '/mentor/activity'),
      appBar: _buildAppBar(context, screenWidth),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<MentorActivityLeaderboardBloc,
            MentorActivityLeaderboardState>(
          listener: (context, state) {
            if (state is ActivityLeaderboardLoaded &&
                state.toastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.toastMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ActivityLeaderboardLoading ||
                state is ActivityLeaderboardInitial) {
              return _buildShimmerLoading(screenWidth);
            }

            if (state is ActivityLeaderboardError) {
              return _buildErrorState(context, state.message);
            }

            if (state is ActivityLeaderboardLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryPurple,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context
                      .read<MentorActivityLeaderboardBloc>()
                      .add(const FetchActivityLeaderboardEvent(isRefresh: true));
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.only(
                    bottom: bottomInset == 0 ? 24.0 : bottomInset + 16.0,
                    top: 16.0,
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Soon Badge
                      _buildHeaderTitle(context, state.data.isMock, screenWidth),
                      const SizedBox(height: 16),

                      // Metric Summary Counters
                      RepaintBoundary(
                        child: _buildMetricSummaryGrid(state.data, screenWidth),
                      ),
                      const SizedBox(height: 20),

                      // Segment Switcher (All / Activities / Leaderboard)
                      _buildSegmentSwitcher(screenWidth),
                      const SizedBox(height: 16),

                      // Search & Quick Action Strip
                      _buildSearchBarAndActions(context, state, screenWidth),
                      const SizedBox(height: 18),

                      // Dynamic Content based on Segment Switcher
                      if (_selectedSegmentIndex == 0) ...[
                        // ALL: Ticker Section + Leaderboard Section
                        _buildActivityTickerSection(context, state, screenWidth),
                        const SizedBox(height: 24),
                        _buildLeaderboardSection(context, state, screenWidth),
                      ] else if (_selectedSegmentIndex == 1) ...[
                        // Activity Feed Only
                        _buildActivityTickerSection(context, state, screenWidth),
                      ] else ...[
                        // Leaderboard Matrix Only
                        _buildLeaderboardSection(context, state, screenWidth),
                      ],
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          LucideIcons.menu,
          color: AppColors.textPrimary,
          size: 22,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Activity & Ranks',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.044, 15.5, 17.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Logs & Rank Matrix',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            LucideIcons.rotateCw,
            color: AppColors.textSecondary,
            size: 20,
          ),
          tooltip: 'Refresh Data',
          onPressed: () {
            HapticFeedback.lightImpact();
            context
                .read<MentorActivityLeaderboardBloc>()
                .add(const FetchActivityLeaderboardEvent(isRefresh: true));
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 0.8,
        ),
      ),
    );
  }

  Widget _buildHeaderTitle(
      BuildContext context, bool isMock, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      isMock
                          ? 'Activity & Ranks *'
                          : 'Activity & Ranks',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(
                            screenWidth * 0.052, 18.0, 22.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isMock) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightLavender,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryPurple.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.sparkles,
                            size: 11,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Soon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Track mentee velocity & diagnostic rankings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 14.0),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSummaryGrid(
      MentorActivityLeaderboardData data, double screenWidth) {
    final isMock = data.isMock;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.activity,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFECE6FE),
                  label: 'Total Logs',
                  value: isMock
                      ? '${data.totalActivities} *'
                      : '${data.totalActivities}',
                  screenWidth: screenWidth,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.checkCircle2,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                  label: 'Completed',
                  value: isMock
                      ? '${data.completedActivities} *'
                      : '${data.completedActivities}',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFE2E8F0), thickness: 0.8),
          Row(
            children: [
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.trendingUp,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF3E8FF),
                  label: 'Avg Score',
                  value: isMock
                      ? '${data.averageScore}% *'
                      : '${data.averageScore}%',
                  screenWidth: screenWidth,
                ),
              ),
              Container(width: 1, height: 48, color: const Color(0xFFE2E8F0)),
              Expanded(
                child: _buildSingleMetric(
                  icon: LucideIcons.award,
                  iconColor: const Color(0xFFF59E0B),
                  iconBg: const Color(0xFFFFFBEB),
                  label: 'Top Ranker',
                  value: data.leaderboard.isNotEmpty
                      ? data.leaderboard.first.name
                      : 'N/A',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSingleMetric({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.042, 15.0, 18.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentSwitcher(double screenWidth) {
    final segments = ['All Views', 'Activity Feed', 'Leaderboard'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _selectedSegmentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedSegmentIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  segments[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBarAndActions(BuildContext context,
      ActivityLeaderboardLoaded state, double screenWidth) {
    return Column(
      children: [
        Row(
          children: [
            // Search field
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context
                        .read<MentorActivityLeaderboardBloc>()
                        .add(SearchActivityLeaderboardEvent(val));
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search logs, students or roles...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      LucideIcons.search,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              context
                                  .read<MentorActivityLeaderboardBloc>()
                                  .add(const SearchActivityLeaderboardEvent(''));
                            },
                            child: const Icon(
                              LucideIcons.x,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Quick Add Action
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'activity') {
                  _showLogActivityBottomSheet(context);
                } else if (val == 'evaluate') {
                  _showEvaluateCandidateBottomSheet(context);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              itemBuilder: (popContext) => [
                PopupMenuItem(
                  value: 'activity',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.listPlus,
                          size: 16, color: AppColors.primaryPurple),
                      const SizedBox(width: 10),
                      Text(
                        'Log Activity Item',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'evaluate',
                  child: Row(
                    children: [
                      const Icon(LucideIcons.award,
                          size: 16, color: Color(0xFF10B981)),
                      const SizedBox(width: 10),
                      Text(
                        'Evaluate Mentee',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityTickerSection(BuildContext context,
      ActivityLeaderboardLoaded state, double screenWidth) {
    final activities = state.filteredActivities;
    final activeFilter = state.activityFilter;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Subtitle + Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity Ticker',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.042, 15.0, 17.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Submission logs with status toggles',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.030, 11.0, 12.0),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.plusCircle,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
                tooltip: 'Log Activity',
                onPressed: () => _showLogActivityBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Status Chips (All / Done / Pending)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ['All', 'Done', 'Pending'].map((status) {
              final isSelected = activeFilter == status;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<MentorActivityLeaderboardBloc>()
                      .add(FilterActivityStatusEvent(status));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryPurple
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    status == 'All'
                        ? 'All (${state.data.activityTicker.length})'
                        : status == 'Done'
                            ? 'Resolved (${state.data.completedActivities})'
                            : 'Pending (${state.data.totalActivities - state.data.completedActivities})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Activities List
          if (activities.isEmpty)
            _buildEmptyActivityFeed(screenWidth)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, index) {
                final item = activities[index];
                return _buildActivityItemTile(context, item, screenWidth);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItemTile(
      BuildContext context, MentorActivityModel item, double screenWidth) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          LucideIcons.trash2,
          color: Color(0xFFEF4444),
          size: 18,
        ),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        context
            .read<MentorActivityLeaderboardBloc>()
            .add(DeleteActivityLogEvent(item.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.done
              ? AppColors.lightLavender.withValues(alpha: 0.4)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.done
                ? AppColors.primaryPurple.withValues(alpha: 0.2)
                : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              context
                  .read<MentorActivityLeaderboardBloc>()
                  .add(ToggleActivityEvent(item.id));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox status
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: item.done,
                        activeColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF94A3B8),
                          width: 1.2,
                        ),
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          context
                              .read<MentorActivityLeaderboardBloc>()
                              .add(ToggleActivityEvent(item.id));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text & Time (NO truncation, full multi-line readable)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(
                                screenWidth * 0.035, 13.0, 14.5),
                            fontWeight: FontWeight.w600,
                            color: item.done
                                ? AppColors.primaryPurple
                                : AppColors.textPrimary,
                            decoration:
                                item.done ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clock,
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.time,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (item.done) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Resolved',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.textMuted,
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

  Widget _buildLeaderboardSection(BuildContext context,
      ActivityLeaderboardLoaded state, double screenWidth) {
    final leaderboard = state.filteredLeaderboard;
    final activeTier = state.leaderboardFilter;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High-Achiever Leaderboard Matrix',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.042, 15.0, 17.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Ranks by aggregate employability index',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize:
                            clampDouble(screenWidth * 0.030, 11.0, 12.0),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  LucideIcons.userPlus,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                tooltip: 'Evaluate Mentee',
                onPressed: () => _showEvaluateCandidateBottomSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Chips (All / Top 3 / Elite >=85 / In Training <85)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: ['All', 'Top 3', 'Elite', 'In Training'].map((tier) {
              final isSelected = activeTier == tier;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<MentorActivityLeaderboardBloc>()
                      .add(FilterLeaderboardTierEvent(tier));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    tier == 'All'
                        ? 'All Candidates'
                        : tier == 'Top 3'
                            ? '🥇 Top 3 Podium'
                            : tier == 'Elite'
                                ? 'Elite (85+)'
                                : 'In Training (<85)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Leaderboard Cards
          if (leaderboard.isEmpty)
            _buildEmptyLeaderboard(screenWidth)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, index) {
                final candidate = leaderboard[index];
                return _buildLeaderboardCandidateCard(candidate, screenWidth);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCandidateCard(
      MentorLeaderboardCandidateModel candidate, double screenWidth) {
    final isPodium = candidate.rank.contains('🥇') ||
        candidate.rank.contains('🥈') ||
        candidate.rank.contains('🥉');

    Color rankBadgeColor = const Color(0xFFF1F5F9);
    Color rankTextColor = AppColors.textPrimary;
    Color borderHighlight = const Color(0xFFE2E8F0);

    if (candidate.rank.contains('🥇')) {
      rankBadgeColor = const Color(0xFFFEF3C7);
      rankTextColor = const Color(0xFFB45309);
      borderHighlight = const Color(0xFFF59E0B).withValues(alpha: 0.4);
    } else if (candidate.rank.contains('🥈')) {
      rankBadgeColor = const Color(0xFFF1F5F9);
      rankTextColor = const Color(0xFF475569);
      borderHighlight = const Color(0xFF94A3B8).withValues(alpha: 0.4);
    } else if (candidate.rank.contains('🥉')) {
      rankBadgeColor = const Color(0xFFFFEDD5);
      rankTextColor = const Color(0xFFC2410C);
      borderHighlight = const Color(0xFFF97316).withValues(alpha: 0.4);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPodium ? borderHighlight : const Color(0xFFE2E8F0),
          width: isPodium ? 1.2 : 0.8,
        ),
        boxShadow: isPodium
            ? [
                BoxShadow(
                  color: borderHighlight.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Rank Badge, Candidate Name, Score Meter
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank Pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rankBadgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  candidate.rank,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: rankTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Name & Fit (NO truncation, full readable text)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(
                            screenWidth * 0.038, 14.0, 16.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      candidate.fit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
              ),

              // Score Indicator Box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: candidate.score >= 85
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: candidate.score >= 85
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${candidate.score}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: candidate.score >= 85
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                    Text(
                      'INDEX',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: candidate.score >= 85
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // College & Branch Info (NO truncation, full readable text)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  LucideIcons.graduationCap,
                  size: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${candidate.college} • ${candidate.branch}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Skill Tags Wrap
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: candidate.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              );
            }).toList(),
          ),

          if (candidate.gapAreas.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 0.6,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      LucideIcons.sparkles,
                      size: 12,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Focus: ${candidate.gapAreas}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyActivityFeed(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightLavender,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.inbox,
              size: 24,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No Activity Logs Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'All mentee submission tasks have been resolved or filtered out.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboard(double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.award,
              size: 24,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No Ranked Candidates',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Evaluate mentees to build the live leaderboard index.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth * 0.6,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Workspace',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context
                    .read<MentorActivityLeaderboardBloc>()
                    .add(const FetchActivityLeaderboardEvent());
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
