import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_dashboard_models.dart';

/// Full-width Pending Approvals summary card with zero overflow risk.
/// Displays an Asterisk (*) badge because verification queue aggregation is currently mock.
class AdminPendingApprovalsCard extends StatelessWidget {
  final PendingApprovalsDto approvals;

  const AdminPendingApprovalsCard({
    super.key,
    required this.approvals,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleFontSize = clampDouble(screenWidth * 0.038, 13.0, 15.0);
    final badgeFontSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.border,
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card Header + Asterisk Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'PENDING VERIFICATIONS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '*',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 0.6),
                  ),
                  child: Text(
                    '*Mock Data',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // Item 1: College Onboarding
            _buildApprovalRow(
              icon: LucideIcons.building2,
              title: 'New College Onboarding',
              badgeText: '${approvals.collegePending} pending',
              badgeBg: const Color(0xFFFFFBEB),
              badgeTextColor: const Color(0xFFD97706),
              badgeBorderColor: const Color(0xFFFDE68A),
              titleFontSize: titleFontSize,
              badgeFontSize: badgeFontSize,
            ),
            const SizedBox(height: 10),

            // Item 2: Recruiter Verification
            _buildApprovalRow(
              icon: LucideIcons.fileCheck,
              title: 'Recruiter Verification',
              badgeText: '${approvals.recruiterUrgent} urgent',
              badgeBg: const Color(0xFFFEF2F2),
              badgeTextColor: const Color(0xFFEF4444),
              badgeBorderColor: const Color(0xFFFECDD3),
              titleFontSize: titleFontSize,
              badgeFontSize: badgeFontSize,
            ),
            const SizedBox(height: 10),

            // Item 3: Broadcast Approval
            _buildApprovalRow(
              icon: LucideIcons.megaphone,
              title: 'Broadcast Approval',
              badgeText: '${approvals.broadcastDrafts} drafts',
              badgeBg: const Color(0xFFF1F5F9),
              badgeTextColor: const Color(0xFF475569),
              badgeBorderColor: const Color(0xFFE2E8F0),
              titleFontSize: titleFontSize,
              badgeFontSize: badgeFontSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalRow({
    required IconData icon,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    required Color badgeBorderColor,
    required double titleFontSize,
    required double badgeFontSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeBorderColor, width: 0.8),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: badgeFontSize,
              fontWeight: FontWeight.w700,
              color: badgeTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
