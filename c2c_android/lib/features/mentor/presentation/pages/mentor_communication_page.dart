import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_communication_bloc.dart';
import '../../bloc/mentor_communication_event.dart';
import '../../bloc/mentor_communication_state.dart';
import '../../data/models/mentor_communication_model.dart';
import '../../data/models/mentor_overview_model.dart';
import '../widgets/communication_shimmer.dart';
import '../widgets/mentor_drawer.dart';

/// Communication Hub Screen for Mentor Module
/// Complete 1:1 parity with web frontend (src/pages/MentorDashboard.tsx Tab 11 & Module 18)
/// Audited for ZERO ellipsis truncation across all mobile screen dimensions.
class MentorCommunicationPage extends StatelessWidget {
  const MentorCommunicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorCommunicationBloc()..add(const FetchCommunicationDataEvent()),
      child: const _CommunicationView(),
    );
  }
}

class _CommunicationView extends StatefulWidget {
  const _CommunicationView();

  @override
  State<_CommunicationView> createState() => _CommunicationViewState();
}

class _CommunicationViewState extends State<_CommunicationView> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isChatOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openChatWith(String targetName, bool isGroup) {
    HapticFeedback.lightImpact();
    context.read<MentorCommunicationBloc>().add(
          SelectChatTargetEvent(targetName: targetName, isGroup: isGroup),
        );
    setState(() {
      _isChatOpen = true;
    });
    _scrollToBottom();
  }

  void _closeChat() {
    HapticFeedback.lightImpact();
    setState(() {
      _isChatOpen = false;
    });
  }

  void _sendMessage(String targetName, bool isGroup) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<MentorCommunicationBloc>().add(
          SendChatMessageEvent(
            targetName: targetName,
            text: text,
            isGroup: isGroup,
          ),
        );
    _messageController.clear();
    _scrollToBottom();
  }

  void _showAddDialog(BuildContext context, CommunicationLoaded state) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _CreateActionModal(
        contacts: state.data.contacts,
        channels: state.data.channels,
        onStartChat: (studentName, initialMsg) {
          context.read<MentorCommunicationBloc>().add(
                StartDirectChatEvent(
                  studentName: studentName,
                  initialMessage: initialMsg,
                ),
              );
          setState(() {
            _isChatOpen = true;
          });
          _scrollToBottom();
        },
        onBroadcast: (title, content, category) {
          context.read<MentorCommunicationBloc>().add(
                CreateAnnouncementEvent(
                  title: title,
                  content: content,
                  category: category,
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

    return BlocConsumer<MentorCommunicationBloc, MentorCommunicationState>(
      listener: (context, state) {
        if (state is CommunicationLoaded && state.toastMessage != null) {
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
        final isMock = state is CommunicationLoaded ? state.data.isMock : true;

        return Scaffold(
          backgroundColor: AppColors.background,
          drawer: const MentorNavigationDrawer(currentRoute: '/mentor/communication'),
          appBar: _buildAppBar(context, screenWidth, isMock, state),
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
    MentorCommunicationState state,
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
              _isChatOpen && state is CommunicationLoaded
                  ? state.activeTarget
                  : 'Communication Hub',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.048, 16.0, 19.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (isMock && !_isChatOpen) ...[
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
      actions: [
        if (_isChatOpen)
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.textSecondary, size: 20),
            onPressed: _closeChat,
          )
        else
          const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: AppColors.border, height: 1.0),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    MentorCommunicationState state,
    double screenWidth,
    bool isSmall,
  ) {
    if (state is CommunicationLoading) {
      return const CommunicationShimmer();
    }

    if (state is CommunicationError) {
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
                  context.read<MentorCommunicationBloc>().add(const FetchCommunicationDataEvent());
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

    if (state is CommunicationLoaded) {
      if (_isChatOpen) {
        return _buildActiveChatView(context, state, screenWidth);
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<MentorCommunicationBloc>().add(
                const FetchCommunicationDataEvent(isRefresh: true),
              );
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
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
              // 1. Placement Victory Ticker Banner (Module 18)
              _buildPlacementVictoryBanner(context, state.data.successStory, screenWidth),
              const SizedBox(height: 14),

              // 2. Relocated Action Toolbar (Add Message / Broadcast & Refresh Feed)
              _buildActionToolbar(context, state, screenWidth),
              const SizedBox(height: 14),

              // 3. Ultra-professional Search Bar
              _buildSearchBar(context, screenWidth),
              const SizedBox(height: 14),

              // 4. View Switcher Chips (All, Direct Messages, Cohorts, Announcements)
              _buildCategoryFilterChips(context, state, screenWidth),
              const SizedBox(height: 16),

              // 5. Render Spacious, Zero-Truncation Content Cards
              _buildChannelContentLists(context, state, screenWidth, isSmall),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPlacementVictoryBanner(
    BuildContext context,
    PlacementSuccessStoryModel story,
    double screenWidth,
  ) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SUCCESS BANNER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.028, 9.5, 11.0),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFFECE6FE),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '🎉 Victory ticker shared to college portal!',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: const Color(0xFF059669),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.share2, size: 13, color: Color(0xFF4F46E5)),
                        const SizedBox(width: 5),
                        Text(
                          'Share',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              story.message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.5),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionToolbar(
    BuildContext context,
    CommunicationLoaded state,
    double screenWidth,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () => _showAddDialog(context, state),
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
                const Icon(LucideIcons.plusCircle, size: 17, color: Colors.white),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'New Chat / Broadcast',
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
              context.read<MentorCommunicationBloc>().add(
                    const FetchCommunicationDataEvent(isRefresh: true),
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
                    'Sync Feed',
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

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          context.read<MentorCommunicationBloc>().add(SearchCommunicationEvent(val));
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: clampDouble(screenWidth * 0.036, 13.0, 14.5),
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search mentees, cohorts, or keywords...',
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
                    context.read<MentorCommunicationBloc>().add(const SearchCommunicationEvent(''));
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

  Widget _buildCategoryFilterChips(
    BuildContext context,
    CommunicationLoaded state,
    double screenWidth,
  ) {
    final filters = [
      {'id': 'all', 'label': 'All Channels', 'count': state.data.contacts.length + state.data.channels.length},
      {'id': 'direct', 'label': 'Direct Messages', 'count': state.data.contacts.length},
      {'id': 'cohort', 'label': 'Cohorts', 'count': state.data.channels.length},
      {'id': 'announcements', 'label': 'Announcements', 'count': state.data.announcements.length},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = state.activeFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<MentorCommunicationBloc>().add(
                      FilterChannelTypeEvent(f['id'] as String),
                    );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f['label'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.032, 11.5, 12.5),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${f['count']}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
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

  Widget _buildChannelContentLists(
    BuildContext context,
    CommunicationLoaded state,
    double screenWidth,
    bool isSmall,
  ) {
    final showDirect = state.activeFilter == 'all' || state.activeFilter == 'direct';
    final showCohort = state.activeFilter == 'all' || state.activeFilter == 'cohort';
    final showAnnouncements = state.activeFilter == 'all' || state.activeFilter == 'announcements';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Direct Messages Section
        if (showDirect && state.filteredContacts.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Direct Mentorship Chats',
            count: state.filteredContacts.length,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = state.filteredContacts[index];
              return _buildSpaciousContactCard(contact, screenWidth);
            },
          ),
          const SizedBox(height: 16),
        ],

        // Cohort Workspaces Section
        if (showCohort && state.filteredChannels.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Cohort & Skill Workspaces',
            count: state.filteredChannels.length,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredChannels.length,
            itemBuilder: (context, index) {
              final channel = state.filteredChannels[index];
              return _buildSpaciousCohortCard(channel, screenWidth);
            },
          ),
          const SizedBox(height: 16),
        ],

        // Broadcast Announcements Section
        if (showAnnouncements && state.filteredAnnouncements.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Cohort Broadcasts & Bulletins',
            count: state.filteredAnnouncements.length,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredAnnouncements.length,
            itemBuilder: (context, index) {
              final ann = state.filteredAnnouncements[index];
              return _buildSpaciousAnnouncementCard(ann, screenWidth);
            },
          ),
        ],

        if (state.filteredContacts.isEmpty &&
            state.filteredChannels.isEmpty &&
            state.filteredAnnouncements.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(LucideIcons.messageSquare, size: 36, color: AppColors.textMuted),
                  const SizedBox(height: 10),
                  Text(
                    'No Matching Conversations',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try another keyword or start a new conversation.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required double screenWidth,
  }) {
    return Row(
      children: [
        Flexible(
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(10),
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

  /// Spacious Contact Card with ZERO truncation
  Widget _buildSpaciousContactCard(ChatContactModel contact, double screenWidth) {
    final avatarColor = Color(int.tryParse(contact.avatarBg) ?? 0xFF6366F1);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _openChatWith(contact.name, false),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Name + Online indicator + Timestamp
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: avatarColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              contact.avatar,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (contact.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    contact.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.0),
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.inputFill,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    contact.lastMessageTime,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: clampDouble(screenWidth * 0.029, 10.0, 11.5),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${contact.role} • ${contact.college}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Message Container with zero truncation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(LucideIcons.messageSquare, size: 14, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contact.lastMessage,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        if (contact.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${contact.unreadCount} new',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Spacious Cohort Card with ZERO truncation
  Widget _buildSpaciousCohortCard(CohortChannelModel channel, double screenWidth) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => _openChatWith(channel.name, true),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Hash icon + Name + Mentees count badge + Time
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    channel.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.0),
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${channel.memberCount} Mentees',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF059669),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              channel.topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Discussion Preview Box without truncation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(LucideIcons.users, size: 14, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            channel.lastMessage,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Spacious Announcement Card with ZERO truncation
  Widget _buildSpaciousAnnouncementCard(MentorAnnouncementModel ann, double screenWidth) {
    Color badgeBg;
    Color badgeTxt;
    if (ann.category.toLowerCase().contains('deadline')) {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTxt = const Color(0xFFDC2626);
    } else if (ann.category.toLowerCase().contains('workshop')) {
      badgeBg = const Color(0xFFECE6FE);
      badgeTxt = const Color(0xFF6366F1);
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTxt = const Color(0xFFD97706);
    }

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ann.category.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeTxt,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                ann.date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ann.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.040, 14.5, 16.0),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ann.content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.034, 12.5, 14.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChatView(
    BuildContext context,
    CommunicationLoaded state,
    double screenWidth,
  ) {
    final targetName = state.activeTarget;
    final isGroup = state.isGroupChannel;
    final messages = state.data.chatHistory[targetName] ?? [];

    return Column(
      children: [
        // Chat Header Subbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 22, color: AppColors.textPrimary),
                onPressed: _closeChat,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      isGroup ? 'Group Cohort Channel' : 'Direct Mentee Workspace',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ACTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Message stream list
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            itemCount: messages.length + (state.isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length && state.isTyping) {
                return _buildTypingIndicator();
              }
              final msg = messages[index];
              final isMentor = msg.sender == 'mentor';
              return _buildMessageBubble(msg, isMentor, screenWidth);
            },
          ),
        ),

        // Message Input Composer with smooth bottom padding
        _buildMessageComposer(targetName, isGroup, screenWidth),
      ],
    );
  }

  Widget _buildMessageBubble(
    ChatMessageModel msg,
    bool isMentor,
    double screenWidth,
  ) {
    return Align(
      alignment: isMentor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: screenWidth * 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMentor ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMentor ? 16 : 4),
            bottomRight: Radius.circular(isMentor ? 4 : 16),
          ),
          border: isMentor ? null : Border.all(color: AppColors.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMentor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMentor) ...[
              Text(
                msg.senderName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 3),
            ],
            Text(
              msg.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.036, 13.0, 14.5),
                fontWeight: FontWeight.w600,
                color: isMentor ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.timestamp,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isMentor ? const Color(0xFFECE6FE) : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'typing response...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(
    String targetName,
    bool isGroup,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.viewInsetsOf(context).bottom > 0
            ? 8
            : (MediaQuery.paddingOf(context).bottom == 0 ? 12.0 : MediaQuery.paddingOf(context).bottom + 4.0),
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 0.8),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.036, 13.0, 14.5),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(targetName, isGroup),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _sendMessage(targetName, isGroup),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.send, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet for starting a new direct mentorship chat or cohort announcement
class _CreateActionModal extends StatefulWidget {
  final List<ChatContactModel> contacts;
  final List<CohortChannelModel> channels;
  final Function(String studentName, String initialMsg) onStartChat;
  final Function(String title, String content, String category) onBroadcast;

  const _CreateActionModal({
    required this.contacts,
    required this.channels,
    required this.onStartChat,
    required this.onBroadcast,
  });

  @override
  State<_CreateActionModal> createState() => _CreateActionModalState();
}

class _CreateActionModalState extends State<_CreateActionModal> {
  int _selectedTab = 0; // 0: Direct Chat, 1: Broadcast

  // Tab 0 states
  String? _selectedStudent;
  final TextEditingController _initialMsgController = TextEditingController();

  // Tab 1 states
  final TextEditingController _broadcastTitleController = TextEditingController();
  final TextEditingController _broadcastContentController = TextEditingController();
  String _selectedCategory = 'Workshop';

  @override
  void initState() {
    super.initState();
    if (widget.contacts.isNotEmpty) {
      _selectedStudent = widget.contacts.first.name;
    }
  }

  @override
  void dispose() {
    _initialMsgController.dispose();
    _broadcastTitleController.dispose();
    _broadcastContentController.dispose();
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

            // Tab Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTab == 0
                              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Direct Message',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                            color: _selectedTab == 0 ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _selectedTab == 1
                              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cohort Broadcast',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                            color: _selectedTab == 1 ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            if (_selectedTab == 0) ...[
              // Direct Message Form
              Text(
                'Select Candidate',
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
                    value: _selectedStudent,
                    items: widget.contacts.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(
                          '${c.name} (${c.role})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStudent = val),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Initial Message',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _initialMsgController,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. Hi Rahul, let us review your React component architecture.',
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedStudent != null) {
                      widget.onStartChat(_selectedStudent!, _initialMsgController.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Open Workspace Chat',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ] else ...[
              // Broadcast Form
              Text(
                'Broadcast Title',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _broadcastTitleController,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'e.g. System Design Mock Rubrics Released',
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Category',
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
                    value: _selectedCategory,
                    items: ['Workshop', 'Deadline', 'Policy', 'Notice'].map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          cat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val ?? 'Workshop'),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Broadcast Content',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _broadcastContentController,
                maxLines: 3,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Provide complete details for mentees and cohorts...',
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _broadcastTitleController.text.trim();
                    final content = _broadcastContentController.text.trim();
                    if (title.isNotEmpty && content.isNotEmpty) {
                      widget.onBroadcast(title, content, _selectedCategory);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Post Cohort Broadcast',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
