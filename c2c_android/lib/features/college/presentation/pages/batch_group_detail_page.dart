import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/batch_group_bloc.dart';
import '../../domain/models/batch_group_model.dart';
import '../widgets/college_drawer.dart';

/// College Batch Group Detail Page — Live Student Roster for a specific Cohort.
///
/// Features:
/// - Live MongoDB Atlas student roster with `isMock` boolean & `*` flag
/// - Filter by eligibility status (All, Eligible, Active)
/// - Student profile cards with initials avatar, percentage, skills, and status
/// - Zero-overflow clamped typography and 120Hz Impeller RepaintBoundary
class BatchGroupDetailPage extends StatelessWidget {
  final String batchId;

  const BatchGroupDetailPage({super.key, required this.batchId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BatchGroupBloc()..add(FetchBatchMembersEvent(batchId)),
      child: _BatchGroupDetailView(batchId: batchId),
    );
  }
}

class _BatchGroupDetailView extends StatefulWidget {
  final String batchId;

  const _BatchGroupDetailView({required this.batchId});

  @override
  State<_BatchGroupDetailView> createState() => _BatchGroupDetailViewState();
}

class _BatchGroupDetailViewState extends State<_BatchGroupDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    HapticFeedback.lightImpact();
    context.read<BatchGroupBloc>().add(FetchBatchMembersEvent(widget.batchId));
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final dynamicHorizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);
    final dynamicBottomPadding = bottomInset == 0 ? 16.0 : bottomInset + 24.0;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.bg,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/batches'),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _refresh(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: 16.0,
              left: dynamicHorizontalPadding,
              right: dynamicHorizontalPadding,
              bottom: dynamicBottomPadding + 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBar(context, screenWidth),
                const SizedBox(height: 16),
                BlocBuilder<BatchGroupBloc, BatchGroupState>(
                  builder: (context, state) {
                    if (state is BatchMembersLoading || state is BatchGroupInitial) {
                      return _buildLoadingState(context, screenWidth);
                    }
                    if (state is BatchMembersError) {
                      return _buildErrorState(context, screenWidth, state.message);
                    }
                    if (state is BatchMembersLoaded) {
                      return _buildDetailBody(
                        context,
                        screenWidth,
                        state.detail,
                        state.isMock,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER BAR
  // ===========================================================================
  Widget _buildHeaderBar(BuildContext context, double screenWidth) {
    final titleSize = clampDouble(screenWidth * 0.048, 17.0, 20.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                if (Navigator.canPop(context)) {
                  context.pop();
                } else {
                  context.go('/college/batches');
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.priLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cohort Candidate Roster',
              style: GoogleFonts.plusJakartaSans(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: context.txtPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. DETAIL BODY CONTENT
  // ===========================================================================
  Widget _buildDetailBody(
    BuildContext context,
    double screenWidth,
    BatchDetailModel detail,
    bool isMock,
  ) {
    final batch = detail.batch;
    final query = _searchController.text.trim().toLowerCase();

    final filteredMembers = detail.members.where((m) {
      final matchesQuery = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.email.toLowerCase().contains(query) ||
          m.skills.any((s) => s.toLowerCase().contains(query));
      final matchesFilter = _filter == 'All' ||
          (_filter == 'Eligible' && m.isEligible) ||
          (_filter == 'Active' && m.status.toLowerCase() == 'active');
      return matchesQuery && matchesFilter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cohort Overview Card
        _buildCohortHeaderCard(context, screenWidth, batch, isMock),
        const SizedBox(height: 16),
        // Search & Filter Tier
        _buildSearchAndFilters(context, screenWidth),
        const SizedBox(height: 16),
        // Members Roster Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enrolled Candidates (${filteredMembers.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                fontWeight: FontWeight.w700,
                color: context.txtPrimary,
              ),
            ),
            if (isMock)
              Text(
                'Demo Roster *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Members List
        if (filteredMembers.isEmpty)
          _buildEmptyMembers(context)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredMembers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              return _buildMemberCard(context, screenWidth, member);
            },
          ),
      ],
    );
  }

  Widget _buildCohortHeaderCard(
    BuildContext context,
    double screenWidth,
    BatchGroupModel batch,
    bool isMock,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.priLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  batch.departmentCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name + (isMock ? ' *' : ''),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.046, 16.0, 18.5),
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Graduating Batch ${batch.batchYear}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: context.txtSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            batch.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: context.txtSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          // 3 Metric Pills
          Row(
            children: [
              Expanded(
                child: _buildCohortStatPill(
                  context,
                  label: 'STUDENTS',
                  value: '${batch.memberCount}${isMock ? ' *' : ''}',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCohortStatPill(
                  context,
                  label: 'ELIGIBLE',
                  value: '${batch.eligibleCount}${isMock ? ' *' : ''}',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCohortStatPill(
                  context,
                  label: 'PLACEMENT',
                  value: '${batch.placementRate}%${isMock ? ' *' : ''}',
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCohortStatPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: context.txtMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, double screenWidth) {
    final filters = ['All', 'Eligible', 'Active'];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.brdr, width: 0.8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: context.txtPrimary),
            decoration: InputDecoration(
              hintText: 'Search candidate name, email, or skill...',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: context.txtMuted),
              prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
              border: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: filters.map((f) {
            final isSelected = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _filter = f);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : context.surf,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : context.brdr,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : context.txtSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    double screenWidth,
    BatchMemberModel member,
  ) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.brdr, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/college/students/${member.id}');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: context.priLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getInitials(member.name),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name + (member.isMock ? ' *' : ''),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.txtPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              member.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: context.txtSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Score % Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: member.percentage >= 75
                              ? AppColors.successLight
                              : AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${member.percentage}%${member.isMock ? ' *' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: member.percentage >= 75
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Skills Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: member.skills.take(4).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.surfAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: context.txtSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMembers(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.users, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            'No Candidates Match Filter',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.txtPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, double screenWidth) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 90,
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.brdr, width: 0.8),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, double screenWidth, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        children: [
          const Icon(LucideIcons.alertTriangle, size: 32, color: Color(0xFFEF4444)),
          const SizedBox(height: 10),
          Text(
            'Unable to Load Candidate Roster',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.txtPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.txtSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}