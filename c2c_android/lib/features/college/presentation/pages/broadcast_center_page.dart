import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/components/custom_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';
import '../../bloc/college_broadcast_bloc.dart';
import '../../data/services/broadcast_center_api_service.dart';
import '../../domain/models/broadcast_center_model.dart';
import '../widgets/college_drawer.dart';

/// Broadcast Center — College Module (Strict 1:1 Parity with BroadcastCenterView.tsx)
class BroadcastCenterPage extends StatelessWidget {
  const BroadcastCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CollegeBroadcastBloc(apiService: BroadcastCenterApiService())
        ..add(const FetchBroadcastCenterEvent()),
      child: const _BroadcastCenterView(),
    );
  }
}

class _BroadcastCenterView extends StatefulWidget {
  const _BroadcastCenterView();

  @override
  State<_BroadcastCenterView> createState() => _BroadcastCenterViewState();
}

class _BroadcastCenterViewState extends State<_BroadcastCenterView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  Timer? _searchDebounce;
  int _navIndex = 0;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, BuildContext context) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (context.mounted) {
        context.read<CollegeBroadcastBloc>().add(SearchBroadcastEvent(query));
      }
    });
  }

  void _clearSearch(BuildContext context) {
    _searchDebounce?.cancel();
    _searchCtrl.clear();
    context.read<CollegeBroadcastBloc>().add(const SearchBroadcastEvent(''));
    FocusManager.instance.primaryFocus?.unfocus();
  }

  int _estimateRecipients(String audience) {
    if (audience == 'All Final Years') return 850;
    if (audience == 'All Students') return 1200;
    if (audience == 'Corporate Recruiters & HRs') return 65;
    if (audience == 'Electronics 2024 Batch') return 180;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return BlocConsumer<CollegeBroadcastBloc, CollegeBroadcastState>(
      listener: (context, state) {
        if (state is CollegeBroadcastLoaded && state.toastMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: state.isToastError ? AppColors.error : AppColors.textPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              content: Row(
                children: [
                  Icon(
                    state.isToastError ? LucideIcons.alertCircle : LucideIcons.checkCircle2,
                    color: state.isToastError ? Colors.white : AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.toastMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<CollegeBroadcastBloc>().add(ClearBroadcastToastEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: const CollegeNavigationDrawer(currentRoute: '/college/broadcast'),
          body: SafeArea(
            bottom: true,
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                context.read<CollegeBroadcastBloc>().add(const FetchBroadcastCenterEvent());
              },
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: _buildBody(context, state, screenWidth, bottomPad),
            ),
          ),
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _navIndex,
            onTap: (i) {
              setState(() => _navIndex = i);
              _handleNav(i);
            },
            onFabPressed: () => _showComposeModal(context),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CollegeBroadcastState state,
    double screenWidth,
    double bottomPad,
  ) {
    if (state is CollegeBroadcastLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/loading_spinner.json', width: 120, height: 120),
                  const SizedBox(height: 12),
                  Text(
                    'Loading Broadcast Center...',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Syncing messages and batch groups',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 12.0, 14.0),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (state is CollegeBroadcastLoaded) {
      final data = state.data;
      final broadcasts = state.filteredBroadcasts;
      final drafts = state.filteredDrafts;
      final batchGroups = state.filteredBatchGroups;
      final isMock = data.isMock;

      return SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(
          left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
          right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
          top: 14.0,
          bottom: bottomPad == 0 ? 110 : bottomPad + 96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Toolbar (Ultra-Clean, Zero Truncation)
            _buildHeader(context, screenWidth, isMock),
            const SizedBox(height: 12),

            // 2. New Broadcast Hero Action Banner (Top of Body)
            _buildNewBroadcastBanner(context, screenWidth),
            const SizedBox(height: 12),

            // 3. Ultra-Professional Search & Filter Suite
            _buildSearchAndFilterSuite(
              context,
              screenWidth,
              state.searchQuery,
              state.activeTab == 'all'
                  ? broadcasts.length
                  : (state.activeTab == 'drafts' ? drafts.length : batchGroups.length),
            ),
            const SizedBox(height: 14),

            // 4. Navigation Tabs: All Broadcasts | Drafts | Batch Groups
            _buildNavigationTabs(context, screenWidth, state.activeTab, data.drafts.length),
            const SizedBox(height: 14),

            // 5. Key Metrics Summary Cards (Total Sent, Avg Open Rate, Urgent Pending)
            RepaintBoundary(
              child: _buildKeyMetrics(context, screenWidth, data),
            ),
            const SizedBox(height: 18),

            // 6. Active Tab View Panels
            if (state.activeTab == 'all')
              RepaintBoundary(
                child: _buildBroadcastsFeed(context, screenWidth, broadcasts, isMock),
              )
            else if (state.activeTab == 'drafts')
              RepaintBoundary(
                child: _buildDraftsList(context, screenWidth, drafts, isMock),
              )
            else
              RepaintBoundary(
                child: _buildBatchGroupsGrid(context, screenWidth, batchGroups, isMock),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ===========================================================================
  // 1. Header Toolbar (Ultra-Clean, Zero Truncation Guarantee)
  // ===========================================================================
  Widget _buildHeader(BuildContext context, double screenWidth, bool isMock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          BouncyButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                _scaffoldKey.currentState?.openDrawer();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Icon(
                Navigator.canPop(context) ? LucideIcons.chevronLeft : LucideIcons.menu,
                size: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Broadcast${isMock ? " *" : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.042, 16.0, 18.0),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (isMock) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.sparkles, size: 9, color: AppColors.primary),
                            const SizedBox(width: 2.5),
                            Text(
                              'Soon',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1.5),
                Text(
                  'Campus Notices',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.5, 12.5),
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

  // ===========================================================================
  // 2. New Broadcast Hero Action Banner (Top of Body)
  // ===========================================================================
  Widget _buildNewBroadcastBanner(BuildContext context, double screenWidth) {
    return BouncyButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        _showComposeModal(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Broadcast',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Send alerts to students & recruiters',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.029, 11.0, 12.0),
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.plus, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    'Compose',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
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
    );
  }

  // ===========================================================================
  // 2. Ultra-Professional Search & Filter Suite
  // ===========================================================================
  Widget _buildSearchAndFilterSuite(
    BuildContext context,
    double screenWidth,
    String searchQuery,
    int resultCount,
  ) {
    final hasQuery = searchQuery.trim().isNotEmpty;
    final filterTags = ['All', 'Urgent 🔥', 'CS & IT', 'Final Years', 'Placement', '2024 Batch'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Bar (Full Width, Aesthetic)
        Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasQuery ? AppColors.primary : AppColors.border,
              width: hasQuery ? 1.2 : 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: hasQuery ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.search,
                  size: 15,
                  color: hasQuery ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => _onSearchChanged(val, context),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.034, 12.5, 14.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by title, audience, batch or keyword...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (hasQuery) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$resultCount found',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _clearSearch(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(LucideIcons.x, size: 13, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Quick Filter Pills (Horizontal Scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filterTags.map((tag) {
              final isAll = tag == 'All';
              final isSelected = isAll ? !hasQuery : searchQuery.toLowerCase().contains(tag.replaceAll(' 🔥', '').toLowerCase());

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (isAll || isSelected) {
                      _clearSearch(context);
                    } else {
                      final cleanTag = tag.replaceAll(' 🔥', '');
                      _searchCtrl.text = cleanTag;
                      _onSearchChanged(cleanTag, context);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1.5),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
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

  // ===========================================================================
  // 3. Navigation Tabs
  // ===========================================================================
  Widget _buildNavigationTabs(
    BuildContext context,
    double screenWidth,
    String activeTab,
    int draftCount,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              context: context,
              label: 'All Broadcasts',
              isActive: activeTab == 'all',
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CollegeBroadcastBloc>().add(const ChangeBroadcastTabEvent('all'));
              },
              screenWidth: screenWidth,
            ),
          ),
          Expanded(
            child: _tabButton(
              context: context,
              label: 'Drafts',
              badgeCount: draftCount,
              isActive: activeTab == 'drafts',
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CollegeBroadcastBloc>().add(const ChangeBroadcastTabEvent('drafts'));
              },
              screenWidth: screenWidth,
            ),
          ),
          Expanded(
            child: _tabButton(
              context: context,
              label: 'Batch Groups',
              isActive: activeTab == 'batches',
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<CollegeBroadcastBloc>().add(const ChangeBroadcastTabEvent('batches'));
              },
              screenWidth: screenWidth,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required BuildContext context,
    required String label,
    int? badgeCount,
    required bool isActive,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. Key Metrics Summary Cards
  // ===========================================================================
  Widget _buildKeyMetrics(BuildContext context, double screenWidth, BroadcastCenterData data) {
    final isMock = data.isMock;
    final asterisk = isMock ? ' *' : '';

    final totalSentCard = _buildMetricCard(
      context: context,
      icon: LucideIcons.upload,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primary,
      badgeText: 'TOTAL SENT',
      badgeBg: AppColors.primary,
      badgeTextColor: Colors.white,
      value: '${data.totalSent.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}$asterisk',
      caption: 'Broadcasts this semester',
      screenWidth: screenWidth,
    );

    final avgOpenRateCard = _buildMetricCard(
      context: context,
      icon: LucideIcons.eye,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primary,
      badgeText: 'AVG OPEN RATE',
      badgeBg: AppColors.primaryLight,
      badgeTextColor: AppColors.primary,
      value: '${data.avgOpenRate.toStringAsFixed(1)}%$asterisk',
      caption: '+4.2% from last month',
      captionColor: const Color(0xFF059669),
      screenWidth: screenWidth,
    );

    final urgentPendingCard = _buildMetricCard(
      context: context,
      icon: LucideIcons.alertTriangle,
      iconBg: const Color(0xFFFFE4E6),
      iconColor: const Color(0xFFE11D48),
      badgeText: 'URGENT PENDING',
      badgeBg: const Color(0xFFFFE4E6),
      badgeTextColor: const Color(0xFFE11D48),
      value: '${data.urgentPending.toString().padLeft(2, '0')}$asterisk',
      caption: 'Requiring immediate action',
      captionColor: AppColors.textSecondary,
      isUrgentBorder: true,
      screenWidth: screenWidth,
    );

    if (screenWidth >= 600) {
      return Row(
        children: [
          Expanded(child: totalSentCard),
          const SizedBox(width: 10),
          Expanded(child: avgOpenRateCard),
          const SizedBox(width: 10),
          Expanded(child: urgentPendingCard),
        ],
      );
    }

    return Column(
      children: [
        totalSentCard,
        const SizedBox(height: 10),
        avgOpenRateCard,
        const SizedBox(height: 10),
        urgentPendingCard,
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required String value,
    required String caption,
    Color? captionColor,
    bool isUrgentBorder = false,
    required double screenWidth,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUrgentBorder ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isUrgentBorder ? const Color(0xFFFDA4AF) : AppColors.border,
          width: isUrgentBorder ? 1.5 : 0.8,
        ),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.026, 9.5, 10.5),
                    fontWeight: FontWeight.w800,
                    color: badgeTextColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.060, 19.0, 24.0),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.5),
              fontWeight: FontWeight.w500,
              color: captionColor ?? AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. Broadcast Feed Panel (All Broadcasts) - Generous Dimensions, Zero Truncation
  // ===========================================================================
  Widget _buildBroadcastsFeed(
    BuildContext context,
    double screenWidth,
    List<BroadcastLogItem> items,
    bool isMock,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: 'No Broadcasts Found',
        message: 'No broadcast messages match your search. Try another keyword or compose a new broadcast.',
        screenWidth: screenWidth,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Broadcast Log',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.040, 15.0, 16.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${items.length} Records',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) {
            final item = items[idx];
            return _buildBroadcastItemCard(context, item, screenWidth, isMock);
          },
        ),
      ],
    );
  }

  Widget _buildBroadcastItemCard(
    BuildContext context,
    BroadcastLogItem item,
    double screenWidth,
    bool isMock,
  ) {
    final isMegaphone = item.type == BroadcastType.megaphone;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showBroadcastDetailModal(context, item);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier 1: Icon + Title + Status Badges (Uncrowded)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isMegaphone ? AppColors.primaryLight : AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isMegaphone ? LucideIcons.megaphone : LucideIcons.fileText,
                      size: 20,
                      color: isMegaphone ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.title}${item.isMock ? " *" : ""}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (item.isUrgent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E6),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'SENT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF059669),
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
              const SizedBox(height: 10),

              // Tier 2: Message Snippet (Full Width, Generous Line Height)
              Text(
                item.snippet,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Tier 3: Metadata Row (Target Audience + Date Sent)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.users, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.targetAudience,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendar, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          item.dateSent,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tier 4: Read Receipts Progress & Trailing CTA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Read Receipts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.readCount} / ${item.totalCount} (${item.readPercentage}%)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.totalCount > 0 ? (item.readCount / item.totalCount).clamp(0.0, 1.0) : 0,
                        minHeight: 6,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. Drafts Panel - Generous Card Dimensions
  // ===========================================================================
  Widget _buildDraftsList(
    BuildContext context,
    double screenWidth,
    List<BroadcastLogItem> drafts,
    bool isMock,
  ) {
    if (drafts.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: 'No Saved Drafts',
        message: 'No draft messages saved. Click "New Broadcast" to compose a message and save as draft.',
        screenWidth: screenWidth,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Broadcast Drafts',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.040, 15.0, 16.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${drafts.length} Pending Drafts',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: drafts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) {
            final draft = drafts[idx];
            return _buildDraftCard(context, draft, screenWidth, isMock);
          },
        ),
      ],
    );
  }

  Widget _buildDraftCard(
    BuildContext context,
    BroadcastLogItem draft,
    double screenWidth,
    bool isMock,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.fileText, size: 20, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${draft.title}${draft.isMock ? " *" : ""}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.snippet,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border, width: 0.6),
                          ),
                          child: Text(
                            'Audience: ${draft.targetAudience}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border, width: 0.6),
                          ),
                          child: Text(
                            draft.dateSent,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
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
          Row(
            children: [
              Expanded(
                child: BouncyButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CollegeBroadcastBloc>().add(PublishDraftEvent(draft));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.send, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Send Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BouncyButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<CollegeBroadcastBloc>().add(DeleteDraftEvent(draft.id));
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. Batch Groups Grid Panel
  // ===========================================================================
  Widget _buildBatchGroupsGrid(
    BuildContext context,
    double screenWidth,
    List<BatchGroupItem> groups,
    bool isMock,
  ) {
    if (groups.isEmpty) {
      return _buildEmptyState(
        context: context,
        title: 'No Batch Groups Found',
        message: 'No batch groups match your search query.',
        screenWidth: screenWidth,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Batch Audiences',
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.040, 15.0, 16.5),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, idx) {
            final group = groups[idx];
            return _buildBatchGroupCard(context, group, screenWidth, isMock);
          },
        ),
      ],
    );
  }

  Widget _buildBatchGroupCard(
    BuildContext context,
    BatchGroupItem group,
    double screenWidth,
    bool isMock,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${group.memberCount} MEMBERS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${group.name}${group.isMock ? " *" : ""}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      group.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.0),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.users, size: 20, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1, thickness: 0.8),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Coordinator: ${group.coordinator}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BouncyButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showComposeModal(context, presetAudience: group.name);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.send, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'New Message',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Empty State Widget
  // ===========================================================================
  Widget _buildEmptyState({
    required BuildContext context,
    required String title,
    required String message,
    required double screenWidth,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          Lottie.asset('assets/lottie/empty_state.json', width: 100, height: 100),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.038, 14.0, 16.0),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Compose Modal / Bottom Sheet (Smooth Keyboard Avoidance)
  // ===========================================================================
  void _showComposeModal(BuildContext parentContext, {String? presetAudience}) {
    HapticFeedback.lightImpact();
    final bloc = parentContext.read<CollegeBroadcastBloc>();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ComposeModalSheet(
        presetAudience: presetAudience,
        onSend: (title, body, audience, isUrgent) {
          final recipients = _estimateRecipients(audience);
          bloc.add(SendBroadcastEvent(
            title: title,
            body: body,
            targetAudience: audience,
            isUrgent: isUrgent,
            recipientCount: recipients,
          ));
        },
        onSaveDraft: (title, body, audience, isUrgent) {
          final recipients = _estimateRecipients(audience);
          bloc.add(SaveDraftEvent(
            title: title,
            body: body,
            targetAudience: audience,
            isUrgent: isUrgent,
            recipientCount: recipients,
          ));
        },
      ),
    );
  }

  // ===========================================================================
  // Broadcast Detail / Read Receipts Modal
  // ===========================================================================
  void _showBroadcastDetailModal(BuildContext context, BroadcastLogItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _BroadcastDetailSheet(item: item),
    );
  }

  void _handleNav(int i) {
    switch (i) {
      case 0:
        context.go('/college/dashboard');
        break;
      case 1:
        context.go('/college/reports');
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

// =============================================================================
// COMPOSE MODAL BOTTOM SHEET
// =============================================================================
class _ComposeModalSheet extends StatefulWidget {
  final String? presetAudience;
  final void Function(String title, String body, String audience, bool isUrgent) onSend;
  final void Function(String title, String body, String audience, bool isUrgent) onSaveDraft;

  const _ComposeModalSheet({
    this.presetAudience,
    required this.onSend,
    required this.onSaveDraft,
  });

  @override
  State<_ComposeModalSheet> createState() => _ComposeModalSheetState();
}

class _ComposeModalSheetState extends State<_ComposeModalSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _targetAudience = 'CS & IT 2024 Batch';
  bool _isUrgent = false;

  final List<String> _audienceOptions = const [
    'CS & IT 2024 Batch',
    'All Final Years',
    'Electronics 2024 Batch',
    'Corporate Recruiters & HRs',
    'All Students',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.presetAudience != null && widget.presetAudience!.trim().isNotEmpty) {
      _targetAudience = widget.presetAudience!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: viewInsetsBottom > 0 ? viewInsetsBottom + 16 : (bottomPadding == 0 ? 20 : bottomPadding + 10),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.send, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Compose New Broadcast',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 1, thickness: 0.8),
            const SizedBox(height: 14),

            // Title Field
            Text(
              'Broadcast Subject / Title *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: TextField(
                controller: _titleController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Google Recruitment Drive - Preliminary Shortlist',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Target Audience & Priority Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Audience Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Audience',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _audienceOptions.contains(_targetAudience) ? _targetAudience : _audienceOptions.first,
                            isExpanded: true,
                            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
                            items: _audienceOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(
                                  opt,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _targetAudience = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Priority Toggle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Priority Flag',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: BouncyButton(
                              onPressed: () => setState(() => _isUrgent = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isUrgent ? AppColors.primaryLight : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: !_isUrgent ? AppColors.primary : AppColors.border,
                                    width: 0.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Normal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: !_isUrgent ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: BouncyButton(
                              onPressed: () => setState(() => _isUrgent = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isUrgent ? const Color(0xFFFFE4E6) : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isUrgent ? const Color(0xFFE11D48) : AppColors.border,
                                    width: 0.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Urgent',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isUrgent ? const Color(0xFFE11D48) : AppColors.textSecondary,
                                  ),
                                ),
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

            // Message Body Textarea
            Text(
              'Message Body *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: TextField(
                controller: _bodyController,
                maxLines: 4,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write message details for the selected student or recruiter audience...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Action CTAs: Save as Draft & Send Broadcast
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subject/Title is required to save draft')),
                        );
                        return;
                      }
                      widget.onSaveDraft(
                        _titleController.text.trim(),
                        _bodyController.text.trim(),
                        _targetAudience,
                        _isUrgent,
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save as Draft',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BouncyButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Both title and message body are required')),
                        );
                        return;
                      }
                      widget.onSend(
                        _titleController.text.trim(),
                        _bodyController.text.trim(),
                        _targetAudience,
                        _isUrgent,
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.send, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Send Broadcast',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
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
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BROADCAST DETAIL MODAL SHEET
// =============================================================================
class _BroadcastDetailSheet extends StatelessWidget {
  final BroadcastLogItem item;

  const _BroadcastDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding == 0 ? 20 : bottomPadding + 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.megaphone, size: 16, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Broadcast Log Detail',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(color: AppColors.border, height: 1, thickness: 0.8),
            const SizedBox(height: 12),

            Text(
              'SUBJECT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUDIENCE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.targetAudience,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DATE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.dateSent,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'MESSAGE CONTENT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.fullBody.isNotEmpty ? item.fullBody : item.snippet,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Read Receipt Progress',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${item.readPercentage}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: item.totalCount > 0 ? (item.readCount / item.totalCount).clamp(0.0, 1.0) : 0,
                minHeight: 8,
                backgroundColor: AppColors.inputFill,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${item.readCount} of ${item.totalCount} recipients read',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
