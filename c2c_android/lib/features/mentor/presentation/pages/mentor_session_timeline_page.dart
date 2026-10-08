import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/session_timeline_bloc.dart';
import '../../bloc/session_timeline_event.dart';
import '../../bloc/session_timeline_state.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/mentor_drawer.dart';
import '../widgets/session_timeline_shimmer.dart';

extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return '';
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class MentorSessionTimelinePage extends StatelessWidget {
  const MentorSessionTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SessionTimelineBloc()..add(const FetchSessionTimelineEvent()),
      child: const _MentorSessionTimelineView(),
    );
  }
}

class _MentorSessionTimelineView extends StatefulWidget {
  const _MentorSessionTimelineView();

  @override
  State<_MentorSessionTimelineView> createState() => _MentorSessionTimelineViewState();
}

class _MentorSessionTimelineViewState extends State<_MentorSessionTimelineView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openScheduleSlotModal(BuildContext context, List<MentorStudentModel> availableStudents) {
    HapticFeedback.lightImpact();
    final bloc = context.read<SessionTimelineBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _ScheduleSlotBottomSheet(
        availableStudents: availableStudents,
        onSubmit: (newSession) {
          bloc.add(CreateSessionSlotEvent(newSession));
        },
      ),
    );
  }

  Future<void> _handleJoinRoom(BuildContext context, String meetingLink) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.tryParse(meetingLink);

    if (uri != null) {
      try {
        final canLaunch = await canLaunchUrl(uri);
        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(LucideIcons.link, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Room Link: $meetingLink',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Copy',
            textColor: AppColors.primaryLight,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: meetingLink));
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Clamped Typography
    final screenHeaderSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final sectionHeaderSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);
    final itemTitleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);
    final badgeSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    // Dynamic Safe Insets
    final bottomInset = MediaQuery.paddingOf(context).bottom == 0 ? 16.0 : MediaQuery.paddingOf(context).bottom;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.bg,
      drawer: const MentorNavigationDrawer(currentRoute: '/mentor/sessions'),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<SessionTimelineBloc, SessionTimelineState>(
          listener: (context, state) {
            if (state is SessionTimelineLoaded && state.feedbackMessage != null) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Row(
                    children: [
                      const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 18),
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
            if (state is SessionTimelineLoading || state is SessionTimelineInitial) {
              return const SessionTimelineShimmer();
            }

            if (state is SessionTimelineError) {
              return _buildErrorState(context, state.message, sectionHeaderSize, subtitleSize);
            }

            if (state is! SessionTimelineLoaded) {
              return const SizedBox.shrink();
            }

            final isMock = state.isMock;
            final todaySessionsCount = state.allSessions.where((s) => s.date.toLowerCase().contains('today')).length;
            final urgentAlertsCount = state.alerts.where((a) => !a.isResolved && a.status == 'urgent').length;

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
                  // 1. Top Navigation Bar & Screen Title (Zero Truncation, Simple *)
                  _buildHeaderBar(
                    context,
                    screenHeaderSize: screenHeaderSize,
                    subtitleSize: subtitleSize,
                    isMock: isMock,
                  ),
                  const SizedBox(height: 14),

                  // 2. Action Button (Below AppBar on Top of Body, 100% Overflow-Free)
                  _buildScheduleSlotButton(
                    context,
                    availableStudents: state.availableStudents,
                  ),
                  const SizedBox(height: 14),

                  // 3. Metric Summary Quick Counters
                  _buildSummaryMetrics(
                    context,
                    totalSessions: state.allSessions.length,
                    todaySessions: todaySessionsCount,
                    urgentAlerts: urgentAlertsCount,
                    badgeSize: badgeSize,
                  ),
                  const SizedBox(height: 16),

                  // 4. Session Category Filter Chips
                  _buildCategoryChips(
                    context,
                    state: state,
                    badgeSize: badgeSize,
                  ),
                  const SizedBox(height: 14),

                  // 5. Ultra-Professional Search Bar
                  _buildSearchBar(
                    context,
                    itemTitleSize: itemTitleSize,
                    subtitleSize: subtitleSize,
                  ),
                  const SizedBox(height: 18),

                  // 6. Sequential Session Tracker Timeline
                  RepaintBoundary(
                    child: _buildSessionTimelineSection(
                      context,
                      state: state,
                      sectionHeaderSize: sectionHeaderSize,
                      itemTitleSize: itemTitleSize,
                      subtitleSize: subtitleSize,
                      badgeSize: badgeSize,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 7. Action Priority Queue (Operational Warnings & Task Alerts)
                  RepaintBoundary(
                    child: _buildActionPriorityQueue(
                      context,
                      alerts: state.alerts,
                      sectionHeaderSize: sectionHeaderSize,
                      subtitleSize: subtitleSize,
                      badgeSize: badgeSize,
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

        // Title and Subtitle with Shorter Synonym
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Session Timeline',
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
                'Sequential Schedule*',
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

  // --- Full-Width Schedule Slot Button (Below AppBar on Top of Body) ---
  Widget _buildScheduleSlotButton(
    BuildContext context, {
    required List<MentorStudentModel> availableStudents,
  }) {
    return InkWell(
      onTap: () => _openScheduleSlotModal(context, availableStudents),
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
            const Icon(LucideIcons.calendarPlus, color: Colors.white, size: 17),
            const SizedBox(width: 8),
            Text(
              'Schedule Session Slot*',
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

  // --- Metric Summary Quick Counters (Spacious, MediaQuery Powered, Zero Truncation) ---
  Widget _buildSummaryMetrics(
    BuildContext context, {
    required int totalSessions,
    required int todaySessions,
    required int urgentAlerts,
    required double badgeSize,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = clampDouble(screenWidth * 0.46, 155.0, 205.0);

    return SizedBox(
      height: 106,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSpaciousStatCard(
            context,
            width: cardWidth,
            label: 'Total Booked*',
            value: '$totalSessions*',
            sublabel: 'Pipeline sessions',
            icon: LucideIcons.calendar,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            badgeSize: badgeSize,
          ),
          const SizedBox(width: 10),
          _buildSpaciousStatCard(
            context,
            width: cardWidth,
            label: "Today's Calls*",
            value: '$todaySessions*',
            sublabel: 'Active check-ins',
            icon: LucideIcons.clock,
            iconColor: const Color(0xFF0D9488),
            iconBg: const Color(0xFFCCFBF1),
            badgeSize: badgeSize,
          ),
          const SizedBox(width: 10),
          _buildSpaciousStatCard(
            context,
            width: cardWidth,
            label: 'Action Queue*',
            value: '$urgentAlerts*',
            sublabel: 'Pending alerts',
            icon: LucideIcons.alertTriangle,
            iconColor: urgentAlerts > 0 ? AppColors.error : AppColors.warning,
            iconBg: urgentAlerts > 0 ? AppColors.errorLight : AppColors.warningLight,
            badgeSize: badgeSize,
          ),
        ],
      ),
    );
  }

  Widget _buildSpaciousStatCard(
    BuildContext context, {
    required double width,
    required String label,
    required String value,
    required String sublabel,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required double badgeSize,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.txtPrimary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                softWrap: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                  color: context.txtPrimary,
                ),
              ),
              Text(
                sublabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: badgeSize,
                  fontWeight: FontWeight.w500,
                  color: context.txtMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Category Filter Chips ---
  Widget _buildCategoryChips(
    BuildContext context, {
    required SessionTimelineLoaded state,
    required double badgeSize,
  }) {
    final categories = ['All', 'Resume Review', 'Mock Interview', 'Career Guidance', 'Technical Check-in'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = state.selectedCategory.toLowerCase() == cat.toLowerCase();
          final count = cat == 'All'
              ? state.allSessions.length
              : state.allSessions.where((s) => s.type.toLowerCase().trim() == cat.toLowerCase().trim()).length;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<SessionTimelineBloc>().add(FilterSessionCategoryEvent(cat));
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
                      cat,
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
                        color: isSelected ? Colors.white.withValues(alpha: 0.25) : context.surfAlt,
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

  // --- Ultra-Professional Search Bar ---
  Widget _buildSearchBar(
    BuildContext context, {
    required double itemTitleSize,
    required double subtitleSize,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(LucideIcons.search, size: 17, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (val) {
                context.read<SessionTimelineBloc>().add(SearchSessionsEvent(val));
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: itemTitleSize,
                fontWeight: FontWeight.w500,
                color: context.txtPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search by mentee, session type, time...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: context.txtMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _searchController.clear();
                context.read<SessionTimelineBloc>().add(const SearchSessionsEvent(''));
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  // --- Sequential Session Timeline Section ---
  Widget _buildSessionTimelineSection(
    BuildContext context, {
    required SessionTimelineLoaded state,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Sequential Session Timeline*',
                      softWrap: true,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.filteredSessions.length} Scheduled*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Interview Check-ins',
                softWrap: true,
                maxLines: 2,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: context.txtSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Session Cards List
          if (state.filteredSessions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.surfAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.calendar, size: 24, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No session slots match your search filter',
                    textAlign: TextAlign.center,
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.filteredSessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final session = state.filteredSessions[index];
                return _buildSessionCard(
                  context,
                  session: session,
                  itemTitleSize: itemTitleSize,
                  subtitleSize: subtitleSize,
                  badgeSize: badgeSize,
                );
              },
            ),
        ],
      ),
    );
  }

  // --- Session Timeline Item Card (Zero Overflow, Tiered Architecture) ---
  Widget _buildSessionCard(
    BuildContext context, {
    required MentorSessionModel session,
    required double itemTitleSize,
    required double subtitleSize,
    required double badgeSize,
  }) {
    final startTime = session.time.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier 1: Time Pill + Session Type + Options menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 0.8),
                ),
                child: Text(
                  '$startTime*',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${session.type.toTitleCase()}*',
                  softWrap: true,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: itemTitleSize,
                    fontWeight: FontWeight.w700,
                    color: context.txtPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.moreVertical, size: 16, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'cancel') {
                    HapticFeedback.lightImpact();
                    context.read<SessionTimelineBloc>().add(CancelSessionSlotEvent(session.id));
                  } else if (value == 'copy') {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: session.meetingLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: const Text('Meeting link copied to clipboard'),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.copy, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Copy Link*', style: GoogleFonts.plusJakartaSans(fontSize: 12.5)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        const Icon(LucideIcons.trash2, size: 15, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Cancel Slot*', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tier 2: Assigned Mentee (Full Width, Zero Truncation)
          Row(
            children: [
              const Icon(LucideIcons.userCheck, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Assigned: ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w500,
                  color: context.txtSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  '${session.studentName.toTitleCase()}*',
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w700,
                    color: context.txtPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tier 3: Meeting Time Window (Full Width, Zero Truncation)
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${session.time} • ${session.date}*',
                  softWrap: true,
                  maxLines: 2,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: context.txtSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Tier 4: Full-Width Join Room CTA (100% Overflow-Free)
          InkWell(
            onTap: () => _handleJoinRoom(context, session.meetingLink),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.playCircle, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Join Room*',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
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
    );
  }

  // --- Action Priority Queue (Operational Warnings & Alerts) ---
  Widget _buildActionPriorityQueue(
    BuildContext context, {
    required List<ActionPriorityItemModel> alerts,
    required double sectionHeaderSize,
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
          // Header Tier
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Action Priority Queue*',
                      softWrap: true,
                      maxLines: 2,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: sectionHeaderSize,
                        fontWeight: FontWeight.w700,
                        color: context.txtPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${alerts.where((a) => !a.isResolved).length} Alerts*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: badgeSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Active operational alerts',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w400,
                  color: context.txtSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alerts List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: alerts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final alert = alerts[idx];
              final isUrgent = alert.status == 'urgent';
              final isResolved = alert.isResolved;

              return InkWell(
                onTap: isResolved
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        context.read<SessionTimelineBloc>().add(ResolveAlertEvent(alert.id));
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: isResolved
                        ? context.surfAlt
                        : isUrgent
                            ? AppColors.errorLight.withValues(alpha: 0.6)
                            : AppColors.warningLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isResolved
                          ? context.brdr
                          : isUrgent
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.warning.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isResolved
                            ? LucideIcons.checkCircle2
                            : isUrgent
                                ? LucideIcons.alertOctagon
                                : LucideIcons.alertTriangle,
                        size: 16,
                        color: isResolved
                            ? AppColors.textMuted
                            : isUrgent
                                ? AppColors.error
                                : AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${alert.text}*',
                          softWrap: true,
                          maxLines: 2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isResolved
                                ? context.txtMuted
                                : isUrgent
                                    ? AppColors.error
                                    : const Color(0xFFB45309),
                            decoration: isResolved ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (!isResolved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isUrgent ? AppColors.error : AppColors.warning,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isUrgent ? 'URGENT*' : 'NOTICE*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
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
              'Failed to Load Sessions',
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
                context.read<SessionTimelineBloc>().add(const FetchSessionTimelineEvent());
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

// --- Schedule Slot Bottom Sheet Form with Butter-Smooth Keyboard Handling ---
class _ScheduleSlotBottomSheet extends StatefulWidget {
  final List<MentorStudentModel> availableStudents;
  final ValueChanged<MentorSessionModel> onSubmit;

  const _ScheduleSlotBottomSheet({
    required this.availableStudents,
    required this.onSubmit,
  });

  @override
  State<_ScheduleSlotBottomSheet> createState() => _ScheduleSlotBottomSheetState();
}

class _ScheduleSlotBottomSheetState extends State<_ScheduleSlotBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedStudent;
  String _selectedCategory = 'Resume Review';
  final TextEditingController _timeController = TextEditingController(text: '10:00 AM - 11:00 AM');
  String _selectedDay = 'Mon';
  final TextEditingController _dateController = TextEditingController(text: 'Today');
  final TextEditingController _linkController = TextEditingController(text: 'https://teams.microsoft.com/mock-link');

  @override
  void initState() {
    super.initState();
    if (widget.availableStudents.isNotEmpty) {
      _selectedStudent = widget.availableStudents.first.name;
    } else {
      _selectedStudent = 'Rahul Sharma';
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _dateController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final newSession = MentorSessionModel(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      studentName: _selectedStudent,
      type: _selectedCategory,
      time: _timeController.text.trim(),
      date: _dateController.text.trim(),
      day: _selectedDay,
      meetingLink: _linkController.text.trim().isNotEmpty
          ? _linkController.text.trim()
          : 'https://teams.microsoft.com/mock-link',
      isMock: true,
    );

    widget.onSubmit(newSession);
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendarPlus, size: 19, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Create Session Slot*',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: context.txtPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 19),
                      color: context.txtSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 1. Select Student Dropdown
                Text(
                  'SELECT MENTEE *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: context.txtSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surfAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.brdr, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStudent,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.txtPrimary,
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStudent = val);
                      },
                      items: (widget.availableStudents.isNotEmpty
                              ? widget.availableStudents.map((s) => s.name).toList()
                              : ['Rahul Sharma', 'Priya Singh', 'Anjali Gupta', 'Gaurav Verma', 'Divya Nair'])
                          .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(name.toTitleCase()),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Session Category Dropdown
                Text(
                  'SESSION CATEGORY *',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w700,
                    color: context.txtSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.surfAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.brdr, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.txtPrimary,
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                      items: const [
                        DropdownMenuItem(value: 'Resume Review', child: Text('Resume Review')),
                        DropdownMenuItem(value: 'Mock Interview', child: Text('Mock Interview')),
                        DropdownMenuItem(value: 'Career Guidance', child: Text('Career Guidance')),
                        DropdownMenuItem(value: 'Technical Check-in', child: Text('Technical Check-in')),
                        DropdownMenuItem(value: 'Portfolio Review', child: Text('Portfolio Review')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Meeting Time & Weekday
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildFormField(
                        context,
                        controller: _timeController,
                        label: 'TIME SLOT *',
                        hint: 'e.g. 10:00 AM - 11:00 AM',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter time' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAY *',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: context.txtSecondary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: context.surfAlt,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: context.brdr, width: 0.8),
                            ),
                            alignment: Alignment.center,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDay,
                                isExpanded: true,
                                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.txtPrimary,
                                ),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedDay = val);
                                },
                                items: const [
                                  DropdownMenuItem(value: 'Mon', child: Text('Mon')),
                                  DropdownMenuItem(value: 'Tue', child: Text('Tue')),
                                  DropdownMenuItem(value: 'Wed', child: Text('Wed')),
                                  DropdownMenuItem(value: 'Thu', child: Text('Thu')),
                                  DropdownMenuItem(value: 'Fri', child: Text('Fri')),
                                  DropdownMenuItem(value: 'Sat', child: Text('Sat')),
                                  DropdownMenuItem(value: 'Sun', child: Text('Sun')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. Date Label & Meeting Room Link
                _buildFormField(
                  context,
                  controller: _dateController,
                  label: 'DATE / WINDOW *',
                  hint: 'e.g. Today, Tomorrow, Oct 24',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter date' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  context,
                  controller: _linkController,
                  label: 'MEETING ROOM LINK',
                  hint: 'e.g. https://teams.microsoft.com/...',
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
                      'Schedule Session*',
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
            fontSize: 11.0,
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
