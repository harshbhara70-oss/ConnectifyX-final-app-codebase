import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Maintenance Mode Panel matching web SettingsView.tsx
class AdminMaintenanceCard extends StatelessWidget {
  final bool maintenanceEnabled;
  final VoidCallback onToggle;

  const AdminMaintenanceCard({
    super.key,
    required this.maintenanceEnabled,
    required this.onToggle,
  });

  void _showConfirmationDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              color: maintenanceEnabled ? const Color(0xFF059669) : const Color(0xFFEF4444),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              maintenanceEnabled ? 'Resume Platform' : 'Enable Maintenance',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          maintenanceEnabled
              ? 'This will restore public access for all colleges, students, and recruiters.'
              : 'This will immediately terminate all non-admin active sessions across mobile & web. Are you sure you want to proceed?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onToggle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: maintenanceEnabled ? const Color(0xFF059669) : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              maintenanceEnabled ? 'Resume' : 'Activate',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: maintenanceEnabled ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
                width: 4.0,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.alertOctagon, size: 16, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'System Maintenance Mode',
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
              const SizedBox(height: 8),
              Text(
                'Activating maintenance mode will immediately terminate all active student and corporate recruiter sessions. Only Super Admins will retain access.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Status Box + Action Button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: maintenanceEnabled ? const Color(0xFFEF4444) : const Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'System Status',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maintenanceEnabled
                          ? 'Maintenance mode is currently ACTIVE.'
                          : 'Currently operating normally.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: maintenanceEnabled ? const Color(0xFFEF4444) : AppColors.textSecondary,
                        fontWeight: maintenanceEnabled ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showConfirmationDialog(context),
                        icon: const Icon(LucideIcons.power, size: 14),
                        label: Text(
                          maintenanceEnabled ? 'Disable Maintenance' : '⚡ Enable Maintenance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maintenanceEnabled ? const Color(0xFFDC2626) : Colors.white,
                          foregroundColor: maintenanceEnabled ? Colors.white : const Color(0xFF0F172A),
                          elevation: maintenanceEnabled ? 2 : 0,
                          side: maintenanceEnabled ? BorderSide.none : const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
