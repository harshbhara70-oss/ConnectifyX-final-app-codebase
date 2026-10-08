import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_placement_models.dart';

/// Interactive Drive Card for Placement Oversight Roster.
/// Features zero-overflow wrapped badges, clamped typography, and full-card InkWell.
class AdminPlacementDriveCard extends StatelessWidget {
  final AdminPlacementDriveModel drive;
  final VoidCallback onTap;

  const AdminPlacementDriveCard({
    super.key,
    required this.drive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);
    final subSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);
    final badgeSize = clampDouble(screenWidth * 0.030, 11.0, 12.0);

    // Status colors
    Color statusBgColor = const Color(0xFFEDE9FE);
    Color statusTextColor = const Color(0xFF6D28D9);

    switch (drive.status.toLowerCase()) {
      case 'completed':
        statusBgColor = const Color(0xFFF1F5F9);
        statusTextColor = const Color(0xFF64748B);
        break;
      case 'assessment phase':
        statusBgColor = const Color(0xFFECFDF5);
        statusTextColor = const Color(0xFF059669);
        break;
      case 'scheduled':
        statusBgColor = const Color(0xFFEFF6FF);
        statusTextColor = const Color(0xFF2563EB);
        break;
      case 'in progress':
      default:
        statusBgColor = const Color(0xFFEDE9FE);
        statusTextColor = const Color(0xFF6D28D9);
        break;
    }

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
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
              children: [
                // Top Row: Company & Role + Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE6FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.building2,
                          size: 20,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  drive.company,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (drive.isMock) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.star,
                                  size: 10,
                                  color: Color(0xFFD97706),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            drive.role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: subSize,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // College Name with landmark icon
                Row(
                  children: [
                    const Icon(
                      LucideIcons.graduationCap,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        drive.college,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: subSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Badges & Metrics Row
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        drive.status,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: badgeSize,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor,
                        ),
                      ),
                    ),

                    // Drive Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        drive.type,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: badgeSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    // CTC Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        drive.ctcRange,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: badgeSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 10),

                // Bottom Meta: Deadline & Applicants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          drive.deadline,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.users,
                          size: 13,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${drive.applicants} Applicants',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
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
