import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_dashboard_models.dart';

/// Live activity stream audit list for admin portal.
/// Tagged with an Asterisk (*) indicator because live event streaming endpoint is mock.
class AdminActivityStream extends StatelessWidget {
  final List<AdminActivityLogDto> activities;

  const AdminActivityStream({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
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
            // Header with pulsating green status indicator & Mock asterisk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LIVE ACTIVITY STREAM',
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
                    const SizedBox(width: 6),
                    _PulsatingDot(),
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
                    '*Audit Mock',
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

            // Activity Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = activities[index];
                return _buildActivityItem(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({required AdminActivityLogDto item}) {
    IconData icon;
    Color iconColor;
    Color iconBg;
    Color iconBorder;

    switch (item.iconType) {
      case 'student':
        icon = LucideIcons.userPlus;
        iconColor = AppColors.accent;
        iconBg = AppColors.primaryLight;
        iconBorder = const Color(0xFFDDD6FE);
        break;
      case 'recruiter':
        icon = LucideIcons.briefcase;
        iconColor = AppColors.accent;
        iconBg = AppColors.primaryLight;
        iconBorder = const Color(0xFFDDD6FE);
        break;
      case 'warning':
        icon = LucideIcons.alertTriangle;
        iconColor = const Color(0xFFD97706);
        iconBg = const Color(0xFFFEF3C7);
        iconBorder = const Color(0xFFFDE68A);
        break;
      case 'check':
      default:
        icon = LucideIcons.checkCircle2;
        iconColor = const Color(0xFF059669);
        iconBg = const Color(0xFFD1FAE5);
        iconBorder = const Color(0xFFA7F3D0);
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconBorder, width: 0.8),
          ),
          child: Center(
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.timeAgo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PulsatingDot extends StatefulWidget {
  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF10B981).withValues(
              alpha: 0.5 + (_controller.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(
                  alpha: 0.3 * _controller.value,
                ),
                blurRadius: 6 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
