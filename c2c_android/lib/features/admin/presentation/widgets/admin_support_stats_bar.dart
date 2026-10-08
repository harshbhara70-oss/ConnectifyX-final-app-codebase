import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_support_models.dart';

/// Top metric counters banner matching web SupportCenter.tsx (OPEN, IN PROGRESS, RESOLVED)
/// Structured for zero-truncation, responsive multi-device scaling, and Asterisk (*) indicator.
class AdminSupportStatsBar extends StatelessWidget {
  final AdminSupportStatsModel stats;

  const AdminSupportStatsBar({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 360;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'OPEN',
            value: stats.openCount.toString(),
            valueColor: const Color(0xFF6D28D9),
            borderColor: const Color(0xFFDDD6FE),
            screenWidth: screenWidth,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'IN PROGRESS',
            value: stats.inProgressCount.toString(),
            valueColor: AppColors.textPrimary,
            borderColor: AppColors.border,
            screenWidth: screenWidth,
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: 'RESOLVED',
            value: stats.resolvedCount.toString(),
            valueColor: const Color(0xFF059669),
            borderColor: const Color(0xFFA7F3D0),
            screenWidth: screenWidth,
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color borderColor,
    required double screenWidth,
    required bool isSmallScreen,
  }) {
    final counterSize = (screenWidth * 0.055).clamp(18.0, 22.0);
    final labelSize = (screenWidth * 0.026).clamp(10.0, 11.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8.0 : 12.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: counterSize,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              if (stats.isMock) ...[
                const SizedBox(width: 2),
                Text(
                  '*',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
