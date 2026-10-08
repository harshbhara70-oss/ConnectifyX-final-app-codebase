import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/components/custom_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/widgets/bouncy_button.dart';
import '../../bloc/college_settings_bloc.dart';
import '../../domain/models/college_settings_model.dart';
import '../widgets/college_drawer.dart';

/// Redesigned College Settings Screen.
///
/// Strictly mirrors `src/pages/college/Settings.tsx` (1:1 feature parity):
/// 1. Header (Settings & institutional management subtitle)
/// 2. Account Information (Verified email, phone, name from live MongoDB `/college/profile`)
/// 3. Change Password (Current, New with strength meter, Confirm with mismatch alert, CTA)
/// 4. Two-Factor Authentication (SMS verification toggle + active/inactive status pill)
/// 5. Notification Preferences (Email, SMS alerts, Recruiter activity, Weekly digest, Drive reminders)
/// 6. Placement Cycle Configuration (Threshold slider 40-95 + Auto-notify toggle)
/// 7. Data & Privacy (CSV Export action card + Log out of all devices)
/// 8. Danger Zone (Deactivate account with confirmation dialog)
class CollegeSettingsPage extends StatelessWidget {
  const CollegeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CollegeSettingsBloc>(
      create: (_) => CollegeSettingsBloc()..add(FetchCollegeSettingsEvent()),
      child: const _CollegeSettingsContentView(),
    );
  }
}

class _CollegeSettingsContentView extends StatefulWidget {
  const _CollegeSettingsContentView();

  @override
  State<_CollegeSettingsContentView> createState() =>
      _CollegeSettingsContentViewState();
}

class _CollegeSettingsContentViewState
    extends State<_CollegeSettingsContentView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _currentPwController = TextEditingController();
  final TextEditingController _newPwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  double? _localThreshold;
  bool _confirmingDeactivate = false;

  Timer? _toastTimer;
  String? _toastMessage;
  bool _isToastSuccess = true;
  int _navIndex = 4;

  @override
  void dispose() {
    _toastTimer?.cancel();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isSuccess = true}) {
    HapticFeedback.mediumImpact();
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
      _isToastSuccess = isSuccess;
    });
    _toastTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  Future<void> _handleRefresh(BuildContext context) async {
    HapticFeedback.lightImpact();
    final completer = Completer<void>();
    context.read<CollegeSettingsBloc>().add(FetchCollegeSettingsEvent());
    await Future.delayed(const Duration(milliseconds: 500));
    completer.complete();
    return completer.future;
  }

  int _calculatePwStrength(String pw) {
    if (pw.isEmpty) return 0;
    if (pw.length < 6) return 1;
    if (pw.length < 10) return 2;
    return 3;
  }

  void _handlePasswordSubmit(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<CollegeSettingsBloc>().add(
          ChangePasswordEvent(
            currentPassword: _currentPwController.text,
            newPassword: _newPwController.text,
            confirmPassword: _confirmPwController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final sidePadding = clampDouble(screenWidth * 0.045, 12.0, 20.0);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.bg,
      drawer: const CollegeNavigationDrawer(currentRoute: '/college/settings'),
      body: SafeArea(
        bottom: true,
        child: Stack(
          children: [
            BlocConsumer<CollegeSettingsBloc, CollegeSettingsState>(
              listener: (context, state) {
                if (state is CollegeSettingsLoaded) {
                  if (state.passwordSaved) {
                    _currentPwController.clear();
                    _newPwController.clear();
                    _confirmPwController.clear();
                  }
                  if (state.toastMessage != null) {
                    _showToast(state.toastMessage!, isSuccess: state.isToastSuccess);
                    context.read<CollegeSettingsBloc>().add(ClearCollegeSettingsToastEvent());
                  }
                } else if (state is CollegeSettingsError) {
                  _showToast(state.message, isSuccess: false);
                }
              },
              builder: (context, state) {
                if (state is CollegeSettingsLoading) {
                  return _buildLoadingShimmer(context, screenWidth, sidePadding);
                }
                if (state is CollegeSettingsError) {
                  return _buildErrorState(context, state.message, screenWidth);
                }
                if (state is CollegeSettingsLoaded) {
                  return _buildLoadedContent(context, state, screenWidth, sidePadding, bottomInset, viewInsetsBottom);
                }
                return _buildLoadingShimmer(context, screenWidth, sidePadding);
              },
            ),
            if (_toastMessage != null)
              Positioned(
                top: 12,
                left: sidePadding,
                right: sidePadding,
                child: _buildToastNotification(context, _toastMessage!, isSuccess: _isToastSuccess),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
          _handleNavigation(index);
        },
        onFabPressed: () {
          HapticFeedback.lightImpact();
          _showQuickHelpSheet(context);
        },
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: context.go('/college/dashboard'); break;
      case 1: context.go('/college/students'); break;
      case 2: context.go('/college/drives'); break;
      case 3: context.go('/college/reports'); break;
      case 4: break;
    }
  }

  Widget _buildLoadedContent(
    BuildContext context,
    CollegeSettingsLoaded state,
    double screenWidth,
    double sidePadding,
    double bottomInset,
    double viewInsetsBottom,
  ) {
    final cycleThreshold = _localThreshold?.toInt() ?? state.data.placementCycle.eligibilityThreshold;

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(context),
      color: AppColors.primary,
      backgroundColor: context.surf,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(
          left: sidePadding,
          right: sidePadding,
          top: 16.0,
          bottom: (bottomInset == 0 ? 16.0 : bottomInset) + 96.0 + viewInsetsBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(child: _buildScreenHeader(context, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildAccountInfoCard(context, state.data.accountInfo, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildChangePasswordCard(context, state, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildTwoFactorCard(context, state.data.security, state.data.accountInfo.phone, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildNotificationPreferencesCard(context, state.data.notifications, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildPlacementCycleCard(context, state.data.placementCycle, cycleThreshold, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildDataPrivacyCard(context, screenWidth)),
            const SizedBox(height: 16),
            RepaintBoundary(child: _buildDangerZoneCard(context, screenWidth)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenHeader(BuildContext context, double screenWidth) {
    final titleSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncyButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.surfAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.brdr, width: 0.8),
              ),
              child: Icon(LucideIcons.menu, color: context.txtPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: context.txtPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account, security, notifications and placement cycle preferences.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w400,
                    color: context.txtSecondary,
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

  Widget _buildAccountInfoCard(BuildContext context, CollegeAccountInfo account, double screenWidth) {
    final labelSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);
    final valueSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);
    final noteSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'ACCOUNT', title: 'Account Information', icon: LucideIcons.userCheck, iconColor: const Color(0xFF2563EB), screenWidth: screenWidth, isMock: account.isMock),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.mail, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text('EMAIL ADDRESS', style: GoogleFonts.plusJakartaSans(fontSize: labelSize, fontWeight: FontWeight.w700, color: context.txtMuted, letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: context.surfAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.brdr, width: 0.8)),
                child: Row(
                  children: [
                    Expanded(child: Text(account.email, style: GoogleFonts.plusJakartaSans(fontSize: valueSize, fontWeight: FontWeight.w600, color: context.txtPrimary))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD1FAE5))),
                      child: Text('Verified', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF059669))),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.phone, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text('PHONE NUMBER', style: GoogleFonts.plusJakartaSans(fontSize: labelSize, fontWeight: FontWeight.w700, color: context.txtMuted, letterSpacing: 0.5)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: context.surfAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: context.brdr, width: 0.8)),
                child: Text(account.phone, style: GoogleFonts.plusJakartaSans(fontSize: valueSize, fontWeight: FontWeight.w600, color: context.txtPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Expanded(child: Text('To update your name, phone, or designation, head to your Profile page.', style: GoogleFonts.plusJakartaSans(fontSize: noteSize, fontWeight: FontWeight.w500, color: context.txtSecondary, height: 1.3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordCard(BuildContext context, CollegeSettingsLoaded state, double screenWidth) {
    final labelSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);
    final currentNewPw = _newPwController.text;
    final currentConfirmPw = _confirmPwController.text;
    final pwStrength = _calculatePwStrength(currentNewPw);
    final isMismatch = currentNewPw.isNotEmpty && currentConfirmPw.isNotEmpty && currentNewPw != currentConfirmPw;
    final strengthMeta = [{'label': '', 'color': AppColors.border}, {'label': 'Weak', 'color': AppColors.error}, {'label': 'Okay', 'color': AppColors.warning}, {'label': 'Strong', 'color': AppColors.success}][pwStrength];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'SECURITY', title: 'Change Password', icon: LucideIcons.key, iconColor: const Color(0xFF8B5CF6), screenWidth: screenWidth, isMock: true),
          const SizedBox(height: 14),
          _buildPasswordInputField(context: context, label: 'CURRENT PASSWORD', hintText: 'Enter current password', controller: _currentPwController, isObscured: !_showCurrentPw, labelSize: labelSize, onToggleVisibility: () => setState(() => _showCurrentPw = !_showCurrentPw)),
          const SizedBox(height: 12),
          _buildPasswordInputField(context: context, label: 'NEW PASSWORD', hintText: 'At least 8 characters', controller: _newPwController, isObscured: !_showNewPw, labelSize: labelSize, onChanged: (_) => setState(() {}), onToggleVisibility: () => setState(() => _showNewPw = !_showNewPw)),
          if (currentNewPw.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pwStrength / 3.0, minHeight: 4, backgroundColor: AppColors.inputFill, valueColor: AlwaysStoppedAnimation<Color>(strengthMeta['color'] as Color)))),
                const SizedBox(width: 8),
                Text(strengthMeta['label'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: strengthMeta['color'] as Color)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _buildPasswordInputField(context: context, label: 'CONFIRM NEW PASSWORD', hintText: 'Re-enter new password', controller: _confirmPwController, isObscured: !_showConfirmPw, labelSize: labelSize, hasError: isMismatch, onChanged: (_) => setState(() {}), onToggleVisibility: () => setState(() => _showConfirmPw = !_showConfirmPw)),
          if (isMismatch) ...[const SizedBox(height: 4), Text("Passwords don't match.", style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error))],
          if (state.passwordError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
              child: Row(children: [const Icon(LucideIcons.alertTriangle, size: 14, color: AppColors.error), const SizedBox(width: 8), Expanded(child: Text(state.passwordError!, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.error)))]),
            ),
          ],
          if (state.passwordSaved) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD1FAE5))),
              child: Row(children: [const Icon(LucideIcons.check, size: 14, color: Color(0xFF059669)), const SizedBox(width: 8), Expanded(child: Text('Password updated successfully.', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF059669))))]),
            ),
          ],
          const SizedBox(height: 14),
          BouncyButton(
            onPressed: state.isPasswordUpdating ? null : () => _handlePasswordSubmit(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(color: context.isDark ? AppColors.primary : AppColors.textPrimary, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [if (state.isPasswordUpdating) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) else const Icon(LucideIcons.key, size: 14, color: Colors.white), const SizedBox(width: 8), Text('Update Password', style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white))]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorCard(BuildContext context, CollegeSecuritySettings security, String phone, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'SECURITY', title: 'Two-Factor Authentication', icon: LucideIcons.shield, iconColor: const Color(0xFF10B981), screenWidth: screenWidth, isMock: security.isMock),
          const SizedBox(height: 10),
          _buildSettingRow(context: context, icon: LucideIcons.smartphone, title: 'SMS-Based Verification', description: 'Send a one-time code to $phone when signing in from a new device.', screenWidth: screenWidth, control: Switch.adaptive(value: security.twoFactorEnabled, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(ToggleTwoFactorEvent(val)); })),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: security.twoFactorEnabled ? const Color(0xFFECFDF5) : context.surfAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: security.twoFactorEnabled ? const Color(0xFFD1FAE5) : context.brdr)),
            child: Row(children: [Icon(security.twoFactorEnabled ? LucideIcons.check : LucideIcons.alertCircle, size: 14, color: security.twoFactorEnabled ? const Color(0xFF059669) : context.txtSecondary), const SizedBox(width: 8), Expanded(child: Text(security.twoFactorEnabled ? 'Two-factor authentication is enabled.' : 'Two-factor authentication is currently disabled.', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: security.twoFactorEnabled ? const Color(0xFF059669) : context.txtSecondary)))]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferencesCard(BuildContext context, CollegeNotificationPreferences notify, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'NOTIFICATIONS', title: 'Notification Preferences', icon: LucideIcons.bell, iconColor: const Color(0xFFF59E0B), screenWidth: screenWidth, isMock: notify.isMock),
          const SizedBox(height: 10),
          _buildSettingRow(context: context, icon: LucideIcons.mail, title: 'Email Notifications', description: 'Get key placement cell updates by email.', screenWidth: screenWidth, control: Switch.adaptive(value: notify.notifyEmail, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdateNotificationPreferenceEvent(notifyEmail: val)); })),
          const Divider(height: 16, thickness: 0.6),
          _buildSettingRow(context: context, icon: LucideIcons.phone, title: 'SMS Alerts', description: 'Receive urgent alerts as text messages.', screenWidth: screenWidth, control: Switch.adaptive(value: notify.notifySms, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdateNotificationPreferenceEvent(notifySms: val)); })),
          const Divider(height: 16, thickness: 0.6),
          _buildSettingRow(context: context, icon: LucideIcons.building, title: 'Recruiter Activity Alerts', description: 'Notify me when recruiters view or shortlist student profiles.', screenWidth: screenWidth, control: Switch.adaptive(value: notify.notifyRecruiter, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdateNotificationPreferenceEvent(notifyRecruiter: val)); })),
          const Divider(height: 16, thickness: 0.6),
          _buildSettingRow(context: context, icon: LucideIcons.bookOpen, title: 'Weekly Digest Email', description: 'A weekly summary of placement progress and skill scores.', screenWidth: screenWidth, control: Switch.adaptive(value: notify.notifyDigest, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdateNotificationPreferenceEvent(notifyDigest: val)); })),
          const Divider(height: 16, thickness: 0.6),
          _buildSettingRow(context: context, icon: LucideIcons.calendar, title: 'Drive Reminders', description: 'Remind me ahead of upcoming placement drives and deadlines.', screenWidth: screenWidth, control: Switch.adaptive(value: notify.notifyDrives, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdateNotificationPreferenceEvent(notifyDrives: val)); })),
        ],
      ),
    );
  }

  Widget _buildPlacementCycleCard(BuildContext context, CollegePlacementCycleSettings cycle, int currentThreshold, double screenWidth) {
    final labelSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);
    final noteSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'PLACEMENT CYCLE', title: 'Placement Cycle Configuration', icon: LucideIcons.target, iconColor: const Color(0xFF2563EB), screenWidth: screenWidth, isMock: cycle.isMock),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('ELIGIBILITY SKILL-SCORE THRESHOLD', style: GoogleFonts.plusJakartaSans(fontSize: labelSize, fontWeight: FontWeight.w700, color: context.txtMuted, letterSpacing: 0.5))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: context.priLight, borderRadius: BorderRadius.circular(8)), child: Text('$currentThreshold', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.inputFill, thumbColor: AppColors.primary, overlayColor: AppColors.primary.withValues(alpha: 0.12), trackHeight: 4.0),
            child: Slider(value: currentThreshold.toDouble(), min: 40, max: 95, divisions: 55, onChanged: (val) => setState(() => _localThreshold = val), onChangeEnd: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(UpdatePlacementCycleThresholdEvent(val.toInt())); setState(() => _localThreshold = null); }),
          ),
          Text('Students scoring at or above this threshold are marked placement-eligible.', style: GoogleFonts.plusJakartaSans(fontSize: noteSize, fontWeight: FontWeight.w500, color: context.txtSecondary)),
          const Divider(height: 20, thickness: 0.6),
          _buildSettingRow(context: context, icon: LucideIcons.bell, title: 'Auto-Notify Eligible Students', description: 'Automatically email students once their skill score crosses the threshold.', screenWidth: screenWidth, control: Switch.adaptive(value: cycle.autoNotifyEligible, activeTrackColor: AppColors.primary, onChanged: (val) { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(ToggleAutoNotifyEligibleEvent(val)); })),
        ],
      ),
    );
  }

  Widget _buildDataPrivacyCard(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.brdr, width: 0.8),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'DATA', title: 'Data & Privacy', icon: LucideIcons.clipboardList, iconColor: const Color(0xFF0EA5E9), screenWidth: screenWidth, isMock: true),
          const SizedBox(height: 14),
          Material(
            color: context.surfAlt,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () { HapticFeedback.lightImpact(); context.read<CollegeSettingsBloc>().add(ExportInstitutionDataEvent()); },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: context.brdr, width: 0.8)),
                child: Row(children: [Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: context.surf, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.download, size: 16, color: AppColors.textSecondary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Export Institution Data', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: context.txtPrimary)), const SizedBox(height: 2), Text('Download student & placement records as CSV', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w400, color: context.txtSecondary))])), const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted)]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: context.surfAlt,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _showLogoutConfirmationDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: context.brdr, width: 0.8)),
                child: Row(children: [Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: context.surf, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.logOut, size: 16, color: AppColors.textSecondary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Log Out of All Devices', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: context.txtPrimary)), const SizedBox(height: 2), Text('End all active sessions, including this one', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w400, color: context.txtSecondary))])), const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted)]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFFFF1F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECDD3), width: 0.8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(eyebrow: 'DANGER ZONE', title: 'Deactivate Account', icon: LucideIcons.alertTriangle, iconColor: const Color(0xFFEF4444), screenWidth: screenWidth, isMock: true),
          const SizedBox(height: 10),
          Text('Deactivating your admin account removes your access to the placement cell workspace. Student and placement data is retained and can be reassigned by another admin.', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF881337), height: 1.4)),
          const SizedBox(height: 14),
          if (!_confirmingDeactivate)
            BouncyButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _confirmingDeactivate = true);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.trash2,
                        size: 14, color: Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    Text(
                      'Deactivate My Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure? This action can be reversed only by a super-admin.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      BouncyButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _confirmingDeactivate = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BouncyButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          setState(() => _confirmingDeactivate = false);
                          context
                              .read<CollegeSettingsBloc>()
                              .add(DeactivateCollegeAccountEvent());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Yes, Deactivate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
    );
  }

  Widget _buildSectionHeader({
    required String eyebrow,
    required String title,
    required IconData icon,
    required Color iconColor,
    required double screenWidth,
    bool isMock = false,
  }) {
    final eyebrowSize = clampDouble(screenWidth * 0.026, 10.0, 11.0);
    final headerSize = clampDouble(screenWidth * 0.042, 15.0, 17.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              eyebrow,
              style: GoogleFonts.plusJakartaSans(
                fontSize: eyebrowSize,
                fontWeight: FontWeight.w800,
                color: context.txtMuted,
                letterSpacing: 1.0,
              ),
            ),
            if (isMock) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.sparkles,
                      size: 9,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Soon *',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: headerSize,
                  fontWeight: FontWeight.w800,
                  color: context.txtPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget control,
    required double screenWidth,
  }) {
    final titleSize = clampDouble(screenWidth * 0.035, 13.0, 14.0);
    final descSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surfAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: context.txtPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: descSize,
                    fontWeight: FontWeight.w400,
                    color: context.txtSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          control,
        ],
      ),
    );
  }

  Widget _buildPasswordInputField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isObscured,
    required double labelSize,
    required VoidCallback onToggleVisibility,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: context.txtMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.surfAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError ? AppColors.error : context.brdr,
              width: hasError ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isObscured,
                  onChanged: onChanged,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: context.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: context.txtMuted,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggleVisibility();
                },
                icon: Icon(
                  isObscured ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToastNotification(
    BuildContext context,
    String message, {
    required bool isSuccess,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: dialogCtx.surf,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Log Out of All Devices',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: dialogCtx.txtPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to end all active sessions across all devices?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: dialogCtx.txtSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: dialogCtx.txtSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              _showToast('All active sessions have been terminated.');
            },
            child: Text(
              'Log Out All',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: sheetCtx.surf,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetCtx.brdr,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Institutional Settings & Preferences',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: sheetCtx.txtPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your placement cell account credentials, multi-factor verification, broadcast alerts, and candidate eligibility thresholds for active placement seasons.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: sheetCtx.txtSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(sheetCtx),
                child: Text(
                  'Got It',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(
    BuildContext context,
    double screenWidth,
    double sidePadding,
  ) {
    return Shimmer.fromColors(
      baseColor: context.isDark ? const Color(0xFF1E293B) : Colors.grey[200]!,
      highlightColor: context.isDark ? const Color(0xFF334155) : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sidePadding, vertical: 16),
        child: Column(
          children: [
            Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 4; i++) ...[
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    double screenWidth,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to Load Settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.txtPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: context.txtSecondary,
              ),
            ),
            const SizedBox(height: 16),
            BouncyButton(
              onPressed: () {
                context
                    .read<CollegeSettingsBloc>()
                    .add(FetchCollegeSettingsEvent());
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
