import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_profile_bloc.dart';
import '../../bloc/mentor_profile_event.dart';
import '../../bloc/mentor_profile_state.dart';
import '../../data/models/mentor_profile_model.dart';
import '../widgets/mentor_drawer.dart';
import '../widgets/profile_shimmer.dart';

/// Mentor Profile Screen
/// 1:1 Feature Parity with Web Frontend (src/pages/MentorDashboard.tsx Tab 10)
/// Audited for zero truncation, fluid multi-line wrapping, dynamic font scaling,
/// and real-time MongoDB Atlas synchronization.
class MentorProfilePage extends StatelessWidget {
  const MentorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorProfileBloc()..add(const FetchMentorProfileEvent()),
      child: const _MentorProfileView(),
    );
  }
}

class _MentorProfileView extends StatefulWidget {
  const _MentorProfileView();

  @override
  State<_MentorProfileView> createState() => _MentorProfileViewState();
}

class _MentorProfileViewState extends State<_MentorProfileView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditProfileModal(BuildContext context, MentorProfileData profile) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _EditProfileBottomSheet(
        profile: profile,
        onSave: (updated) {
          context.read<MentorProfileBloc>().add(UpdateMentorProfileEvent(updated));
        },
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Add Expertise Tag',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Distributed Systems, Kubernetes',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 0.8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = textController.text.trim();
              if (tag.isNotEmpty) {
                context.read<MentorProfileBloc>().add(AddExpertiseTagEvent(tag));
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Add Tag',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmall = screenWidth < 360;

    return BlocConsumer<MentorProfileBloc, MentorProfileState>(
      listener: (context, state) {
        if (state is MentorProfileLoaded && state.toastMessage != null) {
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
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(milliseconds: 2800),
            ),
          );
        }
      },
      builder: (context, state) {
        final isMock = state is MentorProfileLoaded ? state.profile.isMock : false;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          drawer: const MentorNavigationDrawer(currentRoute: '/mentor/profile'),
          appBar: _buildAppBar(context, isMock, screenWidth),
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
    bool isMock,
    double screenWidth,
  ) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(LucideIcons.menu, color: AppColors.textPrimary, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            Scaffold.of(ctx).openDrawer();
          },
        ),
      ),
      titleSpacing: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mentor Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.046, 17.0, 19.0),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (isMock) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
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
    MentorProfileState state,
    double screenWidth,
    bool isSmall,
  ) {
    if (state is MentorProfileLoading) {
      return const ProfileShimmer();
    }

    if (state is MentorProfileError) {
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
                  context.read<MentorProfileBloc>().add(const FetchMentorProfileEvent());
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

    if (state is MentorProfileLoaded) {
      final profile = state.profile;

      return RefreshIndicator(
        onRefresh: () async {
          context.read<MentorProfileBloc>().add(const FetchMentorProfileEvent(isRefresh: true));
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
              // 1. Mentor Identity Header Banner Card
              _buildIdentityHeaderCard(context, profile, screenWidth),
              const SizedBox(height: 14),

              // 2. Action Toolbar in Body
              _buildActionToolbar(context, profile, state.isSaving, screenWidth),
              const SizedBox(height: 14),

              // 3. Impact & Activity Metrics Row (4-Col Fluid Wrap)
              _buildImpactStatsGrid(context, profile, screenWidth),
              const SizedBox(height: 14),

              // 4. Availability Booking Ticker Card
              _buildAvailabilityCard(context, profile, screenWidth),
              const SizedBox(height: 14),

              // 5. Corporate & Contact Credentials Card (2x2 Grid)
              _buildCredentialsCard(context, profile, screenWidth),
              const SizedBox(height: 14),

              // 6. Domain Expertise & Skill Matrix Card
              _buildDomainExpertiseCard(context, profile, screenWidth),
              const SizedBox(height: 14),

              // 7. Executive Bio & Summary Card
              _buildExecutiveBioCard(context, profile, screenWidth),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 1. Identity Header Banner Card
  Widget _buildIdentityHeaderCard(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Avatar
              Stack(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile.avatar,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name, Role & Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.fullName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: clampDouble(screenWidth * 0.046, 16.5, 19.0),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.roleTitle} • ${profile.company}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rating Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                            '${profile.rating} Rating (Elite Mentor)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Department & Location Pill Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.shield, size: 13, color: AppColors.primary),
                    const SizedBox(width: 5),
                    Text(
                      'Dept: ${profile.department}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.mapPin, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      profile.location,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Body Action Toolbar
  Widget _buildActionToolbar(
    BuildContext context,
    MentorProfileData profile,
    bool isSaving,
    double screenWidth,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: isSaving ? null : () => _showEditProfileModal(context, profile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.edit3, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Edit Profile Credentials',
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
              context.read<MentorProfileBloc>().add(
                    const FetchMentorProfileEvent(isRefresh: true),
                  );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border, width: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.refreshCw, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Sync',
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

  /// 3. Core Impact & Activity Metrics Row
  Widget _buildImpactStatsGrid(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    final metrics = [
      {
        'icon': LucideIcons.users,
        'color': const Color(0xFF6366F1),
        'bg': const Color(0xFFECE6FE),
        'val': '${profile.activeMentees}',
        'lbl': 'Active Mentees',
      },
      {
        'icon': LucideIcons.calendar,
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFECFDF5),
        'val': '${profile.totalSessions}',
        'lbl': 'Sessions Held',
      },
      {
        'icon': LucideIcons.award,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'val': '${profile.totalEvaluations}',
        'lbl': 'Evaluations',
      },
      {
        'icon': LucideIcons.uploadCloud,
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFF3E8FF),
        'val': '${profile.totalResources}',
        'lbl': 'Materials',
      },
    ];

    return Row(
      children: metrics.map((m) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: m['bg'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(m['icon'] as IconData, size: 15, color: m['color'] as Color),
                ),
                const SizedBox(height: 6),
                Text(
                  m['val'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  m['lbl'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 4. Availability Booking Ticker Card
  Widget _buildAvailabilityCard(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    final isActive = profile.availabilitySwitch;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFECFDF5) : AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? LucideIcons.calendarCheck : LucideIcons.calendarX,
              size: 20,
              color: isActive ? const Color(0xFF059669) : AppColors.textMuted,
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
                        'Availability Booking Ticker',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: clampDouble(screenWidth * 0.036, 13.0, 14.5),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Paused',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isActive ? const Color(0xFF059669) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Allow assigned cohorts to schedule 1-on-1 mock reviews immediately.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.030, 10.5, 12.0),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isActive,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              context.read<MentorProfileBloc>().add(const ToggleAvailabilityEvent());
            },
          ),
        ],
      ),
    );
  }

  /// 5. Corporate & Contact Credentials Card (2x2 Grid)
  Widget _buildCredentialsCard(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.briefcase, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Corporate Credentials & Contact',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 2x2 Grid
          _buildCredentialRow(
            icon1: LucideIcons.mail,
            label1: 'CORPORATE EMAIL',
            val1: profile.email,
            icon2: LucideIcons.clock,
            label2: 'OFFICE HOURS',
            val2: profile.officeHours,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 14),
          _buildCredentialRow(
            icon1: LucideIcons.phone,
            label1: 'CONTACT NUMBER',
            val1: profile.phone,
            icon2: LucideIcons.globe,
            label2: 'BASE LOCATION',
            val2: profile.location,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Social Links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.linkedInUrl.isNotEmpty)
                _buildSocialBadge(
                  icon: LucideIcons.linkedin,
                  label: 'LinkedIn Verified',
                  color: const Color(0xFF0A66C2),
                  bg: const Color(0xFFEBF3FB),
                ),
              if (profile.githubUrl.isNotEmpty)
                _buildSocialBadge(
                  icon: LucideIcons.github,
                  label: 'GitHub Portal',
                  color: const Color(0xFF24292E),
                  bg: const Color(0xFFF3F4F6),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon1,
    required String label1,
    required String val1,
    required IconData icon2,
    required String label2,
    required String val2,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon1, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    label1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                val1,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon2, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    label2,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                val2,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Domain Expertise & Skill Matrix Card
  Widget _buildDomainExpertiseCard(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Domain Expertise & Vector Tags',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plusCircle, size: 18, color: AppColors.primary),
                onPressed: () => _showAddTagDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...profile.expertiseTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.read<MentorProfileBloc>().add(RemoveExpertiseTagEvent(tag));
                        },
                        child: const Icon(LucideIcons.x, size: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }),
              InkWell(
                onTap: () => _showAddTagDialog(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.plus, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Add Skill Tag',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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

  /// 7. Executive Bio & Summary Card
  Widget _buildExecutiveBioCard(
    BuildContext context,
    MentorProfileData profile,
    double screenWidth,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.fileText, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Executive Summary & Bio',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            profile.bio,
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.034, 12.5, 14.0),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Edit Profile Bottom Sheet with smooth keyboard avoidance
class _EditProfileBottomSheet extends StatefulWidget {
  final MentorProfileData profile;
  final Function(MentorProfileData updated) onSave;

  const _EditProfileBottomSheet({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _deptController;
  late TextEditingController _emailController;
  late TextEditingController _officeHoursController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _roleController = TextEditingController(text: widget.profile.roleTitle);
    _companyController = TextEditingController(text: widget.profile.company);
    _deptController = TextEditingController(text: widget.profile.department);
    _emailController = TextEditingController(text: widget.profile.email);
    _officeHoursController = TextEditingController(text: widget.profile.officeHours);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _locationController = TextEditingController(text: widget.profile.location);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _deptController.dispose();
    _emailController.dispose();
    _officeHoursController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
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
              'Edit Mentor Profile Credentials',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            _buildFormField(label: 'Full Name', controller: _nameController),
            _buildFormField(label: 'Corporate Role Title', controller: _roleController),
            _buildFormField(label: 'Company & Pipeline', controller: _companyController),
            _buildFormField(label: 'Department', controller: _deptController),
            _buildFormField(label: 'Corporate Email', controller: _emailController),
            _buildFormField(label: 'Office Hours', controller: _officeHoursController),
            _buildFormField(label: 'Phone Contact', controller: _phoneController),
            _buildFormField(label: 'Base Location', controller: _locationController),
            _buildFormField(label: 'Executive Bio', controller: _bioController, maxLines: 3),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final updated = widget.profile.copyWith(
                    fullName: _nameController.text.trim(),
                    roleTitle: _roleController.text.trim(),
                    company: _companyController.text.trim(),
                    department: _deptController.text.trim(),
                    email: _emailController.text.trim(),
                    officeHours: _officeHoursController.text.trim(),
                    phone: _phoneController.text.trim(),
                    location: _locationController.text.trim(),
                    bio: _bioController.text.trim(),
                  );
                  widget.onSave(updated);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  'Save Profile Credentials',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
