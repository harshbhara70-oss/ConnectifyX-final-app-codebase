import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../bloc/mentor_settings_bloc.dart';
import '../../bloc/mentor_settings_event.dart';
import '../../bloc/mentor_settings_state.dart';
import '../../data/models/mentor_settings_model.dart';
import '../widgets/mentor_drawer.dart';
import '../widgets/settings_shimmer.dart';

/// System Settings Screen for Mentor Module
/// 1:1 Feature Parity with Web Frontend (src/pages/MentorDashboard.tsx Tab 11)
/// Audited for zero truncation, multi-line wrapping, dynamic font scaling via MediaQuery,
/// and live MongoDB Atlas preference synchronization without hardcoded overflow traps.
class MentorSettingsPage extends StatelessWidget {
  const MentorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MentorSettingsBloc()..add(const FetchMentorSettingsEvent()),
      child: const _MentorSettingsView(),
    );
  }
}

class _MentorSettingsView extends StatefulWidget {
  const _MentorSettingsView();

  @override
  State<_MentorSettingsView> createState() => _MentorSettingsViewState();
}

class _MentorSettingsViewState extends State<_MentorSettingsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showPasswordResetDialog(BuildContext context, String defaultEmail, double screenWidth) {
    HapticFeedback.mediumImpact();
    final emailController = TextEditingController(text: defaultEmail.isNotEmpty ? defaultEmail : 'sarah.jenkins@stripe.com');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        insetPadding: EdgeInsets.symmetric(
          horizontal: clampDouble(screenWidth * 0.06, 16.0, 28.0),
          vertical: 24.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.lock, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Password Reset Dispatch',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.042, 15.0, 17.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We will dispatch a secure validation reset link directly to your corporate inbox. Please verify authorization credentials below.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.032, 11.5, 13.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.034, 12.0, 13.5),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Target Corporate Email',
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.029, 10.5, 12.0),
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
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsOverflowButtonSpacing: 8,
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<MentorSettingsBloc>().add(RequestPasswordResetEvent(email));
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Dispatch Link',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isSmall = screenWidth < 360;

    return BlocConsumer<MentorSettingsBloc, MentorSettingsState>(
      listener: (context, state) {
        if (state is MentorSettingsLoaded && state.toastMessage != null) {
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
              duration: const Duration(milliseconds: 2600),
            ),
          );
        }
      },
      builder: (context, state) {
        final isMock = state is MentorSettingsLoaded ? state.settings.isMock : false;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          drawer: const MentorNavigationDrawer(currentRoute: '/mentor/settings'),
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
          Flexible(
            child: Text(
              'System Settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.046, 17.0, 19.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
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
    MentorSettingsState state,
    double screenWidth,
    bool isSmall,
  ) {
    if (state is MentorSettingsLoading) {
      return const SettingsShimmer();
    }

    if (state is MentorSettingsError) {
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
                  context.read<MentorSettingsBloc>().add(const FetchMentorSettingsEvent());
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

    if (state is MentorSettingsLoaded) {
      final s = state.settings;
      final bottomInset = MediaQuery.paddingOf(context).bottom;

      return RefreshIndicator(
        onRefresh: () async {
          context.read<MentorSettingsBloc>().add(const FetchMentorSettingsEvent(isRefresh: true));
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: 14,
            bottom: bottomInset == 0 ? 20.0 : bottomInset + 12.0,
            left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
            right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Action Toolbar in Body
              _buildActionToolbar(context, screenWidth),
              const SizedBox(height: 14),

              // 2. System Preferences Card (Toggles)
              _buildPreferencesCard(context, s, screenWidth),
              const SizedBox(height: 14),

              // 3. Regional & Cache Limits Configuration Card
              _buildRegionalConfigCard(context, s, screenWidth),
              const SizedBox(height: 14),

              // 4. Session & Automation Defaults Card
              _buildSessionAutomationCard(context, s, screenWidth),
              const SizedBox(height: 14),

              // 5. Security & Password Reset Card
              _buildSecurityPasswordCard(context, s, screenWidth),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 1. Body Action Toolbar
  Widget _buildActionToolbar(BuildContext context, double screenWidth) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<MentorSettingsBloc>().add(const ResetSettingsToDefaultsEvent());
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
                const Icon(LucideIcons.rotateCcw, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Reset to Defaults',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<MentorSettingsBloc>().add(
                    const FetchMentorSettingsEvent(isRefresh: true),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.refreshCw, size: 15, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Sync',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 11.5, 13.0),
                      fontWeight: FontWeight.w800,
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

  /// 2. System Preferences Card
  Widget _buildPreferencesCard(
    BuildContext context,
    MentorSettingsData s,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.045, 14.0, 18.0)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
              const Icon(LucideIcons.sliders, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Display & Notification Preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Force System Dark Mode
          _buildToggleRow(
            context: context,
            title: 'Force System Dark Mode',
            subtitle: 'Enforce high-contrast dark theme canvas.',
            value: s.darkMode,
            onChanged: (val) {
              context.read<MentorSettingsBloc>().add(
                    UpdateSettingToggleEvent(key: 'darkMode', value: val),
                  );
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // Message Push Alerts
          _buildToggleRow(
            context: context,
            title: 'Message Push Alerts',
            subtitle: 'Receive instant cues for assignment and feedback reviews.',
            value: s.pushAlerts,
            onChanged: (val) {
              context.read<MentorSettingsBloc>().add(
                    UpdateSettingToggleEvent(key: 'pushAlerts', value: val),
                  );
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // Private Profile Mode
          _buildToggleRow(
            context: context,
            title: 'Private Profile Mode',
            subtitle: 'Hide contact details from public recruiter search directories.',
            value: s.privacyMode,
            onChanged: (val) {
              context.read<MentorSettingsBloc>().add(
                    UpdateSettingToggleEvent(key: 'privacyMode', value: val),
                  );
            },
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  /// 3. Regional & Cache Limits Configuration Card
  Widget _buildRegionalConfigCard(
    BuildContext context,
    MentorSettingsData s,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.045, 14.0, 18.0)),
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
              const Icon(LucideIcons.globe, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Regional & Cache Configuration',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Alert Cache Limits Dropdown
          _buildDropdownRow(
            context: context,
            title: 'Alert Cache Limits',
            subtitle: 'Limit logs count displayed in header ticker dropdown.',
            value: s.alertsLimit,
            items: const ['5', '10', '25'],
            labels: const {'5': '5 Logs', '10': '10 Logs', '25': '25 Logs'},
            onChanged: (val) {
              if (val != null) {
                context.read<MentorSettingsBloc>().add(
                      UpdateSettingValueEvent(key: 'alertsLimit', value: val),
                    );
              }
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // System Language Dropdown
          _buildDropdownRow(
            context: context,
            title: 'System Language',
            subtitle: 'Preferred UI language across workspace portals.',
            value: s.systemLanguage,
            items: const ['English', 'Spanish', 'French', 'Hindi', 'German'],
            labels: const {
              'English': 'English (US)',
              'Spanish': 'Español',
              'French': 'Français',
              'Hindi': 'हिन्दी',
              'German': 'Deutsch',
            },
            onChanged: (val) {
              if (val != null) {
                context.read<MentorSettingsBloc>().add(
                      UpdateSettingValueEvent(key: 'systemLanguage', value: val),
                    );
              }
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // Email Digest Frequency
          _buildDropdownRow(
            context: context,
            title: 'Email Digest Frequency',
            subtitle: 'Frequency of automated mentee progress summaries.',
            value: s.emailDigest,
            items: const ['Immediate', 'Daily Digest', 'Weekly Summary'],
            labels: const {
              'Immediate': 'Real-time Instant',
              'Daily Digest': 'Daily Summary',
              'Weekly Summary': 'Weekly Digest',
            },
            onChanged: (val) {
              if (val != null) {
                context.read<MentorSettingsBloc>().add(
                      UpdateSettingValueEvent(key: 'emailDigest', value: val),
                    );
              }
            },
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  /// 4. Session & Automation Defaults Card
  Widget _buildSessionAutomationCard(
    BuildContext context,
    MentorSettingsData s,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.045, 14.0, 18.0)),
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
              const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Session & Automation Defaults',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Default Session Duration
          _buildDropdownRow(
            context: context,
            title: 'Default Session Duration',
            subtitle: 'Default time block reserved when scheduling meetings.',
            value: s.defaultSessionDuration,
            items: const ['30 min', '45 min', '60 min'],
            labels: const {
              '30 min': '30 Minutes',
              '45 min': '45 Minutes',
              '60 min': '60 Minutes',
            },
            onChanged: (val) {
              if (val != null) {
                context.read<MentorSettingsBloc>().add(
                      UpdateSettingValueEvent(key: 'defaultSessionDuration', value: val),
                    );
              }
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // Sound Effects Toggle
          _buildToggleRow(
            context: context,
            title: 'Audio Sound FX',
            subtitle: 'Play audio cues on evaluation submission & direct chat.',
            value: s.soundEffects,
            onChanged: (val) {
              context.read<MentorSettingsBloc>().add(
                    UpdateSettingToggleEvent(key: 'soundEffects', value: val),
                  );
            },
            screenWidth: screenWidth,
          ),
          const Divider(height: 20, color: AppColors.border),

          // Auto-lock Timeout
          _buildDropdownRow(
            context: context,
            title: 'Session Auto-Lock',
            subtitle: 'Inactivity interval before requiring re-authentication.',
            value: s.autoLockTimeout,
            items: const ['15 min', '30 min', 'Never'],
            labels: const {
              '15 min': '15 Minutes',
              '30 min': '30 Minutes',
              'Never': 'Disabled (Always On)',
            },
            onChanged: (val) {
              if (val != null) {
                context.read<MentorSettingsBloc>().add(
                      UpdateSettingValueEvent(key: 'autoLockTimeout', value: val),
                    );
              }
            },
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  /// 5. Security & Password Reset Card
  Widget _buildSecurityPasswordCard(
    BuildContext context,
    MentorSettingsData s,
    double screenWidth,
  ) {
    return Container(
      padding: EdgeInsets.all(clampDouble(screenWidth * 0.045, 14.0, 18.0)),
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
              const Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF059669)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Security & Authentication Safeguards',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: clampDouble(screenWidth * 0.038, 13.5, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // 2FA Security Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.key, size: 16, color: Color(0xFF059669)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Two-Factor Authentication (2FA)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.035, 12.5, 14.0),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Cryptographic session defense active.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.029, 10.5, 12.0),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Enabled',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Request Password Reset Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPasswordResetDialog(context, 'sarah.jenkins@stripe.com', screenWidth),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.lock, size: 15, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Request Password Reset Dispatch',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                        fontWeight: FontWeight.w800,
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
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.035, 12.5, 14.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: clampDouble(screenWidth * 0.029, 10.5, 12.0),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primary,
          activeThumbColor: Colors.white,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
        ),
      ],
    );
  }

  Widget _buildDropdownRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Map<String, String> labels,
    required Function(String?) onChanged,
    required double screenWidth,
  }) {
    final selectedVal = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.035, 12.5, 14.0),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: clampDouble(screenWidth * 0.029, 10.5, 12.0),
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedVal,
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSecondary),
              style: GoogleFonts.plusJakartaSans(
                fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              items: items.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(
                    labels[opt] ?? opt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
