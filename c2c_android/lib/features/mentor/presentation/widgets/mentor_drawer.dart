import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

/// Production-ready Mentor Navigation Drawer matching the website sidebar & uploaded UI
class MentorNavigationDrawer extends StatelessWidget {
  final String currentRoute;

  const MentorNavigationDrawer({
    super.key,
    this.currentRoute = '/mentor/dashboard',
  });

  Future<void> _handleLogout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.logOut,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end your Mentor workspace session?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.heavyImpact();
      try {
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      } catch (_) {}

      if (context.mounted) {
        Navigator.pop(context); // Close drawer
        context.go('/auth/role-select');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Drawer(
      backgroundColor: const Color(0xFF0D1322), // Dark Navy matching website/uploaded sidebar
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(context),
            const Divider(height: 1, color: Color(0xFF1E293B)),

            // Navigation List: 11 Core Items matching web & image exactly
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 12,
                  left: 12,
                  right: 12,
                  bottom: bottomInset == 0 ? 16.0 : bottomInset + 8.0,
                ),
                children: [
                  // 1. Dashboard Overview
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.bookOpen,
                    title: 'Dashboard Overview',
                    route: '/mentor/dashboard',
                    isSelected: currentRoute == '/mentor/dashboard',
                  ),

                  // 2. Student Analytics
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.users,
                    title: 'Student Analytics',
                    route: '/mentor/students',
                    isSelected: currentRoute == '/mentor/students',
                  ),

                  // 3. Session Timeline
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.calendar,
                    title: 'Session Timeline',
                    route: '/mentor/sessions',
                    isSelected: currentRoute == '/mentor/sessions',
                  ),

                  // 4. Employability Matrix
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.award,
                    title: 'Employability Matrix',
                    route: '/mentor/employability',
                    isSelected: currentRoute == '/mentor/employability',
                  ),

                  // 5. Activity & Leaderboard
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.trendingUp,
                    title: 'Activity & Leaderboard',
                    route: '/mentor/activity',
                    isSelected: currentRoute == '/mentor/activity',
                  ),

                  // 6. Shared Material Library (Live with MongoDB Atlas endpoints)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.uploadCloud,
                    title: 'Shared Material Library',
                    route: '/mentor/resources',
                    isSelected: currentRoute == '/mentor/resources',
                  ),

                  // 7. Career Roadmaps (Live with MongoDB Atlas / Stepper Checklists)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.checkCircle2,
                    title: 'Career Roadmaps',
                    route: '/mentor/roadmaps',
                    isSelected: currentRoute == '/mentor/roadmaps',
                  ),

                  // 8. Communication Hub (Upcoming / Mock)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.messageSquare,
                    title: 'Communication Hub',
                    route: '/mentor/communication',
                    isSelected: currentRoute == '/mentor/communication',
                  ),

                  // 9. Feedback Section (Live with MongoDB Atlas evaluation submission)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.star,
                    title: 'Feedback Section',
                    route: '/mentor/feedback',
                    isSelected: currentRoute == '/mentor/feedback',
                  ),

                  // 10. Mentor Profile (Live with MongoDB Atlas profile sync)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.shield,
                    title: 'Mentor Profile',
                    route: '/mentor/profile',
                    isSelected: currentRoute == '/mentor/profile',
                  ),

                  // 11. System Settings (Live with MongoDB Atlas settings sync)
                  _buildDrawerItem(
                    context,
                    icon: LucideIcons.settings,
                    title: 'System Settings',
                    route: '/mentor/settings',
                    isSelected: currentRoute == '/mentor/settings',
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFF1E293B)),
                  const SizedBox(height: 12),

                  // 12. Mentor Profile Footer & Logout Button
                  _buildMentorFooter(context),
                  const SizedBox(height: 8),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'C2C',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ASHOKSOFT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'C2C Mentorship',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          size: 19,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context); // Close Drawer
          if (!isSelected) {
            context.go(route);
          }
        },
      ),
    );
  }

  Widget _buildMentorFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'SJ',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Sarah Jenkins',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Mentor ID: M-2026',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: const Icon(
          LucideIcons.logOut,
          size: 19,
          color: Color(0xFFF87171),
        ),
        title: Text(
          'Logout Session',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF87171),
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 16,
          color: Color(0xFFF87171),
        ),
        onTap: () => _handleLogout(context),
      ),
    );
  }
}
