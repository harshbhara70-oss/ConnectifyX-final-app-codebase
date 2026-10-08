import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_settings_models.dart';

/// Card for User Policies, General Config, and Notifications
class AdminPoliciesCard extends StatelessWidget {
  final AdminGeneralSettingsModel general;
  final Function(AdminGeneralSettingsModel updated) onSave;

  const AdminPoliciesCard({
    super.key,
    required this.general,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF6D28D9)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'User & Security Policies',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Policy Switch 1: Mandatory 2FA
          _buildSwitchTile(
            title: 'Mandatory 2FA for Recruiters',
            subtitle: 'Enforce two-factor verification on corporate accounts',
            value: general.mandatory2fa,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onSave(general.copyWith(mandatory2fa: val));
            },
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16),

          // Policy Switch 2: Auto-Approve Verified Colleges
          _buildSwitchTile(
            title: 'Auto-Approve Accredited Colleges',
            subtitle: 'Automatically approve institutes matching edu domain registry',
            value: general.autoApproveColleges,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onSave(general.copyWith(autoApproveColleges: val));
            },
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16),

          // Policy Switch 3: System Alert Webhooks
          _buildSwitchTile(
            title: 'System Alert Webhooks',
            subtitle: 'Forward critical platform outages to SecOps Slack channel',
            value: general.systemAlertWebhooks,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onSave(general.copyWith(systemAlertWebhooks: val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          activeTrackColor: const Color(0xFF6D28D9),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
