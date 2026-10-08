import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';

/// Production-ready Admin Sidebar Drawer Navigation Panel for Campus2Corporate.
/// 1:1 Parity with the Web AdminSidebar.tsx, containing strictly the 9 Admin module screens,
/// Log Out Admin button, and Security / V3.2 version footer badge.
class AdminSidebarDrawer extends StatelessWidget {
  const AdminSidebarDrawer({super.key});

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to end your current administrator session and return to role selection?',
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
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // close drawer
              HapticFeedback.lightImpact();
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/auth/role-select');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = (screenWidth * 0.78).clamp(260.0, 320.0);
    final currentPath = GoRouterState.of(context).uri.path;

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: const Color(0xFFEFEBF9),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              // 1. Top Brand Header
              _buildBrandHeader(context),

              const Divider(color: Color(0xFFDDD6FE), height: 1),

              // 2. Navigation Items (Strictly matching website's 9 items 1:1)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  children: [
                    _buildNavItem(
                      context,
                      title: 'Dashboard',
                      icon: LucideIcons.layoutDashboard,
                      route: '/admin/dashboard',
                      isActive: currentPath == '/admin/dashboard',
                    ),
                    _buildNavItem(
                      context,
                      title: 'User Management',
                      icon: LucideIcons.users,
                      route: '/admin/users',
                      isActive: currentPath.startsWith('/admin/user'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Content Hub',
                      icon: LucideIcons.bookOpen,
                      route: '/admin/content',
                      isActive: currentPath.startsWith('/admin/content'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Placement Oversight',
                      icon: LucideIcons.briefcase,
                      route: '/admin/placement-oversight',
                      isActive: currentPath.startsWith('/admin/placement'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Verification Queue',
                      icon: LucideIcons.checkCircle2,
                      route: '/admin/verification-queue',
                      isActive: currentPath.startsWith('/admin/verification'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Broadcast Control',
                      icon: LucideIcons.megaphone,
                      route: '/admin/broadcast-control',
                      isActive: currentPath.startsWith('/admin/broadcast') ||
                          currentPath.startsWith('/admin/comm'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Analytics',
                      icon: LucideIcons.barChart3,
                      route: '/admin/analytics',
                      isActive: currentPath.startsWith('/admin/analytics') ||
                          currentPath.startsWith('/admin/platform-analytics'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Support',
                      icon: LucideIcons.helpCircle,
                      route: '/admin/support',
                      isActive: currentPath.startsWith('/admin/support'),
                    ),
                    _buildNavItem(
                      context,
                      title: 'Settings',
                      icon: LucideIcons.settings,
                      route: '/admin/settings',
                      isActive: currentPath.startsWith('/admin/settings'),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0xFFDDD6FE), height: 1),

              // 3. Footer Section with Log Out Admin and Security / V3.2 badges
              Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 12,
                  bottom: bottomPadding == 0 ? 12 : bottomPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Log Out Admin button
                    Material(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showSignOutDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFECDD3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.logOut,
                                size: 16,
                                color: Color(0xFFE11D48),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Log Out Admin',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE11D48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Security & V3.2 footer info row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.shieldCheck,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Security',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFDDD6FE), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.info,
                                size: 12,
                                color: Color(0xFF7C3AED),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'V3.2',
                                style: GoogleFonts.firaCode(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF6D28D9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildBrandHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6D28D9).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                LucideIcons.building2,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'C2C Admin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ENTERPRISE PORTAL',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: const Color(0xFF6D28D9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isActive ? const Color(0xFF6D28D9) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        elevation: isActive ? 2 : 0,
        shadowColor: const Color(0xFF6D28D9).withValues(alpha: 0.3),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context); // close drawer
            if (isActive) return;
            context.go(route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.white : const Color(0xFF7C3AED),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                      color: isActive ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
