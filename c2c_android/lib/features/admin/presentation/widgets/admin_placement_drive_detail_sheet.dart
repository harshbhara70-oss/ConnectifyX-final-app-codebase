import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_placement_models.dart';

/// Modal Bottom Sheet displaying full Drive Oversight Information & Actions
class AdminPlacementDriveDetailSheet extends StatelessWidget {
  final AdminPlacementDriveModel drive;
  final ValueChanged<String> onStatusUpdate;
  final VoidCallback onDelete;

  const AdminPlacementDriveDetailSheet({
    super.key,
    required this.drive,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final navBarHeight = MediaQuery.paddingOf(context).bottom;
    final titleSize = clampDouble(screenWidth * 0.046, 16.0, 19.0);
    final sectionTitleSize = clampDouble(screenWidth * 0.038, 14.0, 16.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: clampDouble(screenWidth * 0.05, 16.0, 22.0),
            right: clampDouble(screenWidth * 0.05, 16.0, 22.0),
            top: 14,
            bottom: bottomInset > 0 ? bottomInset + 12 : navBarHeight + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          drive.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          drive.role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 12),

              // Scrollable Details
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Grid
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('College', drive.college, LucideIcons.graduationCap),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('Drive Type', drive.type, LucideIcons.briefcase),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('Status', drive.status, LucideIcons.activity),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('CTC Package', drive.ctcRange, LucideIcons.badgeDollarSign),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('Location', drive.location, LucideIcons.mapPin),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('Deadline', drive.deadline, LucideIcons.calendar),
                            const Divider(color: Color(0xFFE2E8F0), height: 16),
                            _buildInfoRow('Applicants', '${drive.applicants} Candidates', LucideIcons.users),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Eligibility Requirements
                      Text(
                        'Eligibility Criteria',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Text(
                          drive.eligibility,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Selection Rounds
                      Text(
                        'Selection Rounds',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: drive.rounds.length,
                        separatorBuilder: (context, _) => const SizedBox(height: 6),
                        itemBuilder: (context, idx) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECE6FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    drive.rounds[idx],
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status Update Actions
                      Text(
                        'Update Drive Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: sectionTitleSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusButton(context, 'In Progress', const Color(0xFF6366F1)),
                          _buildStatusButton(context, 'Assessment Phase', const Color(0xFF059669)),
                          _buildStatusButton(context, 'Completed', const Color(0xFF64748B)),
                          _buildStatusButton(context, 'Scheduled', const Color(0xFF2563EB)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Delete Drive CTA
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            onDelete();
                          },
                          icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFEF4444)),
                          label: Text(
                            'Remove Drive from Oversight',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFFECDD3), width: 1.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(BuildContext context, String status, Color color) {
    final isSelected = drive.status.toLowerCase() == status.toLowerCase();

    return Material(
      color: isSelected ? color : color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          onStatusUpdate(status);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            status,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}
