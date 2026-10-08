import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';
import '../../bloc/recruiter_dashboard_bloc.dart';
import '../../data/models/recruiter_dashboard_model.dart';
import '../widgets/recruiter_side_nav.dart';

class RecruiterDashboardPage extends StatelessWidget {
  const RecruiterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecruiterDashboardBloc()..add(const FetchRecruiterDashboard()),
      child: const _RecruiterDashboardView(),
    );
  }
}

class _RecruiterDashboardView extends StatelessWidget {
  const _RecruiterDashboardView();

  void _showActionFeedback(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 14.0, 20.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const RecruiterSideNav(highlightRoute: '/recruiter/dashboard'),
        appBar: _buildAppBar(context, screenWidth),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<RecruiterDashboardBloc>().add(const RefreshRecruiterDashboard());
            },
            child: BlocConsumer<RecruiterDashboardBloc, RecruiterDashboardState>(
              listener: (context, state) {
                if (state is RecruiterDashboardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is RecruiterDashboardLoading || state is RecruiterDashboardInitial) {
                  return _buildLoadingSkeleton(horizontalPadding);
                }

                if (state is RecruiterDashboardError) {
                  return _buildErrorView(context, state.message);
                }

                if (state is RecruiterDashboardLoaded) {
                  return _buildLoadedContent(context, state, screenWidth, horizontalPadding);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    final titleFontSize = clampDouble(screenWidth * 0.046, 16.0, 19.0);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            HapticFeedback.selectionClick();
            Scaffold.of(ctx).openDrawer();
          },
          tooltip: 'Open navigation menu',
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.briefcase,
              color: Color(0xFFEA580C),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    BlocBuilder<RecruiterDashboardBloc, RecruiterDashboardState>(
                      builder: (context, state) {
                        if (state is RecruiterDashboardLoaded && state.data.isMock) {
                          return Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '*',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final name = state is Authenticated ? state.userName : 'Corporate Recruiter';
                    return Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: const EdgeInsets.all(6),
          icon: const Icon(LucideIcons.bell, size: 19, color: AppColors.textSecondary),
          onPressed: () => _showActionFeedback(context, 'Hiring notifications active'),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: const EdgeInsets.all(6),
          icon: const Icon(LucideIcons.logOut, size: 19, color: AppColors.error),
          onPressed: () {
            context.read<AuthBloc>().add(LogoutRequested());
            context.go('/auth/role-select');
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    RecruiterDashboardLoaded state,
    double screenWidth,
    double horizontalPadding,
  ) {
    final data = state.data;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 14.0,
        bottom: bottomInset > 0 ? bottomInset + 20.0 : 28.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Action Toolbar in Body (Post a New Job + Sync Metrics)
          _buildActionToolbar(context, screenWidth),
          const SizedBox(height: 16),

          // 2. Hero Banner: AI-Ranked Intelligence & Welcome Card (1:1 with Web RecruiterDashboard.tsx)
          _buildHeroIntelligenceBanner(context, data, screenWidth),
          const SizedBox(height: 18),

          // 3. Stats 2x2 Responsive Wrap (Active Jobs, Total Applications, Shortlisted, Interviews)
          _buildStatsGrid(context, data.stats, screenWidth),
          const SizedBox(height: 20),

          // 4. Job Filter Tabs
          _buildJobFilterChips(context, state.selectedFilter),
          const SizedBox(height: 14),

          // 5. Active Job Postings Section
          _buildActiveJobsSection(context, state.filteredJobs),
          const SizedBox(height: 20),

          // 6. Candidate Pipeline Section (1:1 with Table on Web)
          _buildCandidatePipelineSection(context, data.recentApplications),
          const SizedBox(height: 20),

          // 7. Top Candidate Matches Section
          _buildTopMatchesSection(context, data.topMatches),
          const SizedBox(height: 20),

          // 8. Interview Queue & Talent Pool Health Section
          _buildInterviewQueueSection(context, data.interviewQueue),
          const SizedBox(height: 20),

          // 9. Getting Started / Corporate Verification Status Card
          _buildGettingStartedCard(context, data.verificationStatus),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- 1. Action Toolbar in Body ---
  Widget _buildActionToolbar(BuildContext context, double screenWidth) {
    final btnFontSize = clampDouble(screenWidth * 0.033, 12.0, 13.5);

    return Row(
      children: [
        Expanded(
          child: BouncyButton(
            onPressed: () async {
              await context.push('/recruiter/post-job');
              if (context.mounted) {
                context.read<RecruiterDashboardBloc>().add(const RefreshRecruiterDashboard());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E17EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E17EB).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plusCircle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Post a New Job',
                      style: TextStyle(
                        fontSize: btnFontSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        BouncyButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            context.read<RecruiterDashboardBloc>().add(const RefreshRecruiterDashboard());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.refreshCw, color: AppColors.textPrimary, size: 15),
                const SizedBox(width: 6),
                Text(
                  'Sync Metrics',
                  style: TextStyle(
                    fontSize: btnFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Hero Intelligence & Welcome Banner ---
  Widget _buildHeroIntelligenceBanner(
    BuildContext context,
    RecruiterDashboardData data,
    double screenWidth,
  ) {
    final titleFontSize = clampDouble(screenWidth * 0.048, 17.0, 21.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sparkles, color: Color(0xFF93C5FD), size: 13),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'AI-ranked candidate intelligence',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDBEAFE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.activeJobs.isNotEmpty ? data.activeJobs.first.title : 'Corporate Talent Drive',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review high-fit candidates, schedule interviews, and keep your hiring pipeline synced in real time.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),

          // 3-Metric Counter Chips
          Row(
            children: [
              _buildHeroChip('${data.stats.matchedCandidates} verified'),
              const SizedBox(width: 8),
              _buildHeroChip('184 ready'),
              const SizedBox(width: 8),
              _buildHeroChip('${data.stats.interviews} today'),
            ],
          ),
          const SizedBox(height: 16),

          // Pipeline Progress Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                      child: Text(
                        'Hiring Pipeline Health',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    Text(
                      '${(data.pipelineProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: data.pipelineProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.cohortName,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. Stats 2x2 Responsive Wrap (No fixed aspect ratio vertical clipping) ---
  Widget _buildStatsGrid(BuildContext context, RecruiterStats stats, double screenWidth) {
    final statCards = [
      {
        'label': 'Active Jobs',
        'value': stats.activeJobs.toString(),
        'trend': stats.activeJobs > 0 ? '+${stats.activeJobs}' : '0',
        'icon': LucideIcons.briefcase,
        'color': const Color(0xFF5E17EB),
        'bg': const Color(0xFFECE6FE),
      },
      {
        'label': 'Total Applications',
        'value': stats.totalApplications.toString(),
        'trend': stats.totalApplications > 0 ? '+${stats.totalApplications}' : '0',
        'icon': LucideIcons.barChart3,
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
      },
      {
        'label': 'Shortlisted',
        'value': stats.shortlisted.toString(),
        'trend': stats.shortlisted > 0 ? '+${stats.shortlisted}' : '0',
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'label': 'Interviews',
        'value': stats.interviews.toString(),
        'trend': stats.interviews > 0 ? '+${stats.interviews}' : '0',
        'icon': LucideIcons.calendarDays,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFFFBEB),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: statCards.map((card) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: card['bg'] as Color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(card['icon'] as IconData, size: 16, color: card['color'] as Color),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            card['trend'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card['value'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- 4. Job Filter Chips ---
  Widget _buildJobFilterChips(BuildContext context, String selectedFilter) {
    final filters = [
      {'key': 'ALL', 'label': 'All Postings'},
      {'key': 'ACTIVE', 'label': 'Active'},
      {'key': 'FULLTIME', 'label': 'Full-time'},
      {'key': 'INTERNSHIP', 'label': 'Internship'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<RecruiterDashboardBloc>().add(FilterJobsChanged(f['key']!));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5E17EB) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF5E17EB) : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF5E17EB).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 12,
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

  // --- 5. Active Jobs Section ---
  Widget _buildActiveJobsSection(BuildContext context, List<RecruiterJobItem> activeJobs) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Active Jobs',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/recruiter/my-postings'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Manage Jobs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5E17EB),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF5E17EB)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (activeJobs.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeJobs.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final job = activeJobs[i];
                return Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textSecondary),
                                    Text(
                                      job.location,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                    Text(
                                      job.jobType,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              job.status,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              job.salary,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BouncyButton(
                            onPressed: () => context.push('/recruiter/my-postings?jobId=${job.id}'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE6FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'View Posting',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF5E17EB),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECE6FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.briefcase, color: Color(0xFF5E17EB), size: 22),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No active job postings',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create your first listing to start accepting candidates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    BouncyButton(
                      onPressed: () => context.push('/recruiter/post-job'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E17EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+ Post a New Job',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 6. Candidate Pipeline Section (1:1 with Web Candidate Pipeline Table) ---
  Widget _buildCandidatePipelineSection(BuildContext context, List<RecruiterCandidateItem> candidates) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Candidate Pipeline',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sorted by verified match score & readiness',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showActionFeedback(context, 'Exporting candidate pipeline summary'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.filter, size: 12, color: AppColors.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (candidates.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidates.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, i) {
                final candidate = candidates[i];
                final initials = candidate.name.isNotEmpty
                    ? candidate.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join('')
                    : 'CD';

                return Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              candidate.roleApplied,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              candidate.college,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: Text(
                                    '${candidate.matchScore}% Match',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF047857),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    candidate.stage.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncyButton(
                        onPressed: () => _showReviewCandidateModal(context, candidate),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.inbox, color: Color(0xFF2563EB), size: 22),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No applications received yet',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'When candidates apply, their AI match scores will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 7. Top Candidate Matches Section ---
  Widget _buildTopMatchesSection(BuildContext context, List<RecruiterCandidateItem> topMatches) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Candidate Matches',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(LucideIcons.sparkles, size: 15, color: Color(0xFF059669)),
            ],
          ),
          const SizedBox(height: 12),
          if (topMatches.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topMatches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final match = topMatches[i];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.userCheck, size: 14, color: Color(0xFF059669)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.name,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${match.roleApplied} • ${match.college}',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${match.matchScore}% Fit',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Top candidate matches will appear once applications arrive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 8. Interview Queue & Talent Pool Health ---
  Widget _buildInterviewQueueSection(BuildContext context, List<InterviewQueueItem> queue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interview Queue',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(LucideIcons.calendarDays, size: 15, color: Color(0xFF2563EB)),
            ],
          ),
          const SizedBox(height: 12),
          ...queue.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(LucideIcons.clock, size: 14, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item.candidate} (${item.role})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
          // Talent Pool Health Sub-Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.graduationCap, size: 16, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talent Pool Health',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '184 candidates ready for recruiter review',
                        style: TextStyle(fontSize: 10.5, color: Color(0xFF3B82F6)),
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

  // --- 9. Getting Started / Corporate Verification Status Card ---
  Widget _buildGettingStartedCard(BuildContext context, String verificationStatus) {
    final isVerified = verificationStatus == 'VERIFIED';
    final isPending = verificationStatus == 'PENDING';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Getting Started',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVerified
                ? 'Your corporate profile is verified by Admin. You can publish unlimited job openings and manage talent pipelines.'
                : 'Set up your company profile and create job listings to unlock AI-verified talent matches.',
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 14),
          BouncyButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isPending || isVerified) {
                context.push('/recruiter/admin-review');
              } else {
                context.push('/recruiter/settings');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isVerified
                    ? const Color(0xFF059669).withValues(alpha: 0.25)
                    : isPending
                        ? const Color(0xFFD97706).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isVerified
                      ? const Color(0xFF34D399)
                      : isPending
                          ? const Color(0xFFFBBF24)
                          : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isVerified ? LucideIcons.checkCircle : LucideIcons.clock,
                          size: 14,
                          color: isVerified ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isVerified
                                ? 'Company Profile Verified'
                                : isPending
                                    ? 'Profile Pending Admin Review'
                                    : 'Complete Company Profile',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isVerified
                                  ? const Color(0xFF34D399)
                                  : isPending
                                      ? const Color(0xFFFBBF24)
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronRight, size: 14, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Candidate Stage Change Modal ---
  void _showReviewCandidateModal(BuildContext context, RecruiterCandidateItem candidate) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetCtx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${candidate.roleApplied} • ${candidate.college}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(bottomSheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Update Candidate Pipeline Stage:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStageOption(context, bottomSheetCtx, candidate.id, 'shortlisted', 'Shortlist', const Color(0xFF059669)),
                  _buildStageOption(context, bottomSheetCtx, candidate.id, 'interview', 'Schedule Interview', const Color(0xFF2563EB)),
                  _buildStageOption(context, bottomSheetCtx, candidate.id, 'selected', 'Select / Offer', const Color(0xFF7C3AED)),
                  _buildStageOption(context, bottomSheetCtx, candidate.id, 'rejected', 'Reject', AppColors.error),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStageOption(
    BuildContext context,
    BuildContext modalCtx,
    String candidateId,
    String stage,
    String label,
    Color color,
  ) {
    return BouncyButton(
      onPressed: () {
        context.read<RecruiterDashboardBloc>().add(
              UpdateCandidateStageRequested(candidateId: candidateId, newStage: stage),
            );
        Navigator.pop(modalCtx);
        _showActionFeedback(context, 'Candidate moved to ${stage.toUpperCase()}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }

  // --- Shimmer Skeleton Loader ---
  Widget _buildLoadingSkeleton(double horizontalPadding) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
            children: List.generate(
              4,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 36, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Failed to load recruiter dashboard',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            BouncyButton(
              onPressed: () => context.read<RecruiterDashboardBloc>().add(const FetchRecruiterDashboard()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5E17EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
