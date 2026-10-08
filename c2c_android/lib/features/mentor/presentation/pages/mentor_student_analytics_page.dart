import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/student_analytics_bloc.dart';
import '../../bloc/student_analytics_event.dart';
import '../../bloc/student_analytics_state.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/mentor_drawer.dart';
import '../widgets/student_analytics_shimmer.dart';

extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return '';
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class MentorStudentAnalyticsPage extends StatelessWidget {
  const MentorStudentAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudentAnalyticsBloc()..add(const FetchStudentAnalyticsEvent()),
      child: const _MentorStudentAnalyticsView(),
    );
  }
}

class _MentorStudentAnalyticsView extends StatefulWidget {
  const _MentorStudentAnalyticsView();

  @override
  State<_MentorStudentAnalyticsView> createState() => _MentorStudentAnalyticsViewState();
}

class _MentorStudentAnalyticsViewState extends State<_MentorStudentAnalyticsView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    _searchFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _openAddMenteeModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<StudentAnalyticsBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _AddMenteeBottomSheet(
        onSubmit: (newStudent) {
          bloc.add(AddStudentEvent(newStudent));
        },
      ),
    );
  }

  /// Shorter synonyms for milestone OKR items ensuring zero text truncation
  String _getShortMilestoneTitle(String original) {
    switch (original.trim().toLowerCase()) {
      case 'resume completed':
        return 'Resume Ready';
      case 'linkedin profile':
        return 'LinkedIn Set';
      case 'aptitude training':
        return 'Aptitude Prep';
      case 'hr interview':
        return 'HR Mock';
      case 'placement':
        return 'Job Placed';
      default:
        return original;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Standard Responsive Typography
    final screenHeaderSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final itemTitleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);
    final badgeSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    // Dynamic Safe Insets
    final bottomInset = MediaQuery.paddingOf(context).bottom == 0 ? 16.0 : MediaQuery.paddingOf(context).bottom;
    const horizontalPadding = 16.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.bg,
      drawer: const MentorNavigationDrawer(currentRoute: '/mentor/students'),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<StudentAnalyticsBloc, StudentAnalyticsState>(
          listener: (context, state) {
            if (state is StudentAnalyticsLoaded && state.feedbackMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.feedbackMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: subtitleSize,
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
            if (state is StudentAnalyticsLoading || state is StudentAnalyticsInitial) {
              return const StudentAnalyticsShimmer();
            }

            if (state is StudentAnalyticsError) {
              return _buildErrorState(context, state.message, sectionHeaderSize, subtitleSize);
            }

            if (state is! StudentAnalyticsLoaded) {
              return const SizedBox.shrink();
            }

            final activeStudent = state.selectedStudent;
            final isMock = state.isMock;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 14.0,
                bottom: bottomInset + 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Clean Zero-Truncation Top Navigation Header with simple *
                  _buildHeaderBar(
                    context,
                    screenHeaderSize: screenHeaderSize,
                    subtitleSize: subtitleSize,
                    isMock: isMock,
                  ),
                  const SizedBox(height: 14),

                  // 2. Full-Width Add Mentee Action (Below AppBar on Top of Body, Zero Overflow)
                  _buildActionBar(context),
                  const SizedBox(height: 14),

                  // 3. Pipeline Stage Filter Chips
                  _buildPipelineStageChips(
                    context,
                    state: state,
                    badgeSize: badgeSize,
                  ),
                  const SizedBox(height: 16),

                  // 4. Assigned Student Roster Card (Spacious, Zero-Truncation)
                  _buildRosterSection(
                    context,
                    state: state,
                    sectionHeaderSize: sectionHeaderSize,
                    itemTitleSize: itemTitleSize,
                    subtitleSize: subtitleSize,
                    badgeSize: badgeSize,
                  ),
                  const SizedBox(height: 20),

                  // 5. Selected Student Detailed Analytics View (Uncrowded, Zero-Truncation, Zero-Overflow)
                  RepaintBoundary(
                    child: _buildStudentDetailsSection(
                      context,
                      student: activeStudent,
                      sectionHeaderSize: sectionHeaderSize,
                      itemTitleSize: itemTitleSize,
                      subtitleSize: subtitleSize,
                      badgeSize: badgeSize,
                      isMock: isMock,
                      isSavingNote: state.isSavingNote,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Top App Header (Zero Truncation, Simple * for Mock) ---
  Widget _buildHeaderBar(
    BuildContext context, {
    required double screenHeaderSize,
    required double subtitleSize,
    required bool isMock,
  }) {
    return Row(
      children: [
        // Drawer toggle button
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
            ),
            child: Icon(LucideIcons.menu, color: context.txtPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 12),

        // Title and Subtitle with Simple * (No Truncation)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Student Analytics',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: screenHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (isMock) ...[
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: screenHeaderSize + 2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'Mentee Readiness*',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: context.txtSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Add Mentee Button (Below AppBar on Top of Body, 100% Overflow-Free) ---
  Widget _buildActionBar(BuildContext context) {
    return InkWell(
      onTap: () => _openAddMenteeModal(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.userPlus, color: Colors.white, size: 17),
            const SizedBox(width: 8),
            Text(
              'Add Mentee Record*',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Pipeline Stage Filter Chips ---
  Widget _buildPipelineStageChips(
    BuildContext context, {
    required StudentAnalyticsLoaded state,
    required double badgeSize,
  }) {
    const stages = [
      'All',
      'Enrolled',
      'Skill Assessment',
      'Learning Path',
      'Mentorship',
      'Mock Interview',
      'Placement Ready',
      'Hired',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: stages.map((stage) {
          final isSelected = state.selectedStage.toLowerCase() == stage.toLowerCase();
          final count = stage == 'All'
              ? state.allStudents.length
              : state.allStudents.where((s) => s.pipelineStage.toLowerCase() == stage.toLowerCase()).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<StudentAnalyticsBloc>().add(FilterPipelineStageEvent(stage));
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.surf,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : context.brdr,
                    width: 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: badgeSize,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : context.txtSecondary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : context.surfAlt,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : context.txtSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- Assigned Student Roster Card (Spacious, Zero-Truncation) ---
  Widget _buildRosterSection(
    BuildContext context, {
    required StudentAnalyticsLoaded state,
    required double sectionHeaderSize,
    required double itemTitleSize,
    required double subtitleSize,
    required double badgeSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Tier - Full Width, Zero Truncation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assigned Student Roster*',
                softWrap: true,
                maxLines: 2,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionHeaderSize,
                  fontWeight: FontWeight.w700,
                  color: context.txtPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tap mentee to inspect',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: context.txtSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.filteredStudents.length} Active*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ultra-Professional Search Bar
          Container(
            constraints: const BoxConstraints(minHeight: 44),
            decoration: BoxDecoration(
              color: context.surfAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.brdr, width: 0.8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 17, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (val) {
                      context.read<StudentAnalyticsBloc>().add(SearchStudentEvent(val));
                    },
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: itemTitleSize,
                      fontWeight: FontWeight.w500,
                      color: context.txtPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by student, college, role, skills...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: context.txtMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _searchController.clear();
                      context.read<StudentAnalyticsBloc>().add(const SearchStudentEvent(''));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Roster Strip (Generous Space, Multi-line College, Overflow Free)
          if (state.filteredStudents.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.users, size: 32, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'No students match your search filter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                      color: context.txtSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final rosterCardWidth = constraints.maxWidth > 500 ? 270.0 : (constraints.maxWidth * 0.72).clamp(220.0, 270.0);
                return SizedBox(
                  height: 144,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.filteredStudents.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final student = state.filteredStudents[index];
                      final isSelected = student.id == state.selectedStudent.id;
                      final avatarBgColor = Color(int.tryParse(student.avatarBg) ?? 0xFF6366F1);

                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<StudentAnalyticsBloc>().add(SelectStudentEvent(student.id));
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: rosterCardWidth,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.6) : context.surfAlt,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : context.brdr,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: avatarBgColor,
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
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          student.name.toTitleCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected ? AppColors.primary : context.txtPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${student.progress}% Ready*',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.success,
                                          ),
                                        ),
                                      ],
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
                                    Text(
                                      student.college,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w500,
                                        color: context.txtSecondary,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      student.role,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w400,
                                        color: context.txtMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Deep Student Progress Analytics Section (Uncrowded, Zero-Truncation, Zero-Overflow) ---
  Widget _buildStudentDetailsSection(
    BuildContext context, {
    required MentorStudentModel student,
    required double sectionHeaderSize,
    required double itemTitleSize,
    required double subtitleSize,
    required double badgeSize,
    required bool isMock,
    required bool isSavingNote,
  }) {
    final avatarColor = Color(int.tryParse(student.avatarBg) ?? 0xFF6366F1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. Student Profile Header Card (Spacious, Multi-line, Zero Truncation)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Tier: Large Avatar + Student Name + Badges Wrap
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Box
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: avatarColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      student.avatar,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Student Name & Badges Wrap
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${student.name.toTitleCase()}*',
                          maxLines: 2,
                          softWrap: true,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: sectionHeaderSize + 1,
                            fontWeight: FontWeight.w800,
                            color: context.txtPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                student.semester,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: badgeSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: context.surfAlt,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: context.brdr, width: 0.8),
                              ),
                              child: Text(
                                'GPA: ${student.gpa}*',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: badgeSize,
                                  fontWeight: FontWeight.w700,
                                  color: context.txtSecondary,
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
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              // Institution Tier (Full Width, Zero Truncation)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.graduationCap, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.college,
                          softWrap: true,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: context.txtPrimary,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          student.branch,
                          softWrap: true,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                            color: context.txtSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Career Role Tier (Full Width, Zero Truncation)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.briefcase, size: 15, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${student.role} at ${student.company}',
                      softWrap: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.txtPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Contact Bar Wrap (Protected against overflow)
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.mail, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            student.email,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: context.txtSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.phone, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        student.phone,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: context.txtSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // B. Readiness Score Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Radial Progress Gauge
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: student.progress / 100.0,
                      strokeWidth: 6.5,
                      backgroundColor: context.surfAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${student.progress}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.txtPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Title & Pipeline Stage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Readiness Score*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: itemTitleSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Overall Placement Ready metric from verified tasks',
                      softWrap: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w400,
                        color: context.txtSecondary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Stage: ${student.pipelineStage}*',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: badgeSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // C. Employability Metrics Grid (2x2) - Responsive Flex Layout (Zero Overflow)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: LucideIcons.fileText,
                label: 'Resume Score',
                value: '${student.resumeScore} / 100*',
                badgeSize: badgeSize,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: LucideIcons.award,
                label: 'Aptitude Score',
                value: '${student.aptitudeScore} / 100*',
                badgeSize: badgeSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                icon: LucideIcons.checkCircle2,
                label: 'Attendance Rate',
                value: '${student.attendance}%*',
                badgeSize: badgeSize,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                icon: LucideIcons.target,
                label: 'Match Score',
                value: '${student.matchScore}%*',
                badgeSize: badgeSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // D. Skills Assessment Ratings & Verification Stack
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skills Assessment Ratings*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: sectionHeaderSize,
                  fontWeight: FontWeight.w700,
                  color: context.txtPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Technical skill bar
              _buildRatingBar(
                context,
                title: 'Technical Skill',
                percentage: student.techSkillRating,
                color: AppColors.primary,
                subtitleSize: subtitleSize,
              ),
              const SizedBox(height: 12),

              // Communication & soft skills bar
              _buildRatingBar(
                context,
                title: 'Communication Skills',
                percentage: student.communicationRating,
                color: const Color(0xFF8B5CF6),
                subtitleSize: subtitleSize,
              ),
              const SizedBox(height: 12),

              // Soft skills bar
              _buildRatingBar(
                context,
                title: 'Problem Solving Vector',
                percentage: student.softSkillRating,
                color: const Color(0xFF06B6D4),
                subtitleSize: subtitleSize,
              ),
              const SizedBox(height: 14),

              // Skill Stack Chips
              Text(
                'Verified Skill Stack*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w700,
                  color: context.txtSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: student.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.brdr, width: 0.8),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w600,
                        color: context.txtPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // E. Career Milestones Tracker (Shorter Synonyms, Zero Truncation)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
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
                    child: Text(
                      'Career Milestones*',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Tap to toggle',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: context.txtMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: student.milestones.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, mIdx) {
                  final milestone = student.milestones[mIdx];
                  final isDone = milestone.status == 'done';
                  final isProgress = milestone.status == 'progress';
                  final shortTitle = _getShortMilestoneTitle(milestone.name);

                  return InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<StudentAnalyticsBloc>().add(
                            ToggleStudentMilestoneEvent(
                              studentId: student.id,
                              milestoneIndex: mIdx,
                            ),
                          );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.surfAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.brdr, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? LucideIcons.checkCircle2
                                : isProgress
                                    ? LucideIcons.clock
                                    : LucideIcons.circle,
                            size: 18,
                            color: isDone
                                ? AppColors.success
                                : isProgress
                                    ? AppColors.warning
                                    : context.txtMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$shortTitle*',
                              maxLines: 2,
                              softWrap: true,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: itemTitleSize,
                                fontWeight: FontWeight.w600,
                                color: context.txtPrimary,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppColors.successLight
                                  : isProgress
                                      ? AppColors.warningLight
                                      : context.surf,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              milestone.status == 'progress' ? 'IN WORK' : milestone.status.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDone
                                    ? AppColors.success
                                    : isProgress
                                        ? AppColors.warning
                                        : context.txtMuted,
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
        ),
        const SizedBox(height: 16),

        // F. Private Notes Vault & Inline Form
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.brdr, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.lock, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Private Notes Vault*',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Confidential mentor observations & feedback records',
                softWrap: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: context.txtSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Notes list
              if (student.notes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(
                    'No private notes logged yet for this mentee.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: subtitleSize,
                      color: context.txtMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: student.notes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, nIdx) {
                    final note = student.notes[nIdx];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.surfAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.brdr, width: 0.8),
                      ),
                      child: Text(
                        note,
                        softWrap: true,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: context.txtPrimary,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 14),

              // Add Note Input Box + Save Memo Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 42),
                      decoration: BoxDecoration(
                        color: context.surfAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.brdr, width: 0.8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: context.txtPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Log custom notes details...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            color: context.txtMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSavingNote
                        ? null
                        : () {
                            final text = _noteController.text.trim();
                            if (text.isEmpty) return;
                            HapticFeedback.lightImpact();
                            context.read<StudentAnalyticsBloc>().add(
                                  AddStudentNoteEvent(
                                    studentId: student.id,
                                    note: text,
                                  ),
                                );
                            _noteController.clear();
                            _noteFocusNode.unfocus();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isSavingNote
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Save Memo*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: badgeSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Metric Grid Card (Zero Overflow Guaranteed) ---
  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required double badgeSize,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const Icon(LucideIcons.chevronRight, size: 15, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: context.txtPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: badgeSize,
              fontWeight: FontWeight.w500,
              color: context.txtSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- Rating Progress Bar ---
  Widget _buildRatingBar(
    BuildContext context, {
    required String title,
    required int percentage,
    required Color color,
    required double subtitleSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w600,
                  color: context.txtPrimary,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage / 100.0,
            minHeight: 6,
            backgroundColor: context.surfAlt,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // --- Error State View ---
  Widget _buildErrorState(
    BuildContext context,
    String message,
    double sectionHeaderSize,
    double subtitleSize,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Analytics',
              style: GoogleFonts.plusJakartaSans(
                fontSize: sectionHeaderSize,
                fontWeight: FontWeight.w700,
                color: context.txtPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w400,
                color: context.txtSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<StudentAnalyticsBloc>().add(const FetchStudentAnalyticsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Add Mentee Bottom Sheet Form with Smooth Keyboard Handling ---
class _AddMenteeBottomSheet extends StatefulWidget {
  final ValueChanged<MentorStudentModel> onSubmit;

  const _AddMenteeBottomSheet({required this.onSubmit});

  @override
  State<_AddMenteeBottomSheet> createState() => _AddMenteeBottomSheetState();
}

class _AddMenteeBottomSheetState extends State<_AddMenteeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController(text: 'Delhi Technological University');
  final _branchController = TextEditingController(text: 'Computer Science');
  final _semesterController = TextEditingController(text: '8th Semester');
  final _gpaController = TextEditingController(text: '9.0');
  final _roleController = TextEditingController(text: 'Software Engineer');
  final _companyController = TextEditingController(text: 'Stripe');
  final _skillsController = TextEditingController(text: 'Flutter, Dart, Firebase');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    _semesterController.dispose();
    _gpaController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _skillsController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final name = _nameController.text.trim();
    final initials = name.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join('');
    final skills = _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final newStudent = MentorStudentModel(
      id: 'st_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      college: _collegeController.text.trim(),
      branch: _branchController.text.trim(),
      semester: _semesterController.text.trim(),
      gpa: _gpaController.text.trim(),
      role: _roleController.text.trim(),
      company: _companyController.text.trim(),
      progress: 65,
      matchScore: 88,
      resumeScore: 85,
      aptitudeScore: 84,
      techSkillRating: 82,
      softSkillRating: 80,
      communicationRating: 85,
      avatar: initials.isNotEmpty ? initials : 'ST',
      avatarBg: '0xFF6366F1',
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : '${name.toLowerCase().replaceAll(' ', '.')}@dtu.edu',
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : '+91 98765 43210',
      notes: ['Profile created by Mentor Dr. Sarah Jenkins.'],
      skills: skills.isNotEmpty ? skills : ['Flutter', 'Dart'],
      attendance: 92,
      milestones: const [
        MilestoneModel(name: 'Resume Completed', status: 'done'),
        MilestoneModel(name: 'LinkedIn Profile', status: 'done'),
        MilestoneModel(name: 'Aptitude Training', status: 'progress'),
        MilestoneModel(name: 'HR Interview', status: 'pending'),
        MilestoneModel(name: 'Placement', status: 'pending'),
      ],
      pipelineStage: 'Enrolled',
      isMock: true,
    );

    widget.onSubmit(newStudent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: keyboardHeight > 0 ? keyboardHeight + 16 : 24,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.brdr,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Modal Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Register Mentee Record*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: context.txtPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 19),
                      color: context.txtSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Form Fields
                _buildFormField(
                  context,
                  controller: _nameController,
                  label: 'Full Name *',
                  hint: 'e.g. Aman Sharma',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Student name is required' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _collegeController,
                        label: 'College',
                        hint: 'e.g. DTU Delhi',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _branchController,
                        label: 'Branch / Dept',
                        hint: 'e.g. Computer Science',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _semesterController,
                        label: 'Semester',
                        hint: 'e.g. 8th Semester',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _gpaController,
                        label: 'GPA / CGPA',
                        hint: 'e.g. 9.1',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _roleController,
                        label: 'Target Role',
                        hint: 'e.g. Frontend Engineer',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildFormField(
                        context,
                        controller: _companyController,
                        label: 'Target Company',
                        hint: 'e.g. Stripe',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildFormField(
                  context,
                  controller: _skillsController,
                  label: 'Skills (comma separated)',
                  hint: 'e.g. React, TypeScript, Node.js',
                ),
                const SizedBox(height: 18),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Save Mentee Record*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
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
    );
  }

  Widget _buildFormField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: context.txtSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.txtPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: context.txtMuted,
            ),
            filled: true,
            fillColor: context.surfAlt,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.brdr, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.brdr, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
