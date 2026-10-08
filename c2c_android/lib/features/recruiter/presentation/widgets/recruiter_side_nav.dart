import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/bloc/auth_bloc.dart';

/// 1:1 parity with `src/components/recruiter/RecruiterSidebar.tsx` navItems.
/// Scalable: add future recruiter screens here — drawer auto-adapts with no layout changes.
class RecruiterNavItem {
  final String label;
  final IconData icon;
  final String route;
  final bool isSoon; // true = not yet built screen -> shows Soon badge + snackbar
  const RecruiterNavItem({required this.label, required this.icon, required this.route, this.isSoon = false});
}

class RecruiterSideNav extends StatelessWidget {
  /// Current active route highlight (optional). If null, auto-detect via GoRouter state.
  final String? highlightRoute;
  const RecruiterSideNav({super.key, this.highlightRoute});

  // Keep as static const for zero-rebuild + future extensibility.
  static const List<RecruiterNavItem> navItems = [
    RecruiterNavItem(label: 'Dashboard', icon: LucideIcons.layoutDashboard, route: '/recruiter/dashboard'),
    RecruiterNavItem(label: 'Post a Job', icon: LucideIcons.filePlus2, route: '/recruiter/post-job'),
    RecruiterNavItem(label: 'My Job Postings', icon: LucideIcons.briefcase, route: '/recruiter/my-postings'),
    RecruiterNavItem(label: 'Applications & Reports', icon: LucideIcons.fileBarChart2, route: '/recruiter/applications', isSoon: false),
    RecruiterNavItem(label: 'Shortlisted Candidates', icon: LucideIcons.userCheck, route: '/recruiter/shortlisted-candidates', isSoon: false),
    RecruiterNavItem(label: 'Messages', icon: LucideIcons.messageSquare, route: '/recruiter/messages', isSoon: false),
    RecruiterNavItem(label: 'Admin Review', icon: LucideIcons.shieldCheck, route: '/recruiter/admin-review', isSoon: false),
    RecruiterNavItem(label: 'Settings', icon: LucideIcons.settings, route: '/recruiter/settings', isSoon: false),
  ];

  bool _isActive(String route, String currentLocation) {
    if (highlightRoute != null) return highlightRoute == route;
    // Exact or prefix match like web isActive()
    return currentLocation == route || currentLocation.startsWith('$route/');
  }

  void _handleTap(BuildContext context, RecruiterNavItem item) {
    HapticFeedback.selectionClick();
    final current = GoRouterState.of(context).uri.toString();
    // Close drawer first
    if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);

    if (item.isSoon) {
      // Show mock-soon feedback instead of hard navigation failure
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(child: AutoSizeText('${item.label} is coming soon to the mobile app!', minFontSize: 11, maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
            duration: const Duration(seconds: 2),
          ),
        );
      });
      // Still attempt navigation if route actually exists (future toggle isSoon false without UI change)
      return;
    }

    // Avoid pushing duplicate
    if (_isActive(item.route, current)) return;

    // Use go for top-level replacement (preserves back-stack hygiene)
    context.go(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = clampDouble(screenWidth * 0.78, 272.0, 304.0);
    final currentLocation = GoRouterState.of(context).uri.toString();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              // Brand Header — tap -> home (mirrors web click on brand -> navigate('/'))
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                  context.go('/');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF5E17EB), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                          Text('C2C', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.3)),
                          Text('Recruiter Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                        ]),
                      ),
                      const Icon(LucideIcons.chevronRight, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),

              // Navigation list — scrollable, lean tree
              Expanded(
                child: RepaintBoundary(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    itemCount: navItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (ctx, i) {
                      final item = navItems[i];
                      final active = _isActive(item.route, currentLocation);
                      return _NavTile(
                        item: item,
                        active: active,
                        onTap: () => _handleTap(context, item),
                      );
                    },
                  ),
                ),
              ),

              // Footer — Help Center (soon) + Logout
              Container(
                padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: bottomInset == 0 ? 12 : bottomInset),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FooterTile(
                      icon: LucideIcons.helpCircle,
                      label: 'Help Center',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(children: [
                              Icon(LucideIcons.sparkles, color: AppColors.primary, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text('Help Center is coming soon to the mobile app!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            ]),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    _FooterTile(
                      icon: LucideIcons.logOut,
                      label: 'Logout',
                      isDestructive: true,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
                        context.read<AuthBloc>().add(LogoutRequested());
                        context.go('/auth/role-select');
                      },
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

class _NavTile extends StatefulWidget {
  final RecruiterNavItem item;
  final bool active;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.active, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.active ? Colors.white.withValues(alpha: 0.11) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: widget.active ? Border.all(color: Colors.white.withValues(alpha: 0.08)) : null,
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 16, color: widget.active ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.active ? Colors.white : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              if (widget.item.isSoon) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '*',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ),
              ] else if (widget.active) ...[
                const SizedBox(width: 6),
                const Icon(LucideIcons.chevronRight, size: 12, color: Color(0xFF93C5FD)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _FooterTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, size: 16, color: isDestructive ? const Color(0xFFF87171) : const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDestructive ? const Color(0xFFFCA5A5) : const Color(0xFF94A3B8))),
        ]),
      ),
    );
  }
}
