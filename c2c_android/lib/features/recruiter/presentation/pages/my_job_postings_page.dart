import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/my_job_posting_bloc.dart';
import '../../data/models/my_job_posting_model.dart';
import '../widgets/recruiter_side_nav.dart';

class MyJobPostingsPage extends StatelessWidget {
  final String? jobId;
  const MyJobPostingsPage({super.key, this.jobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => MyJobPostingBloc()..add(FetchMyPostings(jobIdParam: jobId)),
      child: _MyJobPostingsView(initialJobId: jobId),
    );
  }
}

class _MyJobPostingsView extends StatelessWidget {
  final String? initialJobId;
  const _MyJobPostingsView({this.initialJobId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = clampDouble(screenWidth * 0.045, 14.0, 20.0);
    final titleSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const RecruiterSideNav(highlightRoute: '/recruiter/my-postings'),
        appBar: _buildAppBar(context, titleSize),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<MyJobPostingBloc>().add(const RefreshMyPostings());
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: BlocConsumer<MyJobPostingBloc, MyJobPostingState>(
              listener: (ctx, state) {
                if (state is MyJobPostingError) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(state.message)),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              builder: (ctx, state) {
                if (state is MyJobPostingInitial || state is MyJobPostingLoading) {
                  return _ShimmerSkeleton(padding: hPad);
                }
                if (state is MyJobPostingError) {
                  return _ErrorView(message: state.message);
                }
                if (state is MyJobPostingEmpty) {
                  return _buildEmptyOrList(
                    context: ctx,
                    postings: const [],
                    filtered: const [],
                    activeTab: state.activeTab,
                    selectedJobId: state.selectedJobId,
                    selectedInfo: null,
                    hPad: hPad,
                    screenWidth: screenWidth,
                  );
                }
                if (state is MyJobPostingLoaded) {
                  final filtered = state.filteredPostings;
                  return _buildEmptyOrList(
                    context: ctx,
                    postings: state.postings,
                    filtered: filtered,
                    activeTab: state.activeTab,
                    selectedJobId: state.selectedJobId,
                    selectedInfo: state.selectedJobInfo,
                    hPad: hPad,
                    screenWidth: screenWidth,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double titleSize) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'My Job Postings',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          BlocBuilder<MyJobPostingBloc, MyJobPostingState>(
            builder: (context, state) {
              bool isMock = false;
              if (state is MyJobPostingLoaded) isMock = state.isMock;
              if (state is MyJobPostingEmpty) isMock = state.isMock;

              if (isMock) {
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
                      fontSize: 10,
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
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textSecondary, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/recruiter/dashboard');
            }
          },
          tooltip: 'Back',
        ),
      ],
    );
  }

  Widget _buildEmptyOrList({
    required BuildContext context,
    required List<JobPostingItem> postings,
    required List<JobPostingItem> filtered,
    required String activeTab,
    String? selectedJobId,
    JobPostingItem? selectedInfo,
    required double hPad,
    required double screenWidth,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(
        left: hPad,
        right: hPad,
        top: 14,
        bottom: bottomInset == 0 ? 28 : bottomInset + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single Job View Banner (1:1 with web)
          if (selectedJobId != null && selectedInfo != null) ...[
            _SingleJobBanner(
              job: selectedInfo,
              onClear: () => context.read<MyJobPostingBloc>().add(const ClearSelectedJobFilter()),
            ),
            const SizedBox(height: 16),
          ],

          // Page Header Row
          _PageHeader(
            screenWidth: screenWidth,
            onPostNew: () async {
              await context.push('/recruiter/post-job');
              if (context.mounted) context.read<MyJobPostingBloc>().add(const RefreshMyPostings());
            },
          ),
          const SizedBox(height: 16),

          // Filter Tabs Row (hide when single-job filtered per web)
          if (selectedJobId == null) ...[
            _FilterTabsRow(
              activeTab: activeTab,
              total: postings.length,
              activeCount: postings.where((p) => p.status == 'ACTIVE').length,
              draftCount: postings.where((p) => p.status == 'DRAFT').length,
              onTab: (tab) => context.read<MyJobPostingBloc>().add(ChangePostingTab(tab)),
            ),
            const SizedBox(height: 16),
          ],

          // Postings Grid / List or Empty
          if (filtered.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (_, i) => _JobPostingCard(
                job: filtered[i],
                onViewDetails: (job) => _showJobDetailSheet(context, job),
                onDelete: (id) => _confirmDelete(context, id),
                onPublish: (id) {
                  HapticFeedback.lightImpact();
                  context.read<MyJobPostingBloc>().add(PublishDraftRequested(id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🎉 Job vacancy published successfully!',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                onViewPipeline: () => context.push('/recruiter/shortlisted-candidates'),
              ),
            )
          else
            _EmptyStateView(
              isSingleNotFound: selectedJobId != null,
              onViewAll: () => context.read<MyJobPostingBloc>().add(const ClearSelectedJobFilter()),
              onCreate: () async {
                await context.push('/recruiter/post-job');
                if (context.mounted) context.read<MyJobPostingBloc>().add(const RefreshMyPostings());
              },
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, String id) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Delete Posting?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'This will permanently remove the job posting and its hiring pipeline.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              HapticFeedback.mediumImpact();
              ctx.read<MyJobPostingBloc>().add(DeletePostingRequested(id));
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(LucideIcons.trash2, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Job posting deleted successfully'),
                    ],
                  ),
                  backgroundColor: AppColors.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Delete Posting', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showJobDetailSheet(BuildContext ctx, JobPostingItem job) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobDetailSheet(
        job: job,
        onPublish: () {
          Navigator.pop(ctx);
          ctx.read<MyJobPostingBloc>().add(PublishDraftRequested(job.id));
        },
        onPipeline: () {
          Navigator.pop(ctx);
          ctx.push('/recruiter/shortlisted-candidates');
        },
      ),
    );
  }
}

// ================= SUB WIDGETS =================

class _SingleJobBanner extends StatelessWidget {
  final JobPostingItem job;
  final VoidCallback onClear;
  const _SingleJobBanner({required this.job, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.briefcase, size: 18, color: Color(0xFF5E17EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(6)),
                      child: const Text(
                        'SINGLE JOB VIEW',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED), letterSpacing: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: 'Viewing Job Posting: '),
                          TextSpan(text: job.title, style: const TextStyle(color: Color(0xFF5E17EB), fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onClear();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.arrowLeft, size: 13, color: Color(0xFF5E17EB)),
                    SizedBox(width: 4),
                    Text('Show All Job Postings', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final double screenWidth;
  final VoidCallback onPostNew;
  const _PageHeader({required this.screenWidth, required this.onPostNew});

  @override
  Widget build(BuildContext context) {
    final headerSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Job Postings & Performance',
                style: TextStyle(fontSize: headerSize, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
              ),
            ),
            const SizedBox(width: 8),
            _PostNewButton(onTap: onPostNew),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Track views, applications, and hiring pipeline metrics for all open positions.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
        ),
      ],
    );
  }
}

class _PostNewButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PostNewButton({required this.onTap});
  @override
  State<_PostNewButton> createState() => _PostNewButtonState();
}

class _PostNewButtonState extends State<_PostNewButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF5E17EB),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x335E17EB), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.plus, size: 14, color: Colors.white),
              SizedBox(width: 5),
              Text('Post a Job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterTabsRow extends StatelessWidget {
  final String activeTab;
  final int total;
  final int activeCount;
  final int draftCount;
  final ValueChanged<String> onTab;
  const _FilterTabsRow({
    required this.activeTab,
    required this.total,
    required this.activeCount,
    required this.draftCount,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'ALL', 'label': 'All Postings ($total)'},
      {'id': 'ACTIVE', 'label': 'Active ($activeCount)'},
      {'id': 'DRAFT', 'label': 'Drafts ($draftCount)'},
    ];

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: tabs.map((t) {
              final isActive = activeTab == t['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTab(t['id'] as String);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF5E17EB) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? const Color(0xFF5E17EB) : AppColors.border),
                    ),
                    child: Text(
                      t['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white : AppColors.textSecondary,
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
}

class _JobPostingCard extends StatefulWidget {
  final JobPostingItem job;
  final ValueChanged<JobPostingItem> onViewDetails;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onPublish;
  final VoidCallback onViewPipeline;
  const _JobPostingCard({
    required this.job,
    required this.onViewDetails,
    required this.onDelete,
    required this.onPublish,
    required this.onViewPipeline,
  });

  @override
  State<_JobPostingCard> createState() => _JobPostingCardState();
}

class _JobPostingCardState extends State<_JobPostingCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final j = widget.job;
    final isActive = j.status == 'ACTIVE';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top title + status + delete
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Text(
                              j.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                j.status,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: isActive ? const Color(0xFF047857) : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 3),
                                Text(j.location.isNotEmpty ? j.location : 'Remote', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                            const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                            Text(j.jobType, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                            if (j.createdAt.isNotEmpty) ...[
                              const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              Text('Posted ${j.createdAt}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onDelete(j.id);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),

              // Description
              if (j.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  j.description,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
              ],

              // Skills tags
              if (j.skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...j.skills.take(4).map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                          child: Text(s, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                        )),
                    if (j.skills.length > 4)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                        child: Text('+${j.skills.length - 4} more', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Salary + Applicants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.indianRupee, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(
                        j.salaryMin.isNotEmpty ? '${j.salaryMin} - ${j.salaryMax} ${j.salaryCurrency}' : 'Not specified',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.users, size: 12, color: Color(0xFF5E17EB)),
                        const SizedBox(width: 4),
                        Text(
                          '${j.applicantsCount} Applicants',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              // Card action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        widget.onViewDetails(j);
                      },
                      icon: const Icon(LucideIcons.eye, size: 14),
                      label: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isActive
                        ? ElevatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onViewPipeline();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E17EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('View Pipeline →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onPublish(j.id);
                            },
                            icon: const Icon(LucideIcons.checkCircle2, size: 14, color: Colors.white),
                            label: const Text('Publish Job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
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
}

class _EmptyStateView extends StatelessWidget {
  final bool isSingleNotFound;
  final VoidCallback onViewAll;
  final VoidCallback onCreate;
  const _EmptyStateView({required this.isSingleNotFound, required this.onViewAll, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.folderOpen, size: 24, color: Color(0xFF5E17EB)),
          ),
          const SizedBox(height: 14),
          Text(
            isSingleNotFound ? 'Selected job posting not found' : 'No job postings found',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isSingleNotFound ? 'This job posting may have been deleted or removed.' : 'You have not published any job vacancies yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (isSingleNotFound) {
                onViewAll();
              } else {
                onCreate();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E17EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            ),
            child: Text(
              isSingleNotFound ? 'View All Job Postings' : '+ Create First Job Posting',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobDetailSheet extends StatelessWidget {
  final JobPostingItem job;
  final VoidCallback onPublish;
  final VoidCallback onPipeline;
  const _JobDetailSheet({required this.job, required this.onPublish, required this.onPipeline});

  @override
  Widget build(BuildContext context) {
    final isActive = job.status == 'ACTIVE';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(left: 18, right: 18, top: 12, bottom: bottomInset == 0 ? 18 : bottomInset + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                          ),
                          child: Text(
                            job.status,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: isActive ? const Color(0xFF047857) : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(job.location.isNotEmpty ? job.location : 'Remote', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                            const Text('•', style: TextStyle(color: AppColors.textMuted)),
                            Text(job.jobType, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            if (job.createdAt.isNotEmpty) ...[
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              Text('Posted ${job.createdAt}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.x, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              // Description
              const Text('JOB DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0.7)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Text(
                  job.description.isNotEmpty ? job.description : 'No description provided.',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.45),
                ),
              ),
              const SizedBox(height: 14),

              // Salary + Applications
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE9D5FF))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SALARY RANGE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(LucideIcons.indianRupee, size: 13, color: AppColors.textPrimary),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  job.salaryMin.isNotEmpty ? '${job.salaryMin} - ${job.salaryMax} ${job.salaryCurrency}' : 'Not specified',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFDBFE))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('APPLICATIONS SUMMARY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                          const SizedBox(height: 4),
                          Text(
                            '${job.applicantsCount} Candidates Applied',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Skills
              if (job.skills.isNotEmpty) ...[
                const Text('REQUIRED SKILLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0.7)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: job.skills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                            child: Text(s, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],

              // Info row extras
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniStat(icon: LucideIcons.users, label: 'Applicants', value: '${job.applicantsCount}'),
                    Container(width: 1, height: 28, color: AppColors.border),
                    _MiniStat(icon: LucideIcons.eye, label: 'In Review', value: '${job.inReviewCount}'),
                    Container(width: 1, height: 28, color: AppColors.border),
                    _MiniStat(icon: LucideIcons.userCheck, label: 'Hired', value: '${job.hiredCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Close Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: isActive
                        ? ElevatedButton(
                            onPressed: onPipeline,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E17EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('View Pipeline →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                          )
                        : ElevatedButton(
                            onPressed: onPublish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Publish This Job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
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
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniStat({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ShimmerSkeleton extends StatelessWidget {
  final double padding;
  const _ShimmerSkeleton({required this.padding});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
        child: Column(
          children: [
            Container(height: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 12),
            Container(height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 14),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 36, color: AppColors.error),
            const SizedBox(height: 10),
            const Text('Failed to load postings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.read<MyJobPostingBloc>().add(const FetchMyPostings()),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E17EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
