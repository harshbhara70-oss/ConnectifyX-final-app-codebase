import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_user_models.dart';

class AdminUserDetailSheet extends StatelessWidget {
  final dynamic userModel; // AdminStudentModel | AdminCollegeModel | AdminRecruiterModel
  final UserRoleTab role;
  final VoidCallback onToggleSuspend;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminUserDetailSheet({
    super.key,
    required this.userModel,
    required this.role,
    required this.onToggleSuspend,
    required this.onEdit,
    required this.onDelete,
  });

  static void show(
    BuildContext context, {
    required dynamic userModel,
    required UserRoleTab role,
    required VoidCallback onToggleSuspend,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminUserDetailSheet(
        userModel: userModel,
        role: role,
        onToggleSuspend: onToggleSuspend,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom == 0
        ? 16.0
        : MediaQuery.paddingOf(context).bottom;

    final String name = _getName();
    final String email = _getEmail();
    final String status = _getStatus();
    final bool isSuspended = status.toLowerCase().contains('suspend') ||
        status.toLowerCase().contains('inact');
    final bool isMock = _getIsMock();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: clampDouble(screenWidth * 0.045, 12.0, 20.0),
            right: clampDouble(screenWidth * 0.045, 12.0, 20.0),
            top: 12.0,
            bottom: bottomInset + 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Row with Avatar, Name, Email, and Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarOrIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.toTitleCase(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: clampDouble(screenWidth * 0.045, 16.0, 19.0),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isMock) ...[
                              const SizedBox(width: 4),
                              Text(
                                '*',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.033, 12.0, 13.5),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Badges Tier (Role, Placement, Status)
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          role == UserRoleTab.students
                              ? LucideIcons.graduationCap
                              : (role == UserRoleTab.colleges
                                  ? LucideIcons.building2
                                  : LucideIcons.briefcase),
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          role.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Placement Badge (if Student)
                  if (role == UserRoleTab.students && userModel is AdminStudentModel) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: (userModel as AdminStudentModel).placementStatus == 'Placed'
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (userModel as AdminStudentModel).placementStatus == 'Placed'
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        (userModel as AdminStudentModel).placementStatus,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: (userModel as AdminStudentModel).placementStatus == 'Placed'
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuspended ? AppColors.errorLight : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSuspended ? const Color(0xFFFECDD3) : const Color(0xFFA7F3D0),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSuspended ? AppColors.error : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1, thickness: 0.8),
              const SizedBox(height: 16),

              // Detail Section Content
              _buildRoleSpecificDetails(context, screenWidth),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  // Suspend / Activate CTA
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        onToggleSuspend();
                      },
                      icon: Icon(
                        isSuspended ? LucideIcons.checkCircle : LucideIcons.ban,
                        size: 15,
                      ),
                      label: Text(
                        isSuspended ? 'Activate' : 'Suspend',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuspended ? const Color(0xFF10B981) : AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Edit Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        onEdit();
                      },
                      icon: const Icon(LucideIcons.edit2, size: 15),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Button
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      HapticFeedback.lightImpact();
                      onDelete();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECDD3), width: 0.8),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOrIcon() {
    if (role == UserRoleTab.students && userModel is AdminStudentModel) {
      final s = userModel as AdminStudentModel;
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          s.avatar,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 50,
            height: 50,
            color: AppColors.primaryLight,
            child: const Icon(LucideIcons.user, size: 26, color: AppColors.primary),
          ),
        ),
      );
    } else if (role == UserRoleTab.colleges) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFCCFBF1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(LucideIcons.building2, size: 26, color: Color(0xFF0F766E)),
      );
    } else {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(LucideIcons.briefcase, size: 26, color: AppColors.primary),
      );
    }
  }

  Widget _buildRoleSpecificDetails(BuildContext context, double screenWidth) {
    if (role == UserRoleTab.students && userModel is AdminStudentModel) {
      final s = userModel as AdminStudentModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic & Placement Dossier',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.building, 'College', s.college),
          _buildInfoRow(LucideIcons.bookOpen, 'Branch', s.branch),
          _buildInfoRow(LucideIcons.award, 'CGPA', s.cgpa),
          _buildInfoRow(LucideIcons.layers, 'Roadmaps & Projects', '${s.rms} • ${s.prjs}'),
          if (s.phone.isNotEmpty) _buildInfoRow(LucideIcons.phone, 'Contact Phone', s.phone),
          _buildInfoRow(LucideIcons.calendar, 'Semester', '${s.semester}th Semester'),
          const SizedBox(height: 10),
          if (s.skills.isNotEmpty) ...[
            Text(
              'Technical Skills',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: s.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    } else if (role == UserRoleTab.colleges && userModel is AdminCollegeModel) {
      final c = userModel as AdminCollegeModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Institutional Oversight',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.landmark, 'Affiliated University', c.university),
          _buildInfoRow(LucideIcons.mapPin, 'Location', '${c.city}, ${c.state}'),
          if (c.phone.isNotEmpty) _buildInfoRow(LucideIcons.phone, 'TPO Phone', c.phone),
          if (c.website.isNotEmpty) _buildInfoRow(LucideIcons.globe, 'Website', c.website),
          _buildInfoRow(LucideIcons.users, 'Enrolled Students', '${c.studentsCount} Students'),
        ],
      );
    } else if (role == UserRoleTab.recruiters && userModel is AdminRecruiterModel) {
      final r = userModel as AdminRecruiterModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recruiter Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: clampDouble(screenWidth * 0.038, 14.0, 15.5),
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.building2, 'Company', r.company),
          _buildInfoRow(LucideIcons.userCheck, 'Designation', r.designation),
          if (r.phone.isNotEmpty) _buildInfoRow(LucideIcons.phone, 'Phone', r.phone),
          if (r.linkedin.isNotEmpty) _buildInfoRow(LucideIcons.linkedin, 'LinkedIn', r.linkedin),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 3,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getName() {
    if (userModel is AdminStudentModel) return (userModel as AdminStudentModel).name;
    if (userModel is AdminCollegeModel) return (userModel as AdminCollegeModel).name;
    if (userModel is AdminRecruiterModel) return (userModel as AdminRecruiterModel).name;
    return 'Entity';
  }

  String _getEmail() {
    if (userModel is AdminStudentModel) return (userModel as AdminStudentModel).email;
    if (userModel is AdminCollegeModel) return (userModel as AdminCollegeModel).email;
    if (userModel is AdminRecruiterModel) return (userModel as AdminRecruiterModel).email;
    return '';
  }

  String _getStatus() {
    if (userModel is AdminStudentModel) return (userModel as AdminStudentModel).activeStatus;
    if (userModel is AdminCollegeModel) return (userModel as AdminCollegeModel).status;
    if (userModel is AdminRecruiterModel) return (userModel as AdminRecruiterModel).status;
    return 'Active';
  }

  bool _getIsMock() {
    if (userModel is AdminStudentModel) return (userModel as AdminStudentModel).isMock;
    if (userModel is AdminCollegeModel) return (userModel as AdminCollegeModel).isMock;
    if (userModel is AdminRecruiterModel) return (userModel as AdminRecruiterModel).isMock;
    return false;
  }
}
