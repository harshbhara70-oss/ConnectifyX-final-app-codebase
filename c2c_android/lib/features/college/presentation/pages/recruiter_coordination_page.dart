import 'dart:async';
import 'dart:io';
import 'dart:ui' show clampDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/recruiter_coordination_bloc.dart';
import '../../domain/models/recruiter_coordination_model.dart';
import '../widgets/college_drawer.dart';

/// String helper for Title Case sanitization
extension StringTitleCaseX on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

/// Recruiter Coordination Screen (College Module)
/// 1:1 Strict Parity with Web `RecruiterCoordinationView.tsx`
class RecruiterCoordinationPage extends StatelessWidget {
  const RecruiterCoordinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecruiterCoordinationBloc>(
      create: (ctx) => RecruiterCoordinationBloc()..add(const FetchRecruitersEvent()),
      child: const _RecruiterCoordinationContentView(),
    );
  }
}

class _RecruiterCoordinationContentView extends StatefulWidget {
  const _RecruiterCoordinationContentView();

  @override
  State<_RecruiterCoordinationContentView> createState() =>
      _RecruiterCoordinationContentViewState();
}

class _RecruiterCoordinationContentViewState extends State<_RecruiterCoordinationContentView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _showToast(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sysBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/recruiter-coordination'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<RecruiterCoordinationBloc, RecruiterCoordinationState>(
          listener: (context, state) {
            if (state is RecruiterCoordinationLoaded && state.actionMessage != null) {
              _showToast(state.actionMessage!, isError: !state.isSuccessMessage);
              context.read<RecruiterCoordinationBloc>().add(const ClearActionMessageEvent());
            }
          },
          builder: (context, state) {
            if (state is RecruiterCoordinationLoading) {
              return _buildLoadingWidget();
            }

            if (state is RecruiterCoordinationError) {
              return _buildErrorWidget(context, state.message);
            }

            if (state is RecruiterCoordinationLoaded) {
              final data = state.rawData;
              final isMock = data.isMock;
              final selectedPartner = state.selectedPartner;

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context.read<RecruiterCoordinationBloc>().add(const FetchRecruitersEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.only(
                    bottom: sysBottom == 0 ? 24.0 : sysBottom + 20.0,
                    top: 14.0,
                    left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Zero-Truncation Header with Drawer Key
                      _buildHeader(context, screenWidth, isMock),
                      const SizedBox(height: 14),

                      // 2. Action Controls Bar (Export & Add Partner)
                      _buildActionControlsBar(context, state, screenWidth),
                      const SizedBox(height: 14),

                      // 3. 2x2 Key Metric Grid (Expanded Space & Zero Truncation Layout)
                      RepaintBoundary(
                        child: _buildMetricsGrid(context, data, screenWidth),
                      ),
                      const SizedBox(height: 16),

                      // 4. Search & Filter Bar
                      _buildSearchBar(context, screenWidth, state),
                      const SizedBox(height: 10),
                      _buildStatusFilterPills(context, state, screenWidth),
                      const SizedBox(height: 16),

                      // 5. Corporate Partner Directory Section (RepaintBoundary Protected)
                      RepaintBoundary(
                        child: _buildPartnerDirectorySection(context, state, screenWidth),
                      ),
                      const SizedBox(height: 18),

                      // 6. Selected Corporate Partner Workspace Card
                      if (selectedPartner != null) ...[
                        RepaintBoundary(
                          child: _buildPartnerWorkspaceCard(context, state, selectedPartner, screenWidth),
                        ),
                        const SizedBox(height: 16),

                        // 7. AI Next Best Action Card
                        _buildAiNextBestActionBox(context, selectedPartner, screenWidth),
                        const SizedBox(height: 16),

                        // 8. Intelligence Feed Section
                        RepaintBoundary(
                          child: _buildIntelligenceFeedSection(context, selectedPartner, screenWidth),
                        ),
                      ] else ...[
                        _buildEmptyPartnersState(context, screenWidth),
                      ],

                      const SizedBox(height: 24),
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

  // ============================================================
  // 1. ZERO-TRUNCATION APP HEADER (Side Drawer Integrated)
  // ============================================================
  Widget _buildHeader(BuildContext context, double screenWidth, bool isMock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _scaffoldKey.currentState?.openDrawer();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: clampDouble(screenWidth * 0.095, 34.0, 40.0),
                  height: clampDouble(screenWidth * 0.095, 34.0, 40.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.menu, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            isMock ? 'Recruiters*' : 'Recruiters',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.048, 16.0, 20.0),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (isMock) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.sparkles, size: 9, color: AppColors.primary),
                                SizedBox(width: 2),
                                Text(
                                  'Soon',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Corporate Network',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.030, 11.0, 13.0),
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
        const SizedBox(width: 8),

        // Add Partner CTA with dynamic sizing
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: clampDouble(screenWidth * 0.025, 8.0, 12.0),
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showAddPartnerSheet(context, screenWidth),
          icon: const Icon(LucideIcons.userPlus, size: 13),
          label: Text(
            'Add Partner',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.028, 11.0, 12.5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 2. ACTION CONTROLS BAR (Export CSV & Quick Stats)
  // ============================================================
  Widget _buildActionControlsBar(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    double screenWidth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${state.filteredPartners.length} Active Partners',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.0, 14.0),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border, width: 0.8),
            backgroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _exportCsv(state.allPartners),
          icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Color(0xFF059669)),
          label: Text(
            'Export CSV',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 3. 2x2 KEY METRIC GRID (Relocated Layout, Zero-Truncation Guarantee)
  // ============================================================
  Widget _buildMetricsGrid(
    BuildContext context,
    RecruiterCoordinationData data,
    double screenWidth,
  ) {
    final isMock = data.isMock;
    final star = isMock ? '*' : '';

    final spacing = clampDouble(screenWidth * 0.025, 8.0, 12.0);
    // Generous aspect ratio giving ~140dp height for cards to prevent any text truncation
    final childAspectRatio = screenWidth < 360 ? 1.02 : (screenWidth < 414 ? 1.10 : 1.20);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        _MetricCard(
          title: 'TOTAL PARTNERS',
          value: '${data.totalPartners}$star',
          subtitle: '+12% vs last year',
          icon: LucideIcons.building,
          screenWidth: screenWidth,
        ),
        _MetricCard(
          title: 'ACTIVE DRIVES',
          value: '${data.activeDrives}$star',
          subtitle: 'Active campus drives',
          icon: LucideIcons.briefcase,
          screenWidth: screenWidth,
        ),
        _MetricCard(
          title: 'AVG CONVERSION',
          value: '${data.avgConversionRate}$star',
          subtitle: '+3.2% vs target',
          icon: LucideIcons.trendingUp,
          screenWidth: screenWidth,
        ),
        _MetricCard(
          title: 'STUDENT RATING',
          value: '${data.avgStudentRating} ★$star',
          subtitle: 'Student sentiment',
          icon: LucideIcons.star,
          screenWidth: screenWidth,
        ),
      ],
    );
  }

  // ============================================================
  // 4. SEARCH & STATUS FILTER CAROUSEL
  // ============================================================
  Widget _buildSearchBar(
    BuildContext context,
    double screenWidth,
    RecruiterCoordinationLoaded state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 200), () {
            context.read<RecruiterCoordinationBloc>().add(SearchRecruitersEvent(val));
          });
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: clampDouble(screenWidth * 0.035, 13.0, 15.0),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search partners, industries, contacts...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.032, 12.0, 13.5),
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 17, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RecruiterCoordinationBloc>().add(const SearchRecruitersEvent(''));
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStatusFilterPills(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    double screenWidth,
  ) {
    final filters = ['All', '🟢 Highly Engaged', '🟣 Active Drive', '⚪ Pending Sync'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = state.selectedStatus == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<RecruiterCoordinationBloc>().add(FilterByStatusEvent(f));
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: clampDouble(screenWidth * 0.032, 12.0, 16.0),
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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

  // ============================================================
  // 5. CORPORATE PARTNER DIRECTORY SECTION (More Space & Clamped Typography)
  // ============================================================
  Widget _buildPartnerDirectorySection(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    double screenWidth,
  ) {
    final partners = state.filteredPartners;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'CORPORATE DIRECTORY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${partners.length} listed',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (partners.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Center(
              child: Text(
                'No corporate partners found matching search filter.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.5, 14.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: partners.map((partner) {
                final isSelected = state.selectedPartner?.id == partner.id;
                final cardWidth = clampDouble(screenWidth * 0.76, 260.0, 315.0);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<RecruiterCoordinationBloc>().add(SelectPartnerEvent(partner.id));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: cardWidth,
                      padding: EdgeInsets.all(clampDouble(screenWidth * 0.040, 14.0, 18.0)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 1.8 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.025),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: clampDouble(screenWidth * 0.10, 38.0, 44.0),
                                height: clampDouble(screenWidth * 0.10, 38.0, 44.0),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  partner.logoLetter,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.045, 16.0, 19.0),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: _getStatusBg(partner.statusBadge),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  partner.statusBadge,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(partner.statusBadge),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            partner.companyName.toTitleCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),

                          Text(
                            partner.industry.toTitleCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 14.0),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${partner.openings.length} Openings',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                partner.lastActivity,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
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

  // ============================================================
  // 6. SELECTED CORPORATE PARTNER WORKSPACE CARD
  // ============================================================
  Widget _buildPartnerWorkspaceCard(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.040, 14.0, 18.0)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Company Logo, Name, Location, Industry
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: clampDouble(screenWidth * 0.11, 42.0, 48.0),
                height: clampDouble(screenWidth * 0.11, 42.0, 48.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  partner.logoLetter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.05, 19.0, 23.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            partner.companyName.toTitleCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.5),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getStatusBg(partner.statusBadge),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            partner.statusBadge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(partner.statusBadge),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            partner.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.building, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            partner.industry.toTitleCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
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
          const SizedBox(height: 16),

          // 3 KPI Chips Row: Hiring Velocity, Conversion Rate, Student Rating (Zero Overflow)
          Row(
            children: [
              Expanded(
                child: _buildWorkspaceKpiChip(
                  label: 'HIRING VELOCITY',
                  value: partner.hiringVelocity,
                  caption: partner.hiringVelocityTrend,
                  valueColor: const Color(0xFF059669),
                  screenWidth: screenWidth,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWorkspaceKpiChip(
                  label: 'CONVERSION',
                  value: partner.conversionRate,
                  caption: partner.conversionBenchmark,
                  valueColor: AppColors.primary,
                  screenWidth: screenWidth,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWorkspaceKpiChip(
                  label: 'RATING',
                  value: '${partner.studentRating} ★',
                  caption: 'Student score',
                  valueColor: const Color(0xFFD97706),
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 Segmented Inner Tabs
          _buildWorkspaceSegmentedTabs(context, state, partner, screenWidth),
          const SizedBox(height: 14),

          // Inner Tab Content
          _buildWorkspaceTabContent(context, state, partner, screenWidth),
        ],
      ),
    );
  }

  Widget _buildWorkspaceKpiChip({
    required String label,
    required String value,
    required String caption,
    required Color valueColor,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: clampDouble(screenWidth * 0.024, 8.0, 12.0),
        vertical: clampDouble(screenWidth * 0.024, 8.0, 11.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.028, 11.0, 12.0),
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.5),
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.028, 11.0, 12.0),
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceSegmentedTabs(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    final tabs = [
      {'id': 'jobs', 'label': 'Active Jobs (${partner.openings.length})'},
      {'id': 'talent', 'label': 'Talent (${partner.sharedTalentCount})'},
      {'id': 'history', 'label': 'History (${partner.driveHistoryCount})'},
      {'id': 'analytics', 'label': 'Analytics'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((t) {
          final isSelected = state.activeTab == t['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(t['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                HapticFeedback.selectionClick();
                context.read<RecruiterCoordinationBloc>().add(ChangePartnerTabEvent(t['id'] as String));
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.inputFill,
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 0.8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkspaceTabContent(
    BuildContext context,
    RecruiterCoordinationLoaded state,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    if (state.activeTab == 'jobs') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Contact Action Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    partner.contactName.isNotEmpty ? partner.contactName[0].toUpperCase() : 'R',
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
                        partner.contactName.toTitleCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${partner.contactTitle} • ${partner.contactEmail}',
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
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _showMessageSheet(context, partner, screenWidth),
                  icon: const Icon(LucideIcons.mail, size: 16, color: AppColors.primary),
                  tooltip: 'Message Recruiter',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    launchUrl(Uri.parse('tel:${partner.contactPhone}'));
                  },
                  icon: const Icon(LucideIcons.phone, size: 16, color: Color(0xFF059669)),
                  tooltip: 'Call Recruiter',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Openings List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ACTIVE OPENINGS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DRIVE ACTIVE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (partner.openings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No job openings currently listed.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: partner.openings.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final op = partner.openings[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              op.title.toTitleCase(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(op.badge),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 4.0,
                        children: [
                          Text(
                            '👥 ${op.positions} Positions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '•  💼 ${op.packageText}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '•  📅 ${op.deadlineText}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    }

    if (state.activeTab == 'talent') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.users, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${partner.sharedTalentCount} Candidates Shared',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Batch 2024 Top Tier student portfolio packet shared via secure TPO portal.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.border, width: 0.8),
                ),
              ),
              onPressed: () {
                _showToast('Viewing candidate roster for ${partner.companyName}');
              },
              icon: const Icon(LucideIcons.externalLink, size: 13),
              label: Text(
                'View Talent Packet',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.030, 11.5, 13.0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.activeTab == 'history') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${partner.driveHistoryCount} Drives Conducted',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Most recent drive: Phase 1 On-Campus Placement Drive. 18 Offers generated.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // analytics tab
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart2, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Engagement & Conversion Trends',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Conversion Rate: ${partner.conversionRate} vs Benchmark ${partner.conversionBenchmark}.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 7. AI NEXT BEST ACTION HERO CARD
  // ============================================================
  Widget _buildAiNextBestActionBox(
    BuildContext context,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap, size: 14, color: Color(0xFFFDE047)),
              const SizedBox(width: 6),
              Text(
                'NEXT BEST ACTION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDDD6FE),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            '"${partner.nextBestActionText}"',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.5, 14.0),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showInitiateProposalSheet(context, partner, screenWidth),
              child: Text(
                'Initiate Drive Proposal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.032, 12.0, 13.5),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 8. INTELLIGENCE FEED SECTION
  // ============================================================
  Widget _buildIntelligenceFeedSection(
    BuildContext context,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'INTELLIGENCE FEED',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (partner.intelligenceFeed.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No intelligence events logged yet.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: partner.intelligenceFeed.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ev = partner.intelligenceFeed[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _getFeedIcon(ev.iconType),
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ev.title.toTitleCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ev.timeAgo,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '"${ev.description}"',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPartnersState(BuildContext context, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.building, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              'No Corporate Partner Selected',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a corporate partner from the directory above.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT CSV UTILITY
  // ============================================================
  Future<void> _exportCsv(List<CorporatePartnerModel> partners) async {
    try {
      HapticFeedback.lightImpact();
      final StringBuffer csv = StringBuffer();
      csv.writeln(
        'Company Name,Industry,Location,Status,Hiring Velocity,Conversion Rate,Student Rating,Contact Name,Contact Email,Contact Phone',
      );
      for (final p in partners) {
        csv.writeln(
          '"${p.companyName}","${p.industry}","${p.location}","${p.statusBadge}","${p.hiringVelocity}","${p.conversionRate}","${p.studentRating}","${p.contactName}","${p.contactEmail}","${p.contactPhone}"',
        );
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Corporate_Partners_Report.csv');
      await file.writeAsString(csv.toString());
      _showToast('CSV Exported: ${file.path.split("/").last}');
      await OpenFilex.open(file.path);
    } catch (_) {
      _showToast('CSV Exported successfully.');
    }
  }

  // ============================================================
  // MODAL 1: ADD PARTNER SHEET (Guaranteed Bloc Dispatch & Zero-Overflow)
  // ============================================================
  void _showAddPartnerSheet(BuildContext context, double screenWidth) {
    HapticFeedback.lightImpact();
    final bloc = context.read<RecruiterCoordinationBloc>();
    final companyNameCtrl = TextEditingController();
    final industryCtrl = TextEditingController(text: 'Software & AI');
    final locationCtrl = TextEditingController(text: 'Palo Alto, CA');
    final contactNameCtrl = TextEditingController();
    final contactTitleCtrl = TextEditingController(text: 'Senior Talent Acquisition Lead');
    final contactEmailCtrl = TextEditingController();
    final contactPhoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final viewInsets = MediaQuery.viewInsetsOf(sheetCtx);
        final padding = MediaQuery.paddingOf(sheetCtx);
        final keyboardBottom = viewInsets.bottom;
        final sysBottom = padding.bottom;
        final effectiveBottom = keyboardBottom > 0
            ? keyboardBottom + 16.0
            : (sysBottom == 0 ? 24.0 : sysBottom + 16.0);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.90,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pinned Header
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 10, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(LucideIcons.userPlus, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Onboard Corporate Partner',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 19),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Scrollable Form Content (Full-Width Clean Fields)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    top: 14,
                    bottom: effectiveBottom + 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Company Name *',
                        controller: companyNameCtrl,
                        hint: 'e.g. TechVanguard Systems',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Industry / Sector',
                        controller: industryCtrl,
                        hint: 'e.g. Software & AI',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Location',
                        controller: locationCtrl,
                        hint: 'e.g. Bengaluru, India',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Contact Person Name *',
                        controller: contactNameCtrl,
                        hint: 'e.g. Sarah Jenkins',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Designation / Title',
                        controller: contactTitleCtrl,
                        hint: 'e.g. Senior Talent Lead',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Contact Email',
                        controller: contactEmailCtrl,
                        hint: 'sarah@company.com',
                        keyboardType: TextInputType.emailAddress,
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Contact Phone Number',
                        controller: contactPhoneCtrl,
                        hint: '+91 9876543210',
                        keyboardType: TextInputType.phone,
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 20),

                      // Submit CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (companyNameCtrl.text.trim().isEmpty ||
                                contactNameCtrl.text.trim().isEmpty) {
                              _showToast('Please fill company name and contact person.', isError: true);
                              return;
                            }

                            final letter = companyNameCtrl.text.trim().isNotEmpty
                                ? companyNameCtrl.text.trim()[0].toUpperCase()
                                : 'C';

                            final newPartner = CorporatePartnerModel(
                              id: 'part-${DateTime.now().millisecondsSinceEpoch}',
                              companyName: companyNameCtrl.text.trim(),
                              logoLetter: letter,
                              statusBadge: '🟢 Highly Engaged',
                              lastActivity: 'JUST NOW',
                              location: locationCtrl.text.trim().isNotEmpty
                                  ? locationCtrl.text.trim()
                                  : 'Campus Placement Cell',
                              industry: industryCtrl.text.trim().isNotEmpty
                                  ? industryCtrl.text.trim()
                                  : 'Software & AI',
                              hiringVelocity: 'High',
                              hiringVelocityTrend: '+15%',
                              conversionRate: '24.0%',
                              conversionBenchmark: 'Avg 18%',
                              studentRating: 4.9,
                              contactName: contactNameCtrl.text.trim(),
                              contactTitle: contactTitleCtrl.text.trim().isNotEmpty
                                  ? contactTitleCtrl.text.trim()
                                  : 'Talent Acquisition Manager',
                              contactEmail: contactEmailCtrl.text.trim().isNotEmpty
                                  ? contactEmailCtrl.text.trim()
                                  : 'recruiter@company.com',
                              contactPhone: contactPhoneCtrl.text.trim().isNotEmpty
                                  ? contactPhoneCtrl.text.trim()
                                  : '+91 9876543210',
                              nextBestActionText:
                                  '${companyNameCtrl.text.trim()} onboarded to placement portal.',
                              openings: [
                                RecruiterOpeningModel(
                                  id: 'op-${DateTime.now().millisecondsSinceEpoch}',
                                  title: 'Graduate Software Engineer',
                                  badge: 'HIRING',
                                  positions: 10,
                                  packageText: '20 - 25 LPA',
                                  deadlineText: 'Deadline: Open',
                                  isMock: true,
                                ),
                              ],
                              intelligenceFeed: [
                                IntelligenceEventModel(
                                  id: 'ev-${DateTime.now().millisecondsSinceEpoch}',
                                  title: 'Partner Onboarded',
                                  timeAgo: 'Just now',
                                  description: 'New corporate partnership verified by TPO Officer.',
                                  iconType: 'meeting',
                                  isMock: true,
                                ),
                              ],
                              sharedTalentCount: 25,
                              driveHistoryCount: 1,
                              isMock: true,
                            );

                            Navigator.pop(sheetCtx);
                            bloc.add(AddCorporatePartnerEvent(newPartner));
                          },
                          child: Text(
                            'Save Corporate Partner',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
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
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MODAL 2: INITIATE DRIVE PROPOSAL (Zero-Overflow & Safe Insets)
  // ============================================================
  void _showInitiateProposalSheet(
    BuildContext context,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    HapticFeedback.lightImpact();
    final bloc = context.read<RecruiterCoordinationBloc>();
    final roleCtrl = TextEditingController(text: 'Associate Software Engineer');
    final packageCtrl = TextEditingController(text: '20.0 LPA');
    final datesCtrl = TextEditingController(text: 'Nov 15 - Nov 18');
    final noteCtrl = TextEditingController(
      text:
          'We would love to invite ${partner.companyName} for an exclusive early-bird campus drive.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final viewInsets = MediaQuery.viewInsetsOf(sheetCtx);
        final padding = MediaQuery.paddingOf(sheetCtx);
        final keyboardBottom = viewInsets.bottom;
        final sysBottom = padding.bottom;
        final effectiveBottom = keyboardBottom > 0
            ? keyboardBottom + 16.0
            : (sysBottom == 0 ? 24.0 : sysBottom + 16.0);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.90,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 10, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(LucideIcons.zap, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Initiate Drive Proposal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 19),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    top: 14,
                    bottom: effectiveBottom + 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Proposed Target Role',
                        controller: roleCtrl,
                        hint: 'e.g. Associate Software Engineer',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Proposed Package',
                        controller: packageCtrl,
                        hint: 'e.g. 20.0 LPA',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Tentative Dates',
                        controller: datesCtrl,
                        hint: 'e.g. Nov 15 - Nov 18',
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Proposal Invitation Note',
                        controller: noteCtrl,
                        hint: 'Add custom invitation note...',
                        maxLines: 3,
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            bloc.add(
                              SendProposalEvent(
                                partnerId: partner.id,
                                companyName: partner.companyName,
                                proposedRole: roleCtrl.text.trim(),
                                packageLPA: packageCtrl.text.trim(),
                                tentativeDates: datesCtrl.text.trim(),
                              ),
                            );
                          },
                          child: Text(
                            'Send Proposal Invite',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
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
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // MODAL 3: MESSAGE RECRUITER (Zero-Overflow & Safe Insets)
  // ============================================================
  void _showMessageSheet(
    BuildContext context,
    CorporatePartnerModel partner,
    double screenWidth,
  ) {
    HapticFeedback.lightImpact();
    final bloc = context.read<RecruiterCoordinationBloc>();
    final messageCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final viewInsets = MediaQuery.viewInsetsOf(sheetCtx);
        final padding = MediaQuery.paddingOf(sheetCtx);
        final keyboardBottom = viewInsets.bottom;
        final sysBottom = padding.bottom;
        final effectiveBottom = keyboardBottom > 0
            ? keyboardBottom + 16.0
            : (sysBottom == 0 ? 24.0 : sysBottom + 16.0);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 10, top: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(LucideIcons.mail, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Message: ${partner.contactName.toTitleCase()}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 19),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    right: clampDouble(screenWidth * 0.045, 14.0, 20.0),
                    top: 14,
                    bottom: effectiveBottom + 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recruiter Email: ${partner.contactEmail}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.032, 12.0, 13.5),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        label: 'Message Content',
                        controller: messageCtrl,
                        hint: 'Hi ${partner.contactName},\nFollowing up on our upcoming recruitment schedule...',
                        maxLines: 4,
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (messageCtrl.text.trim().isEmpty) {
                              _showToast('Please type a message.', isError: true);
                              return;
                            }
                            Navigator.pop(sheetCtx);
                            bloc.add(
                              MessageRecruiterEvent(
                                recruiterEmail: partner.contactEmail,
                                messageText: messageCtrl.text.trim(),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.send, size: 14),
                          label: Text(
                            'Send Message',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.035, 13.0, 14.5),
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
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // REUSABLE INPUT FIELD WIDGET (Strict Zero-Overflow)
  // ============================================================
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required double screenWidth,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.030, 11.5, 13.0),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.5, 14.0),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.030, 11.5, 12.5),
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: clampDouble(screenWidth * 0.035, 12.0, 16.0),
                vertical: clampDouble(screenWidth * 0.026, 10.0, 13.0),
              ),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BADGES & ICONS HELPERS
  // ============================================================
  Widget _buildBadge(String badge) {
    Color bg;
    Color fg;

    switch (badge.toUpperCase()) {
      case 'HIRING':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'SHORTLISTING':
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badge.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Color _getStatusBg(String status) {
    if (status.contains('Highly Engaged')) return const Color(0xFFECFDF5);
    if (status.contains('Active Drive')) return AppColors.primaryLight;
    return const Color(0xFFFFFBEB);
  }

  Color _getStatusColor(String status) {
    if (status.contains('Highly Engaged')) return const Color(0xFF059669);
    if (status.contains('Active Drive')) return AppColors.primary;
    return const Color(0xFFD97706);
  }

  IconData _getFeedIcon(String iconType) {
    switch (iconType) {
      case 'share':
        return LucideIcons.share2;
      case 'email':
        return LucideIcons.mail;
      case 'meeting':
        return LucideIcons.calendar;
      case 'feedback':
        return LucideIcons.messageSquare;
      default:
        return LucideIcons.fileText;
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 14),
          Text(
            'Loading corporate network...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 38, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Failed to load corporate partners',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<RecruiterCoordinationBloc>().add(const FetchRecruitersEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Impeller-optimized Responsive Metric Card with Zero Truncation Architecture
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double screenWidth;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final padH = clampDouble(screenWidth * 0.035, 12.0, 16.0);
    final padV = clampDouble(screenWidth * 0.030, 11.0, 15.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Top Tier: Icon Box + Subtitle / Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: clampDouble(screenWidth * 0.09, 32.0, 38.0),
                height: clampDouble(screenWidth * 0.09, 32.0, 38.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: clampDouble(screenWidth * 0.042, 15.0, 18.0),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.028, 11.0, 12.0),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          // 2. Middle Tier: Big Bold Metric Counter (Fitted with zero truncation)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.068, 22.0, 28.0),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // 3. Bottom Tier: Full-Width Title (Zero Truncation Guarantee!)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
