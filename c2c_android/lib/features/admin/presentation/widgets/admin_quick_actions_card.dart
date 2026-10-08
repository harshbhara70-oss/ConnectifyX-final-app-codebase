import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import 'admin_broadcast_sheet.dart';

/// Full-width Quick Actions card with zero overflow risk.
/// Actions without backend endpoints show an Asterisk (*) indicator.
class AdminQuickActionsCard extends StatelessWidget {
  final bool isApprovedAll;
  final bool isExporting;
  final VoidCallback onApproveAll;
  final Function(String) onSendBroadcast;
  final VoidCallback onExportReport;

  const AdminQuickActionsCard({
    super.key,
    required this.isApprovedAll,
    required this.isExporting,
    required this.onApproveAll,
    required this.onSendBroadcast,
    required this.onExportReport,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final btnFontSize = clampDouble(screenWidth * 0.033, 11.5, 13.0);

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
                      'QUICK ACTIONS',
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
                    '*Simulated Actions',
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

            // Action Buttons Grid
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isApprovedAll
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            onApproveAll();
                          },
                    icon: const Icon(LucideIcons.check, size: 14),
                    label: Text(
                      isApprovedAll ? 'Approved' : 'Approve All',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: btnFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryLight,
                      disabledForegroundColor: AppColors.textMuted,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      AdminBroadcastSheet.show(context, onSend: onSendBroadcast);
                    },
                    icon: const Icon(LucideIcons.play, size: 12),
                    label: Text(
                      'Broadcast*',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: btnFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Button Row 2: Export Weekly Report
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isExporting
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onExportReport();
                      },
                icon: isExporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                    : const Icon(LucideIcons.download, size: 14),
                label: Text(
                  isExporting ? 'Generating CSV...' : 'Export Weekly Report*',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: btnFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
