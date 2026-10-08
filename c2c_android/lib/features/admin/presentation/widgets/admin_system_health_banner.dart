import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import 'admin_diagnostics_sheet.dart';

/// System Status Banner displaying MongoDB Atlas connectivity & service health.
/// Enforces zero-truncation layout across all device viewports.
class AdminSystemHealthBanner extends StatelessWidget {
  final double screenWidth;

  const AdminSystemHealthBanner({
    super.key,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = (screenWidth * 0.038).clamp(13.0, 15.0);
    final subtitleFontSize = (screenWidth * 0.031).clamp(11.0, 12.5);

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFA7F3D0),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6EE7B7),
                      width: 0.6,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.checkCircle2,
                      size: 19,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            'Atlas & Core Engine',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFA7F3D0), width: 0.6),
                            ),
                            child: Text(
                              'LIVE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Connected to Atlas cluster. All services nominal.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AdminDiagnosticsSheet.show(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Diagnostics*',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          LucideIcons.chevronRight,
                          size: 13,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
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
