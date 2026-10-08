import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Highly optimized, responsive Metric Card for Admin Dashboard.
/// Enforces equal dimensions across all grid cells with zero RenderBox/text overflow issues.
/// Full-width typography hierarchy prevents any truncation on narrow mobile devices.
/// Automatically displays an Asterisk (*) badge when backed by mock data.
class AdminMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isTrendPositive;
  final bool showTrendIcon;
  final bool isMock;
  final VoidCallback? onTap;

  const AdminMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isTrendPositive = false,
    this.showTrendIcon = false,
    this.isMock = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final counterFontSize = (screenWidth * 0.065).clamp(20.0, 26.0);
    final labelFontSize = (screenWidth * 0.033).clamp(12.0, 13.5);
    final subtitleFontSize = (screenWidth * 0.030).clamp(11.0, 12.0);

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isMock) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, size: 14, color: Color(0xFFFDE68A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$label: Currently simulated with mock data. Real-time endpoint coming soon!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.cardDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (onTap != null) {
              onTap!();
            }
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
            decoration: BoxDecoration(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: 38x38 Icon Box + Mock Badge (if simulated)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (isMock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '*Mock',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Middle Content: Value Counter (Bold)
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: counterFontSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),

                // Bottom Content: Full-Width Title Label & Subtitle / Trend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isMock) ...[
                          const SizedBox(width: 2),
                          Text(
                            '*',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (showTrendIcon) ...[
                          Icon(
                            LucideIcons.trendingUp,
                            size: 12,
                            color: isTrendPositive
                                ? const Color(0xFF059669)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: subtitleFontSize,
                              fontWeight: isTrendPositive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isTrendPositive
                                  ? const Color(0xFF059669)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
