import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/recruiter_settings_bloc.dart';
import '../../bloc/recruiter_settings_event.dart';
import '../../bloc/recruiter_settings_state.dart';
import '../../data/models/recruiter_settings_model.dart';
import '../widgets/recruiter_side_nav.dart';

/// 1:1 Parity with Website RecruiterLayout.tsx PENDING Status Review Screen:
/// Displays "Company Profile Under Admin Review" with submitted credentials summary,
/// live MongoDB Atlas data integration, mock indicator asterisks, and zero truncation.
class CompanyProfileAdminReviewPage extends StatelessWidget {
  const CompanyProfileAdminReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecruiterSettingsBloc()..add(const FetchRecruiterSettingsEvent()),
      child: const _CompanyProfileAdminReviewView(),
    );
  }
}

class _CompanyProfileAdminReviewView extends StatefulWidget {
  const _CompanyProfileAdminReviewView();

  @override
  State<_CompanyProfileAdminReviewView> createState() => _CompanyProfileAdminReviewViewState();
}

class _CompanyProfileAdminReviewViewState extends State<_CompanyProfileAdminReviewView>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _setLocalStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('c2c_verification_status', status);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final horizontalPadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const RecruiterSideNav(highlightRoute: '/recruiter/admin-review'),
      appBar: _buildAppBar(context, screenWidth),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<RecruiterSettingsBloc, RecruiterSettingsState>(
          listener: (context, state) {
            if (state is RecruiterSettingsLoaded && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.successMessage!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                  backgroundColor: AppColors.cardDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecruiterSettingsLoading || state is RecruiterSettingsInitial) {
              return _buildLoadingSkeleton(horizontalPadding);
            }

            if (state is RecruiterSettingsError) {
              return _buildErrorView(context, state.message, horizontalPadding);
            }

            if (state is RecruiterSettingsLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryPurple,
                onRefresh: () async {
                  HapticFeedback.lightImpact();
                  context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 16.0,
                    bottom: bottomInset > 0 ? bottomInset + 20.0 : 28.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Top Informational Notice
                      _buildTopNotice(state.settings, screenWidth),
                      const SizedBox(height: 16),

                      // 2. Main Admin Review Hero Card (1:1 with RecruiterLayout.tsx)
                      RepaintBoundary(
                        child: _buildAdminReviewHeroCard(context, state.settings, screenWidth),
                      ),
                      const SizedBox(height: 18),

                      // 3. Submitted Credentials Detailed Summary Card
                      RepaintBoundary(
                        child: _buildSubmittedCredentialsCard(context, state.settings, screenWidth),
                      ),
                      const SizedBox(height: 18),

                      // 4. Review Process Timeline & Checklist
                      RepaintBoundary(
                        child: _buildReviewTimelineCard(state.settings, screenWidth),
                      ),
                      const SizedBox(height: 18),

                      // 5. Admin Simulation Quick Switcher (Live Test Demo Tools)
                      _buildAdminSimulationSwitcher(context, state.settings, screenWidth),
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

  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    final titleFontSize = clampDouble(screenWidth * 0.046, 16.0, 19.0);

    return AppBar(
      backgroundColor: AppColors.cardSurface,
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
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
            ),
            child: const Icon(
              LucideIcons.shieldCheck,
              color: Color(0xFFD97706),
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
                      'Admin Review',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    BlocBuilder<RecruiterSettingsBloc, RecruiterSettingsState>(
                      builder: (context, state) {
                        if (state is RecruiterSettingsLoaded && state.isMock) {
                          return Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.lightLavender,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '*',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                const Text(
                  'Company Verification Status',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          padding: const EdgeInsets.all(6),
          icon: const Icon(LucideIcons.refreshCw, size: 18, color: AppColors.textSecondary),
          onPressed: () {
            HapticFeedback.selectionClick();
            context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
          },
          tooltip: 'Sync real-time verification status',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- Top Notice Banner ---
  Widget _buildTopNotice(RecruiterSettingsModel settings, double screenWidth) {
    final isVerified = settings.isVerified;
    final isPending = settings.verificationStatus.toUpperCase() == 'PENDING';

    final bgColor = isVerified
        ? const Color(0xFFECFDF5)
        : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));
    final borderColor = isVerified
        ? const Color(0xFFA7F3D0)
        : (isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECACA));
    final iconColor = isVerified
        ? const Color(0xFF059669)
        : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626));
    final textColor = isVerified
        ? const Color(0xFF065F46)
        : (isPending ? const Color(0xFF92400E) : const Color(0xFF991B1B));

    final noticeTitle = isVerified
        ? 'Corporate Profile Verified'
        : (isPending ? 'Verification Under Review' : 'Profile Unverified');
    final noticeDesc = isVerified
        ? 'Your organization is approved to post jobs and access student pipelines.'
        : (isPending
            ? 'Administrator is validating your legal entity and credentials.'
            : 'Please complete your company profile to submit for admin approval.');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVerified
                  ? LucideIcons.checkCircle2
                  : (isPending ? LucideIcons.clock : LucideIcons.alertTriangle),
              size: 16,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noticeTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  noticeDesc,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Admin Review Hero Card (1:1 with RecruiterLayout.tsx lines 109-156) ---
  Widget _buildAdminReviewHeroCard(
    BuildContext context,
    RecruiterSettingsModel settings,
    double screenWidth,
  ) {
    final isVerified = settings.isVerified;
    final isPending = settings.verificationStatus.toUpperCase() == 'PENDING';

    final headerFontSize = clampDouble(screenWidth * 0.050, 17.0, 21.0);
    final bodyFontSize = clampDouble(screenWidth * 0.033, 12.0, 13.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified
              ? const Color(0xFFA7F3D0)
              : (isPending ? const Color(0xFFFDE68A) : AppColors.border),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top Gradient Bar
            Container(
              height: 4.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVerified
                      ? [const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFF10B981)]
                      : [const Color(0xFFF59E0B), const Color(0xFFEA580C), const Color(0xFFF59E0B)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  // Animated Clock / Shield Avatar Box
                  ScaleTransition(
                    scale: isPending ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isVerified
                              ? LucideIcons.shieldCheck
                              : (isPending ? LucideIcons.clock : LucideIcons.lock),
                          size: 34,
                          color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFCD34D),
                        width: 0.9,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isVerified
                              ? '✓ VERIFIED CORPORATE ACCOUNT'
                              : (isPending
                                  ? '⏳ PENDING ADMIN VERIFICATION'
                                  : '⚠️ UNVERIFIED ONBOARDING'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isVerified ? const Color(0xFF047857) : const Color(0xFF92400E),
                            letterSpacing: 0.4,
                          ),
                        ),
                        if (settings.isMock) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Main Title (Readable without truncation)
                  Text(
                    isVerified
                        ? 'Company Profile Verified'
                        : (isPending
                            ? 'Company Profile Under Admin Review'
                            : 'Company Verification Required'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description Paragraph
                  Text(
                    isVerified
                        ? 'Your company details have been thoroughly verified by Campus2Corporate Administrator. Core profile data is protected for institutional compliance.'
                        : (isPending
                            ? 'Your company details have been submitted. An administrator is currently reviewing your credentials. You can access Settings and Notifications while review is in progress.'
                            : 'You must complete your Company Profile in Settings and submit for Admin Verification before using recruiter candidate tools. You can view your notifications while unverified.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigation Action Buttons (1:1 with Web buttons)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Button 1: Notifications & Messages
                      OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push('/recruiter/messages');
                        },
                        icon: const Icon(LucideIcons.messageSquare, size: 15),
                        label: const Text('Notifications & Messages'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF92400E),
                          backgroundColor: const Color(0xFFFFFBEB),
                          side: const BorderSide(color: Color(0xFFFDE68A), width: 0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),

                      // Button 2: View / Edit Company Profile
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.push('/recruiter/settings');
                        },
                        icon: Icon(isVerified ? LucideIcons.eye : LucideIcons.building, size: 15),
                        label: Text(isVerified ? 'View Company Profile' : 'Edit Company Profile'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.cardDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Submitted Credentials Summary Card (1:1 with Web RecruiterLayout.tsx) ---
  Widget _buildSubmittedCredentialsCard(
    BuildContext context,
    RecruiterSettingsModel settings,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Logo Preview
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  image: settings.logoUrl != null && settings.logoUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(settings.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: settings.logoUrl == null || settings.logoUrl!.isEmpty
                    ? Center(
                        child: Text(
                          settings.companyName.isNotEmpty
                              ? settings.companyName[0].toUpperCase()
                              : 'L',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SUBMITTED CREDENTIALS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      settings.companyName.isNotEmpty
                          ? settings.companyName
                          : 'Lumina Nexus Tech Solutions',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
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

          // Detail Rows (Zero truncation)
          _buildDetailRow(
            label: 'Representative',
            value: settings.repName.isNotEmpty ? settings.repName : 'Alexander Wright',
            icon: LucideIcons.user,
          ),
          const SizedBox(height: 8),

          _buildDetailRow(
            label: 'Company Name',
            value: settings.companyName.isNotEmpty ? settings.companyName : 'Lumina Nexus Tech',
            icon: LucideIcons.building2,
          ),
          const SizedBox(height: 8),

          _buildDetailRow(
            label: 'Official Website',
            value: settings.websiteUrl.isNotEmpty ? settings.websiteUrl : 'https://luminanexus.com',
            icon: LucideIcons.globe,
            isLink: true,
          ),
          const SizedBox(height: 8),

          _buildDetailRow(
            label: 'Submitted Date',
            value: settings.submittedAt != null && settings.submittedAt!.isNotEmpty
                ? settings.submittedAt!
                : 'Recently Submitted',
            icon: LucideIcons.calendar,
          ),

          if (settings.aboutCompany.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.7),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Company',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.aboutCompany,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isLink ? AppColors.primaryPurple : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // --- Review Process Timeline Card ---
  Widget _buildReviewTimelineCard(RecruiterSettingsModel settings, double screenWidth) {
    final isVerified = settings.isVerified;
    final isPending = settings.verificationStatus.toUpperCase() == 'PENDING';

    final steps = [
      {
        'title': 'Corporate Profile Submitted',
        'desc': 'Company identity, website, representative, and logo captured.',
        'status': 'done',
      },
      {
        'title': 'Admin Identity & Domain Audit',
        'desc': 'Verification of official web domain match and company legitimacy.',
        'status': isVerified ? 'done' : (isPending ? 'current' : 'upcoming'),
      },
      {
        'title': 'Placement Access Activation',
        'desc': 'Full recruiter dashboard, candidate pipeline, and drive tools unlocked.',
        'status': isVerified ? 'done' : 'upcoming',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.listChecks, size: 16, color: AppColors.primaryPurple),
              SizedBox(width: 8),
              Text(
                'Verification Pipeline Stages',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isDone = step['status'] == 'done';
            final isCurrent = step['status'] == 'current';
            final isLast = idx == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF10B981)
                            : (isCurrent ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isDone
                              ? LucideIcons.check
                              : (isCurrent ? LucideIcons.clock : LucideIcons.circle),
                          size: 13,
                          color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: isDone ? const Color(0xFFA7F3D0) : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCurrent ? const Color(0xFF92400E) : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['desc']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // --- Admin Simulation Demo Controls (Live preview for development & demo) ---
  Widget _buildAdminSimulationSwitcher(
    BuildContext context,
    RecruiterSettingsModel settings,
    double screenWidth,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
              const Text(
                'Demo / Admin Verification Simulation',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightLavender,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Simulation',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Toggle verification state to test recruiter flow between Unfilled, Pending Review, and Verified states.',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 1. Simulate Pending
              InkWell(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await _setLocalStatus('PENDING');
                  if (context.mounted) {
                    context.read<RecruiterSettingsBloc>().add(
                          SaveRecruiterSettingsEvent(
                            repName: settings.repName.isNotEmpty
                                ? settings.repName
                                : 'Alexander Wright',
                            companyName: settings.companyName.isNotEmpty
                                ? settings.companyName
                                : 'Lumina Nexus Tech',
                            websiteUrl: settings.websiteUrl.isNotEmpty
                                ? settings.websiteUrl
                                : 'https://luminanexus.com',
                            aboutCompany: settings.aboutCompany.isNotEmpty
                                ? settings.aboutCompany
                                : 'Enterprise AI software and campus recruitment platform partner.',
                            logoUrl: settings.logoUrl,
                          ),
                        );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.clock, size: 12, color: Color(0xFFD97706)),
                      SizedBox(width: 4),
                      Text(
                        'Set PENDING',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Simulate Approve (VERIFIED)
              InkWell(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await _setLocalStatus('VERIFIED');
                  if (context.mounted) {
                    context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.checkCircle2, size: 12, color: Color(0xFF059669)),
                      SizedBox(width: 4),
                      Text(
                        'Simulate ADMIN APPROVE',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Simulate UNFILLED
              InkWell(
                onTap: () async {
                  HapticFeedback.selectionClick();
                  await _setLocalStatus('UNFILLED');
                  if (context.mounted) {
                    context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.rotateCcw, size: 12, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Reset UNFILLED',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
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

  // --- Loading Skeleton ---
  Widget _buildLoadingSkeleton(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  // --- Error View ---
  Widget _buildErrorView(BuildContext context, String message, double horizontalPadding) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 40, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Failed to Load Verification Status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent()),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
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
