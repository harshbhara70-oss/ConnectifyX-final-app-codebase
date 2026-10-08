import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/applications_reports_bloc.dart';
import '../../data/models/candidate_application_model.dart';
import '../widgets/recruiter_side_nav.dart';

class ApplicationsReportsPage extends StatelessWidget {
  const ApplicationsReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ApplicationsReportsBloc()..add(const FetchApplicationsReports()),
      child: const _ApplicationsReportsView(),
    );
  }
}

class _ApplicationsReportsView extends StatelessWidget {
  const _ApplicationsReportsView();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = clampDouble(screenWidth * 0.045, 14.0, 20.0);
    final titleSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const RecruiterSideNav(highlightRoute: '/recruiter/applications'),
        appBar: _buildAppBar(context, titleSize),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<ApplicationsReportsBloc>().add(const RefreshApplicationsReports());
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: BlocConsumer<ApplicationsReportsBloc, ApplicationsReportsState>(
              listener: (ctx, state) {
                if (state is ApplicationsReportsError) {
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
                if (state is ApplicationsReportsInitial || state is ApplicationsReportsLoading) {
                  return _ShimmerSkeleton(padding: hPad);
                }
                if (state is ApplicationsReportsError) {
                  return _ErrorView(message: state.message);
                }
                if (state is ApplicationsReportsEmpty) {
                  return _buildContent(
                    context: ctx,
                    candidates: const [],
                    filtered: const [],
                    selectedFilter: state.selectedFilter,
                    searchQuery: '',
                    hPad: hPad,
                    screenWidth: screenWidth,
                  );
                }
                if (state is ApplicationsReportsLoaded) {
                  return _buildContent(
                    context: ctx,
                    candidates: state.candidates,
                    filtered: state.filteredCandidates,
                    selectedFilter: state.selectedFilter,
                    searchQuery: state.searchQuery,
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
              'Applications & Reports',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          BlocBuilder<ApplicationsReportsBloc, ApplicationsReportsState>(
            builder: (context, state) {
              bool isMock = false;
              if (state is ApplicationsReportsLoaded) isMock = state.isMock;
              if (state is ApplicationsReportsEmpty) isMock = state.isMock;

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

  Widget _buildContent({
    required BuildContext context,
    required List<CandidateAppItem> candidates,
    required List<CandidateAppItem> filtered,
    required String selectedFilter,
    required String searchQuery,
    required double hPad,
    required double screenWidth,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        left: hPad,
        right: hPad,
        top: 14,
        bottom: bottomInset == 0 ? 28 : bottomInset + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (1:1 with web ApplicationsReports.tsx)
          _PageHeader(
            screenWidth: screenWidth,
            onViewShortlisted: () => context.push('/recruiter/shortlisted-candidates'),
          ),
          const SizedBox(height: 16),

          // Search Field
          _SearchField(
            initialQuery: searchQuery,
            onChanged: (q) => context.read<ApplicationsReportsBloc>().add(SearchApplicationsQueryChanged(q)),
          ),
          const SizedBox(height: 14),

          // Filter Pills Row
          _FilterTabsRow(
            selectedFilter: selectedFilter,
            total: candidates.length,
            eligibleCount: candidates.where((c) => c.stage == 'eligible').length,
            shortlistedCount: candidates.where((c) => c.stage == 'shortlisted').length,
            contactedCount: candidates.where((c) => c.stage == 'contacted').length,
            interviewCount: candidates.where((c) => c.stage == 'interview').length,
            offerCount: candidates.where((c) => c.stage == 'offer').length,
            onFilter: (f) => context.read<ApplicationsReportsBloc>().add(ChangeApplicationsFilter(f)),
          ),
          const SizedBox(height: 16),

          // Candidate List or Empty
          if (filtered.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final app = filtered[i];
                return _CandidateAppCard(
                  app: app,
                  onShortlist: () {
                    HapticFeedback.lightImpact();
                    context.read<ApplicationsReportsBloc>().add(ShortlistCandidateAction(app.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '⭐ ${app.name} has been shortlisted!',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
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
                  onTap: () => _showCandidateDossierSheet(context, app),
                );
              },
            )
          else
            const _EmptyStateView(),
        ],
      ),
    );
  }

  void _showCandidateDossierSheet(BuildContext ctx, CandidateAppItem app) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CandidateDossierSheet(
        app: app,
        onShortlist: () {
          Navigator.pop(ctx);
          ctx.read<ApplicationsReportsBloc>().add(ShortlistCandidateAction(app.id));
        },
      ),
    );
  }
}

// ================= SUB WIDGETS =================

class _PageHeader extends StatelessWidget {
  final double screenWidth;
  final VoidCallback onViewShortlisted;
  const _PageHeader({required this.screenWidth, required this.onViewShortlisted});

  @override
  Widget build(BuildContext context) {
    final headerSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Applications & Candidate Reports',
          style: TextStyle(
            fontSize: headerSize,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Filtering candidate responses across all active and past job postings.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onViewShortlisted();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.userCheck, size: 15, color: Color(0xFF5E17EB)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'View Shortlisted Candidates Pipeline →',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.initialQuery, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search candidate name, role, or college...',
          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textSecondary),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 15, color: AppColors.textMuted),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _FilterTabsRow extends StatelessWidget {
  final String selectedFilter;
  final int total;
  final int eligibleCount;
  final int shortlistedCount;
  final int contactedCount;
  final int interviewCount;
  final int offerCount;
  final ValueChanged<String> onFilter;

  const _FilterTabsRow({
    required this.selectedFilter,
    required this.total,
    required this.eligibleCount,
    required this.shortlistedCount,
    required this.contactedCount,
    required this.interviewCount,
    required this.offerCount,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'id': 'ALL', 'label': 'All Applications ($total)'},
      {'id': 'ELIGIBLE', 'label': 'Eligible / Applied ($eligibleCount)'},
      {'id': 'SHORTLISTED', 'label': 'Shortlisted ($shortlistedCount)'},
      {'id': 'CONTACTED', 'label': 'Contacted ($contactedCount)'},
      {'id': 'INTERVIEW', 'label': 'Interview ($interviewCount)'},
      {'id': 'OFFER', 'label': 'Offer Extended ($offerCount)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isActive = selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onFilter(f['id'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5E17EB) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? const Color(0xFF5E17EB) : AppColors.border),
                ),
                child: Text(
                  f['label'] as String,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CandidateAppCard extends StatelessWidget {
  final CandidateAppItem app;
  final VoidCallback onShortlist;
  final VoidCallback onTap;

  const _CandidateAppCard({
    required this.app,
    required this.onShortlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color stageBg;
    Color stageText;
    Color stageBorder;

    switch (app.stage) {
      case 'shortlisted':
        stageBg = const Color(0xFFEEF2FF);
        stageText = const Color(0xFF4338CA);
        stageBorder = const Color(0xFFC7D2FE);
        break;
      case 'contacted':
        stageBg = const Color(0xFFEFF6FF);
        stageText = const Color(0xFF1D4ED8);
        stageBorder = const Color(0xFFBFDBFE);
        break;
      case 'interview':
        stageBg = const Color(0xFFFFFBEB);
        stageText = const Color(0xFFB45309);
        stageBorder = const Color(0xFFFDE68A);
        break;
      case 'offer':
        stageBg = const Color(0xFFECFDF5);
        stageText = const Color(0xFF047857);
        stageBorder = const Color(0xFFA7F3D0);
        break;
      default: // eligible
        stageBg = const Color(0xFFFAF5FF);
        stageText = const Color(0xFF7E22CE);
        stageBorder = const Color(0xFFE9D5FF);
        break;
    }

    final isEligible = app.stage == 'eligible';
    final isShortlisted = app.stage == 'shortlisted';

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Candidate Name + Source tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      if (app.source.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          app.source,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: Text(
                    '${app.score}% Match',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF5E17EB)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Job Role Badge + Stage Badge
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.briefcase, size: 12, color: Color(0xFF5E17EB)),
                      const SizedBox(width: 4),
                      Text(
                        app.jobTitle ?? app.role,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stageBorder),
                  ),
                  child: Text(
                    app.stage == 'eligible' ? 'ELIGIBLE' : app.stage.toUpperCase(),
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: stageText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 3: College & Applied Time
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.graduationCap, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(app.college, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
                const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                Text('Applied ${app.appliedDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // Row 4: Action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(LucideIcons.eye, size: 13, color: AppColors.textSecondary),
                  label: const Text('View Dossier', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
                if (isEligible)
                  ElevatedButton.icon(
                    onPressed: onShortlist,
                    icon: const Icon(LucideIcons.star, size: 13, color: Colors.white),
                    label: const Text('Shortlist Candidate', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E17EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  )
                else if (isShortlisted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.checkCircle2, size: 13, color: Color(0xFF047857)),
                        SizedBox(width: 4),
                        Text('Shortlisted', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.checkCircle2, size: 13, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 4),
                        Text('In Hiring Pipeline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateDossierSheet extends StatelessWidget {
  final CandidateAppItem app;
  final VoidCallback onShortlist;
  const _CandidateDossierSheet({required this.app, required this.onShortlist});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF5E17EB), Color(0xFF7C3AED)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      app.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(app.role, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF5E17EB))),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(LucideIcons.graduationCap, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${app.college} • ${app.branch}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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

              // Match & Score Intelligence
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI SKILL MATCH', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                          const SizedBox(height: 4),
                          Text('${app.score}% Verified Match', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT STAGE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                          const SizedBox(height: 4),
                          Text(app.stage.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Application info
              const Text('APPLICATION DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0.7)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: [
                    _InfoRow(label: 'Target Job Vacancy', value: app.jobTitle ?? app.role),
                    const Divider(height: 16, color: AppColors.border),
                    _InfoRow(label: 'Application Source', value: app.source),
                    const Divider(height: 16, color: AppColors.border),
                    _InfoRow(label: 'Submission Timestamp', value: app.appliedDate),
                    const Divider(height: 16, color: AppColors.border),
                    _InfoRow(label: 'Candidate Email', value: app.email.isNotEmpty ? app.email : 'candidate@campus.edu'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Bottom Actions
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
                      child: const Text('Close', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ),
                  ),
                  if (app.stage == 'eligible') ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onShortlist,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E17EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Shortlist Candidate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

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
            child: const Icon(LucideIcons.inbox, size: 24, color: Color(0xFF5E17EB)),
          ),
          const SizedBox(height: 14),
          const Text('No Applications Found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'No candidate applications match your current filters or search query.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
          ),
        ],
      ),
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
            Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 12),
            Container(height: 38, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 14),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18))),
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
            const Text('Failed to load applications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.read<ApplicationsReportsBloc>().add(const FetchApplicationsReports()),
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
