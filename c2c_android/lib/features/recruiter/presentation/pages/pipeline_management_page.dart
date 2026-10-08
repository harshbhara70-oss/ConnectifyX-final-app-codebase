import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/pipeline_bloc.dart';
import '../../data/models/candidate_pipeline_model.dart';
import '../widgets/recruiter_side_nav.dart';

class PipelineManagementPage extends StatelessWidget {
  const PipelineManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PipelineBloc()..add(const FetchPipeline()),
      child: const _PipelineManagementView(),
    );
  }
}

class _PipelineManagementView extends StatelessWidget {
  const _PipelineManagementView();

  static const List<Map<String, dynamic>> stages = [
    {'id': 'shortlisted', 'title': 'Shortlisted', 'color': Color(0xFF7C3AED), 'bgColor': Color(0xFFFAF5FF), 'borderColor': Color(0xFFE9D5FF)},
    {'id': 'contacted', 'title': 'Contacted', 'color': Color(0xFF2563EB), 'bgColor': Color(0xFFEFF6FF), 'borderColor': Color(0xFFBFDBFE)},
    {'id': 'interview', 'title': 'Interview Scheduled', 'color': Color(0xFFD97706), 'bgColor': Color(0xFFFFFBEB), 'borderColor': Color(0xFFFDE68A)},
    {'id': 'offer', 'title': 'Offer Extended', 'color': Color(0xFF059669), 'bgColor': Color(0xFFECFDF5), 'borderColor': Color(0xFFA7F3D0)},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = clampDouble(screenWidth * 0.045, 14.0, 20.0);
    final titleSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const RecruiterSideNav(highlightRoute: '/recruiter/shortlisted-candidates'),
        appBar: _buildAppBar(context, titleSize),
        body: SafeArea(
          bottom: true,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<PipelineBloc>().add(const RefreshPipeline());
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: BlocConsumer<PipelineBloc, PipelineState>(
              listener: (ctx, state) {
                if (state is PipelineError) {
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
                if (state is PipelineInitial || state is PipelineLoading) {
                  return _ShimmerSkeleton(padding: hPad);
                }
                if (state is PipelineError) {
                  return _ErrorView(message: state.message);
                }
                if (state is PipelineEmpty) {
                  return _buildContent(
                    context: ctx,
                    candidates: const [],
                    selectedStageTab: state.selectedStageTab,
                    hPad: hPad,
                    screenWidth: screenWidth,
                  );
                }
                if (state is PipelineLoaded) {
                  return _buildContent(
                    context: ctx,
                    candidates: state.candidates,
                    selectedStageTab: state.selectedStageTab,
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
              'Shortlisted Candidates',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          BlocBuilder<PipelineBloc, PipelineState>(
            builder: (context, state) {
              bool isMock = false;
              if (state is PipelineLoaded) isMock = state.isMock;
              if (state is PipelineEmpty) isMock = state.isMock;

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
    required List<CandidatePipelineItem> candidates,
    required String selectedStageTab,
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
          // Header Row
          _PageHeader(
            screenWidth: screenWidth,
            onAddCandidate: () => _showAddCandidateModal(context, defaultStage: 'shortlisted'),
          ),
          const SizedBox(height: 16),

          // Stage Selector Pills (All vs Specific Stage)
          _StageFilterTabs(
            selectedStageTab: selectedStageTab,
            candidates: candidates,
            onSelectStage: (stageId) => context.read<PipelineBloc>().add(SelectPipelineStageTab(stageId)),
          ),
          const SizedBox(height: 16),

          // Kanban Columns / List
          if (selectedStageTab == 'ALL') ...[
            // Render all 4 columns vertically for smooth mobile reading
            ...stages.map((stg) {
              final stageId = stg['id'] as String;
              final stageTitle = stg['title'] as String;
              final stageColor = stg['color'] as Color;
              final stageBg = stg['bgColor'] as Color;
              final stageBorder = stg['borderColor'] as Color;
              final stageCandidates = candidates.where((c) => c.stage.toLowerCase() == stageId.toLowerCase()).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: _KanbanStageColumn(
                  stageId: stageId,
                  stageTitle: stageTitle,
                  stageColor: stageColor,
                  stageBg: stageBg,
                  stageBorder: stageBorder,
                  candidates: stageCandidates,
                  onAdvance: (c) => _advanceCandidate(context, c),
                  onRollback: (c) => _rollbackCandidate(context, c),
                  onRemove: (id) => _confirmRemove(context, id),
                  onAdd: () => _showAddCandidateModal(context, defaultStage: stageId),
                ),
              );
            }),
          ] else ...[
            // Render the single selected stage
            () {
              final stg = stages.firstWhere((s) => s['id'] == selectedStageTab, orElse: () => stages.first);
              final stageId = stg['id'] as String;
              final stageTitle = stg['title'] as String;
              final stageColor = stg['color'] as Color;
              final stageBg = stg['bgColor'] as Color;
              final stageBorder = stg['borderColor'] as Color;
              final stageCandidates = candidates.where((c) => c.stage.toLowerCase() == stageId.toLowerCase()).toList();

              return _KanbanStageColumn(
                stageId: stageId,
                stageTitle: stageTitle,
                stageColor: stageColor,
                stageBg: stageBg,
                stageBorder: stageBorder,
                candidates: stageCandidates,
                onAdvance: (c) => _advanceCandidate(context, c),
                onRollback: (c) => _rollbackCandidate(context, c),
                onRemove: (id) => _confirmRemove(context, id),
                onAdd: () => _showAddCandidateModal(context, defaultStage: stageId),
              );
            }(),
          ],
        ],
      ),
    );
  }

  void _advanceCandidate(BuildContext context, CandidatePipelineItem candidate) {
    HapticFeedback.lightImpact();
    context.read<PipelineBloc>().add(AdvanceCandidateAction(candidateId: candidate.id, currentStage: candidate.stage));

    String notifMsg = 'Candidate moved forward in pipeline';
    if (candidate.stage == 'shortlisted') {
      notifMsg = '📞 ${candidate.name} moved to Contacted stage for "${candidate.role}".';
    } else if (candidate.stage == 'contacted') {
      notifMsg = '📅 Interview scheduled for ${candidate.name} (${candidate.role}).';
    } else if (candidate.stage == 'interview') {
      notifMsg = '🎉 Job offer extended to ${candidate.name} for "${candidate.role}"!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(notifMsg, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _rollbackCandidate(BuildContext context, CandidatePipelineItem candidate) {
    HapticFeedback.mediumImpact();
    context.read<PipelineBloc>().add(RollbackCandidateAction(candidateId: candidate.id, currentStage: candidate.stage));

    String notifMsg = 'Candidate stage rolled back';
    if (candidate.stage == 'offer') {
      notifMsg = '↩️ ${candidate.name} rolled back to Interview Scheduled.';
    } else if (candidate.stage == 'interview') {
      notifMsg = '↩️ ${candidate.name} rolled back to Contacted stage.';
    } else if (candidate.stage == 'contacted') {
      notifMsg = '↩️ ${candidate.name} rolled back to Shortlisted stage.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.rotateCcw, color: Color(0xFFF59E0B), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(notifMsg, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5))),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmRemove(BuildContext ctx, String id) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Remove Candidate?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'This will remove the candidate from this stage of the recruitment pipeline.',
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
              ctx.read<PipelineBloc>().add(RemoveCandidateAction(id));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Candidate removed from pipeline'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCandidateModal(BuildContext ctx, {required String defaultStage}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCandidateSheet(
        defaultStage: defaultStage,
        onAdd: (name, role, stage, source, score) {
          ctx.read<PipelineBloc>().add(AddCandidateAction(
                name: name,
                role: role,
                stage: stage,
                source: source,
                score: score,
              ));
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('⭐ $name ($source) added to pipeline!', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ),
                ],
              ),
              backgroundColor: AppColors.surface,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }
}

// ================= SUB WIDGETS =================

class _PageHeader extends StatelessWidget {
  final double screenWidth;
  final VoidCallback onAddCandidate;
  const _PageHeader({required this.screenWidth, required this.onAddCandidate});

  @override
  Widget build(BuildContext context) {
    final headerSize = clampDouble(screenWidth * 0.046, 17.0, 20.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Shortlisted Candidates',
                style: TextStyle(
                  fontSize: headerSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _AddCandidateHeaderButton(onTap: onAddCandidate),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Manage and advance candidates through hiring stages with Move Forward & Rollback.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
        ),
      ],
    );
  }
}

class _AddCandidateHeaderButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddCandidateHeaderButton({required this.onTap});
  @override
  State<_AddCandidateHeaderButton> createState() => _AddCandidateHeaderButtonState();
}

class _AddCandidateHeaderButtonState extends State<_AddCandidateHeaderButton> {
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
              Icon(LucideIcons.userPlus, size: 14, color: Colors.white),
              SizedBox(width: 5),
              Text('Add Candidate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageFilterTabs extends StatelessWidget {
  final String selectedStageTab;
  final List<CandidatePipelineItem> candidates;
  final ValueChanged<String> onSelectStage;

  const _StageFilterTabs({
    required this.selectedStageTab,
    required this.candidates,
    required this.onSelectStage,
  });

  @override
  Widget build(BuildContext context) {
    final stages = [
      {'id': 'ALL', 'label': 'All Stages (${candidates.length})'},
      {'id': 'shortlisted', 'label': 'Shortlisted (${candidates.where((c) => c.stage == 'shortlisted').length})'},
      {'id': 'contacted', 'label': 'Contacted (${candidates.where((c) => c.stage == 'contacted').length})'},
      {'id': 'interview', 'label': 'Interview (${candidates.where((c) => c.stage == 'interview').length})'},
      {'id': 'offer', 'label': 'Offer (${candidates.where((c) => c.stage == 'offer').length})'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: stages.map((stg) {
          final isActive = selectedStageTab.toLowerCase() == stg['id']!.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelectStage(stg['id']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5E17EB) : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isActive ? const Color(0xFF5E17EB) : AppColors.border),
                ),
                child: Text(
                  stg['label']!,
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

class _KanbanStageColumn extends StatelessWidget {
  final String stageId;
  final String stageTitle;
  final Color stageColor;
  final Color stageBg;
  final Color stageBorder;
  final List<CandidatePipelineItem> candidates;
  final ValueChanged<CandidatePipelineItem> onAdvance;
  final ValueChanged<CandidatePipelineItem> onRollback;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  const _KanbanStageColumn({
    required this.stageId,
    required this.stageTitle,
    required this.stageColor,
    required this.stageBg,
    required this.stageBorder,
    required this.candidates,
    required this.onAdvance,
    required this.onRollback,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header (1:1 with web Kanban border style)
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: stageColor, width: 2.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: stageColor, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      stageTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${candidates.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cards list or empty drop zone
          if (candidates.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: candidates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = candidates[i];
                return _KanbanCandidateCard(
                  candidate: c,
                  onAdvance: () => onAdvance(c),
                  onRollback: () => onRollback(c),
                  onRemove: () => onRemove(c.id),
                );
              },
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.inbox, size: 18, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text('No candidates in $stageTitle', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  const Text('Click below to add candidate to this stage.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Add to stage button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onAdd();
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.plus, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Add to $stageTitle', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanCandidateCard extends StatelessWidget {
  final CandidatePipelineItem candidate;
  final VoidCallback onAdvance;
  final VoidCallback onRollback;
  final VoidCallback onRemove;

  const _KanbanCandidateCard({
    required this.candidate,
    required this.onAdvance,
    required this.onRollback,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final isOffer = c.stage.toLowerCase() == 'offer';
    final isShortlisted = c.stage.toLowerCase() == 'shortlisted';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.role,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    if (c.source.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: Text(
                          'Source: ${c.source}',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF5E17EB)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(LucideIcons.trash2, size: 15, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Score Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  '${c.score}% Match',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Move Forward / Offer Issued / Rollback Actions (1:1 with web)
          if (!isOffer) ...[
            ElevatedButton(
              onPressed: onAdvance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E17EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(double.infinity, 32),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Move Forward →', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.checkCircle2, size: 14, color: Color(0xFF047857)),
                  SizedBox(width: 4),
                  Text('Offer Issued', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF047857))),
                ],
              ),
            ),
          ],

          if (!isShortlisted) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: onRollback,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.rotateCcw, size: 12, color: Color(0xFFE11D48)),
                    SizedBox(width: 4),
                    Text('Rollback', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFFE11D48))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddCandidateSheet extends StatefulWidget {
  final String defaultStage;
  final Function(String name, String role, String stage, String source, String score) onAdd;

  const _AddCandidateSheet({required this.defaultStage, required this.onAdd});

  @override
  State<_AddCandidateSheet> createState() => _AddCandidateSheetState();
}

class _AddCandidateSheetState extends State<_AddCandidateSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _scoreCtrl;
  String _nameError = '';
  String _roleError = '';
  late String _selectedStage;
  String _selectedSource = 'Referral';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _roleCtrl = TextEditingController();
    _scoreCtrl = TextEditingController(text: '90');
    _selectedStage = widget.defaultStage;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged(String val) {
    if (RegExp(r'[0-9]').hasMatch(val)) {
      setState(() => _nameError = 'Numbers are not allowed in Candidate Name');
    } else {
      setState(() => _nameError = '');
    }
    final cleaned = val.replaceAll(RegExp(r'[0-9]'), '');
    if (cleaned != val) {
      _nameCtrl.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
  }

  void _onRoleChanged(String val) {
    if (RegExp(r'[0-9]').hasMatch(val)) {
      setState(() => _roleError = 'Numbers are not allowed in Job Title / Role');
    } else {
      setState(() => _roleError = '');
    }
    final cleaned = val.replaceAll(RegExp(r'[0-9]'), '');
    if (cleaned != val) {
      _roleCtrl.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty || _roleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out Candidate Name and Job Role.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    widget.onAdd(
      _nameCtrl.text.trim(),
      _roleCtrl.text.trim(),
      _selectedStage,
      _selectedSource,
      _scoreCtrl.text.trim().isNotEmpty ? _scoreCtrl.text.trim() : '90',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.viewInsets.bottom;
    final hPad = clampDouble(screenWidth * 0.048, 14.0, 20.0);
    final titleSize = clampDouble(screenWidth * 0.044, 15.0, 18.0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.90),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: clampDouble(screenWidth * 0.1, 32.0, 42.0),
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Add Candidate (Referral / External)',
                        style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: AppColors.border),

              // Scrollable Form Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: hPad, right: hPad, top: 6, bottom: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Candidate Name
                        const Text('Candidate Name *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameCtrl,
                          onChanged: _onNameChanged,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'FullName (Letters only)',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                        if (_nameError.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(LucideIcons.alertTriangle, size: 12, color: Color(0xFFE11D48)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(_nameError, style: const TextStyle(fontSize: 11, color: Color(0xFFE11D48), fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                        const SizedBox(height: 14),

                        // Job Role
                        const Text('Job Role / Vacancy Title *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _roleCtrl,
                          onChanged: _onRoleChanged,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. Full Stack Developer (Letters only)',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                        if (_roleError.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(LucideIcons.alertTriangle, size: 12, color: Color(0xFFE11D48)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(_roleError, style: const TextStyle(fontSize: 11, color: Color(0xFFE11D48), fontWeight: FontWeight.w600)),
                            ),
                          ]),
                        ],
                        const SizedBox(height: 14),

                        // Candidate Source
                        const Text('Candidate Source *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSource,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'Referral', child: Text('Referral (Employee / Campus)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                                DropdownMenuItem(value: 'External / Outside', child: Text('External / Outside Application', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                                DropdownMenuItem(value: 'Direct Application', child: Text('Direct Campus Portal Application', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                              ],
                              onChanged: (val) => setState(() => _selectedSource = val ?? 'Referral'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Target Stage
                        const Text('Target Stage *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStage,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'shortlisted', child: Text('Shortlisted', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                                DropdownMenuItem(value: 'contacted', child: Text('Contacted', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                                DropdownMenuItem(value: 'interview', child: Text('Interview Scheduled', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                                DropdownMenuItem(value: 'offer', child: Text('Offer Extended', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                              ],
                              onChanged: (val) => setState(() => _selectedStage = val ?? 'shortlisted'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Match score
                        const Text('Skill Match Score (%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _scoreCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '90',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons Row
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
                                child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5E17EB),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Add Candidate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
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
            const Text('Failed to load candidate pipeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => context.read<PipelineBloc>().add(const FetchPipeline()),
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
