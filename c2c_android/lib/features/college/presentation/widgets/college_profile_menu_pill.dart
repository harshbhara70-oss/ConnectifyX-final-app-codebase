import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';

/// Production-ready College Profile Menu Pill Widget.
/// Displays institutional avatar initial, college short name, and opens a dropdown card
/// with College settings, sub-module routers, and secure Logout confirmation.
class CollegeProfileMenuPill extends StatelessWidget {
  final String collegeName;
  final String collegeEmail;
  final String avatarInitial;

  const CollegeProfileMenuPill({
    super.key,
    this.collegeName = 'MIT Academy of Engineering',
    this.collegeEmail = 'tpo@mitaoe.ac.in',
    this.avatarInitial = 'M',
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showCollegeProfileDropdown(
          context,
          collegeName: collegeName,
          collegeEmail: collegeEmail,
          avatarInitial: avatarInitial,
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 10,
            vertical: isCompact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.brdr),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Purple/Indigo Circular Avatar Initial Badge
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentViolet, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarInitial.isNotEmpty ? avatarInitial[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 6),
                // College Short Name with explicit bounds
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    collegeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: context.txtPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  LucideIcons.chevronDown,
                  size: 14,
                  color: context.txtSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Launcher function to present the College Profile Dropdown Menu anchored below the top-right pill
void showCollegeProfileDropdown(
  BuildContext context, {
  String collegeName = 'MIT Academy of Engineering',
  String collegeEmail = 'tpo@mitaoe.ac.in',
  String avatarInitial = 'M',
}) {
  HapticFeedback.lightImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss College Profile Menu',
    barrierColor: Colors.black.withValues(alpha: context.isDark ? 0.5 : 0.25),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 54),
            child: Material(
              color: Colors.transparent,
              child: _CollegeProfileDropdownMenuCard(
                collegeName: collegeName,
                collegeEmail: collegeEmail,
                avatarInitial: avatarInitial,
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
        alignment: Alignment.topRight,
        child: FadeTransition(
          opacity: curvedAnimation,
          child: child,
        ),
      );
    },
  );
}

class _CollegeProfileDropdownMenuCard extends StatelessWidget {
  final String collegeName;
  final String collegeEmail;
  final String avatarInitial;

  const _CollegeProfileDropdownMenuCard({
    required this.collegeName,
    required this.collegeEmail,
    required this.avatarInitial,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 240.0;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.12),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: context.brdr),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. College Identity Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  collegeName,
                  maxLines: 1,
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.txtPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  collegeEmail,
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: context.txtSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 6),

          // 2. Navigation Items (Settings, Profile, Drives, Reports)
          _buildMenuItem(
            context,
            title: 'College Profile & Settings',
            icon: LucideIcons.settings,
            route: '/college/settings',
          ),
          _buildMenuItem(
            context,
            title: 'Placement Drives',
            icon: LucideIcons.briefcase,
            route: '/college/drives',
          ),
          _buildMenuItem(
            context,
            title: 'Students Directory',
            icon: LucideIcons.users,
            route: '/college/students',
          ),
          _buildMenuItem(
            context,
            title: 'Placement Reports',
            icon: LucideIcons.fileText,
            route: '/college/reports',
          ),

          const SizedBox(height: 4),
          Divider(height: 1, color: context.brdr),
          const SizedBox(height: 4),

          // 3. Logout Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _confirmAndLogout(context),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.logOut,
                      size: 17,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          context.go(route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: context.txtSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 11,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.txtPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    HapticFeedback.lightImpact();
    final router = GoRouter.of(context);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(LucideIcons.logOut, color: AppColors.error, size: 22),
              SizedBox(width: 10),
              Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of your College Portal?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  const storage = FlutterSecureStorage();
                  await storage.delete(key: 'jwt_token');
                  await storage.deleteAll();
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                } catch (_) {}

                router.go('/auth/role-select');
              },
              child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
