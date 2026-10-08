import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_feedback_bloc.dart';
import '../../bloc/mentor_feedback_event.dart';
import '../../bloc/mentor_feedback_state.dart';
import '../../data/models/mentor_feedback_model.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/feedback_shimmer.dart';
import '../widgets/mentor_drawer.dart';

/// Feedback Section Screen for Mentor Module
/// Complete 1:1 parity with web frontend (src/pages/MentorDashboard.tsx Tab 9)
/// Audited for zero truncation, clamped font scaling, and smooth keyboard avoidance.
class MentorFeedbackPage extends StatelessWidget {
  const MentorFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorFeedbackBloc()..add(const FetchFeedbackDataEvent()),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showQuickModal(BuildContext context, FeedbackLoaded state) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _QuickFeedbackModal(
        students: state.data.students,
        initialStudent: state.selectedCandidate,
        initialTech: state.selectedTechRating,
        initialComm: state.selectedCommRating,
        onSubmit: (name, tech, comm, notes) {
          context.read<MentorFeedbackBloc>().add(
                SubmitFeedbackEvent(
                  studentName: name,
                  techRating: tech,
                  commRating: comm,
                  comments: notes,
                ),
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmall = screenWidth < 360;

    return BlocConsumer<MentorFeedbackBloc, MentorFeedbackState>(
      listener: (context, state) {
        if (state is FeedbackLoaded && state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.toastMessage!,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isMock = state is FeedbackLoaded ? state.data.isMock : true;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: const MentorNavigationDrawer(currentRoute: '/mentor/feedback'),
          appBar: _buildAppBar(context, screenWidth, isMock),
          body: SafeArea(
            bottom: true,
            child: _buildBodyContent(context, state, screenWidth, isSmall),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    double screenWidth,
    bool isMock,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
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
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Feedback Section',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.048, 16.0, 19.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isMock) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                '*',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: const [
        SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.border, height: 1.0),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    MentorFeedbackState state,
    double screenWidth,
    bool isSmall,
  ) {
    if (state is FeedbackLoading) {
      return const FeedbackShimmer();
    }

    if (state is FeedbackError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 44, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Connection Error',
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
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<MentorFeedbackBloc>().add(const FetchFeedbackDataEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Retry Sync', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    if (state is FeedbackLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<MentorFeedbackBloc>().add(const FetchFeedbackDataEvent(isRefresh: true));
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: 14,
            bottom: MediaQuery.paddingOf(context).bottom == 0 ? 20.0 : MediaQuery.paddingOf(context).bottom + 12.0,
            left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
            right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Metric Counters Grid (2x2)
              _buildMetricCountersGrid(context, state.data, screenWidth, isSmall),
              const SizedBox(height: 14),

              // 2. Action Toolbar in Screen Body
              _buildActionToolbar(context, state, screenWidth),
              const SizedBox(height: 14),

              // 3. Candidate Star Evaluation Form Card
              _buildStarEvaluationForm(context, state, screenWidth),
              const SizedBox(height: 18),

              // 4. Ultra-professional Search Bar
              _buildSearchBar(context, screenWidth),
              const SizedBox(height: 14),

              // 5. Rating Filter Chips
              _buildFilterChips(context, state, screenWidth),
              const SizedBox(height: 16),

              // 6. Section Header
              _buildSectionHeader(
                title: 'Submitted Evaluations & Notes',
                count: state.filteredFeedbacks.length,
                screenWidth: screenWidth,
              ),
              const SizedBox(height: 10),

              // 7. Submitted Feedback Feed List
              _buildFeedbackList(state.filteredFeedbacks, screenWidth),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMetricCountersGrid(
    BuildContext context,
    MentorFeedbackData data,
    double screenWidth,
    bool isSmall,
  ) {
    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: LucideIcons.award,
                  iconColor: const Color(0xFF6366F1),
                  iconBg: const Color(0xFFECE6FE),
                  value: '${data.totalEvaluationsCount}',
                  label: 'Total Evaluations',
                  screenWidth: screenWidth,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: LucideIcons.star,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  value: '${data.averageTechRating} ★',
                  label: 'Avg Tech Rating',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: LucideIcons.messageSquare,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFECFDF5),
                  value: '${data.averageCommRating} ★',
                  label: 'Avg Comm Rating',
                  screenWidth: screenWidth,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: LucideIcons.users,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFECE6FE),
                  value: '${data.pendingCandidatesCount}',
                  label: 'Pending Review',
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
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required String label,
    required double screenWidth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.052, 17.0, 20.0),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 10.5, 12.0),
                    fontWeight: FontWeight.w600,
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

  Widget _buildActionToolbar(
    BuildContext context,
    FeedbackLoaded state,
    double screenWidth,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () => _showQuickModal(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.star, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Log Evaluation Form',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<MentorFeedbackBloc>().add(
                    const FetchFeedbackDataEvent(isRefresh: true),
                  );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border, width: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.refreshCw, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Sync Records',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStarEvaluationForm(
    BuildContext context,
    FeedbackLoaded state,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.edit3, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Candidate Star Evaluation Feedback',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Tab 9 Evaluation Console',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 1. Assigned Candidate Dropdown
          Text(
            'ASSIGNED CANDIDATE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: state.data.students.any((s) => s.name == state.selectedCandidate)
                    ? state.selectedCandidate
                    : (state.data.students.isNotEmpty ? state.data.students.first.name : null),
                items: state.data.students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student.name,
                    child: Text(
                      '${student.name} (${student.college})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.034, 12.5, 14.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<MentorFeedbackBloc>().add(SelectCandidateEvent(val));
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Technical Rating Stars
          Row(
            children: [
              Expanded(
                child: Text(
                  'TECHNICAL RATING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.selectedTechRating} / 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInteractiveStarRow(
            currentRating: state.selectedTechRating,
            onRatingChanged: (r) {
              context.read<MentorFeedbackBloc>().add(ChangeTechRatingEvent(r));
            },
          ),
          const SizedBox(height: 14),

          // 3. Communication Rating Stars
          Row(
            children: [
              Expanded(
                child: Text(
                  'COMMUNICATION RATING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.selectedCommRating} / 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInteractiveStarRow(
            currentRating: state.selectedCommRating,
            onRatingChanged: (r) {
              context.read<MentorFeedbackBloc>().add(ChangeCommRatingEvent(r));
            },
          ),
          const SizedBox(height: 14),

          // 4. Qualitative Commentary Text Field
          Text(
            'ASSESSMENT COMMENTARY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.034, 12.5, 14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Write structured evaluation notes and improvement guidance here...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border, width: 0.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      final comments = _commentController.text.trim();
                      context.read<MentorFeedbackBloc>().add(
                            SubmitFeedbackEvent(
                              studentName: state.selectedCandidate,
                              techRating: state.selectedTechRating,
                              commRating: state.selectedCommRating,
                              comments: comments.isNotEmpty
                                  ? comments
                                  : 'Evaluation notes logged for candidate session.',
                            ),
                          );
                      _commentController.clear();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E17EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                shadowColor: const Color(0xFF5E17EB).withValues(alpha: 0.3),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Submit Feedback',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStarRow({
    required int currentRating,
    required Function(int) onRatingChanged,
  }) {
    return Row(
      children: [1, 2, 3, 4, 5].map((star) {
        final isFilled = star <= currentRating;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onRatingChanged(star);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFilled
                        ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                        : AppColors.border,
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.star,
                  size: 18,
                  color: isFilled ? const Color(0xFF6366F1) : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          context.read<MentorFeedbackBloc>().add(SearchFeedbackHistoryEvent(val));
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: clampDouble(screenWidth * 0.036, 13.0, 14.5),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search evaluation history, candidates, notes...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    context.read<MentorFeedbackBloc>().add(const SearchFeedbackHistoryEvent(''));
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    FeedbackLoaded state,
    double screenWidth,
  ) {
    final filters = [
      {'id': 'all', 'label': 'All Evaluations'},
      {'id': 'top', 'label': 'Top Performers (5★)'},
      {'id': 'good', 'label': 'Good Fit (4★)'},
      {'id': 'needs_work', 'label': 'Needs Attention (<3★)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<MentorFeedbackBloc>().add(
                      FilterFeedbackHistoryEvent(f['id'] as String),
                    );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  f['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.032, 11.5, 12.5),
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required double screenWidth,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackList(List<CandidateFeedbackEntry> list, double screenWidth) {
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(LucideIcons.fileText, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              'No Feedback Logs Found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Submit an evaluation above to record assessment notes.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildSpaciousFeedbackCard(item, screenWidth);
      },
    );
  }

  /// Spacious Feedback Card with ZERO ellipsis truncation and responsive wrapping
  Widget _buildSpaciousFeedbackCard(CandidateFeedbackEntry item, double screenWidth) {
    final avatarColor = Color(int.tryParse(item.avatarBg) ?? 0xFF6366F1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + Name & College + Score badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.avatar,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.role} • ${item.college}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: Text(
                  '${item.overallScore}/100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Star Ratings Badges + Timestamp (Fluid Wrap to eliminate any overflow)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.star, size: 12, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          'Tech: ${item.techRating} / 5',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECE6FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.messageSquare, size: 12, color: Color(0xFF6366F1)),
                        const SizedBox(width: 4),
                        Text(
                          'Comm: ${item.commRating} / 5',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.clock, size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    item.timestamp,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Assessment Commentary without truncation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputFill.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.comments,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Modal bottom sheet for logging feedback
class _QuickFeedbackModal extends StatefulWidget {
  final List<MentorStudentModel> students;
  final String initialStudent;
  final int initialTech;
  final int initialComm;
  final Function(String name, int tech, int comm, String notes) onSubmit;

  const _QuickFeedbackModal({
    required this.students,
    required this.initialStudent,
    required this.initialTech,
    required this.initialComm,
    required this.onSubmit,
  });

  @override
  State<_QuickFeedbackModal> createState() => _QuickFeedbackModalState();
}

class _QuickFeedbackModalState extends State<_QuickFeedbackModal> {
  late String _student;
  late int _tech;
  late int _comm;
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _student = widget.initialStudent;
    _tech = widget.initialTech;
    _comm = widget.initialComm;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + (MediaQuery.paddingOf(context).bottom == 0 ? 20.0 : MediaQuery.paddingOf(context).bottom + 8.0),
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
            Text(
              'Log Candidate Star Evaluation',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Candidate Dropdown
            Text(
              'Candidate',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: widget.students.any((s) => s.name == _student)
                      ? _student
                      : (widget.students.isNotEmpty ? widget.students.first.name : null),
                  items: widget.students.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.name,
                      child: Text(
                        '${s.name} (${s.college})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _student = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tech Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Technical Rating',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$_tech / 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [1, 2, 3, 4, 5].map((s) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _tech = s),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: s <= _tech ? const Color(0xFFFEF3C7) : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.star,
                          size: 16,
                          color: s <= _tech ? const Color(0xFFD97706) : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Comm Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Communication Rating',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '$_comm / 5',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [1, 2, 3, 4, 5].map((s) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _comm = s),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: s <= _comm ? const Color(0xFFECFDF5) : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          LucideIcons.messageSquare,
                          size: 16,
                          color: s <= _comm ? const Color(0xFF059669) : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Commentary
            Text(
              'Assessment Commentary',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Write structured notes here...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final text = _commentCtrl.text.trim();
                  widget.onSubmit(
                    _student,
                    _tech,
                    _comm,
                    text.isNotEmpty ? text : 'Candidate evaluation recorded.',
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E17EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Submit Evaluation',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
