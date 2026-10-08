import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

class AdminCommandCenterModal extends StatefulWidget {
  final Function(String routeName, String title) onSelectRoute;

  const AdminCommandCenterModal({
    super.key,
    required this.onSelectRoute,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(String routeName, String title) onSelectRoute,
  }) {
    HapticFeedback.lightImpact();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AdminCommandCenterModal(onSelectRoute: onSelectRoute),
    );
  }

  @override
  State<AdminCommandCenterModal> createState() =>
      _AdminCommandCenterModalState();
}

class _AdminCommandCenterModalState extends State<AdminCommandCenterModal> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _commands = [
    {
      'id': 'overview',
      'label': 'Go to Overview Dashboard',
      'icon': LucideIcons.layoutDashboard,
      'route': '/admin/dashboard',
      'title': 'Overview & Analytics',
    },
    {
      'id': 'users',
      'label': 'Manage Students & Users Directory',
      'icon': LucideIcons.users,
      'route': '/admin/students',
      'title': 'User Management',
    },
    {
      'id': 'colleges',
      'label': 'Manage Colleges & Institutional Partners',
      'icon': LucideIcons.building2,
      'route': '/admin/colleges',
      'title': 'College Directory',
    },
    {
      'id': 'recruiters',
      'label': 'Manage Recruiters & Companies',
      'icon': LucideIcons.briefcase,
      'route': '/admin/recruiters',
      'title': 'Recruiter Directory',
    },
    {
      'id': 'projects',
      'label': 'Projects & Placement Pipeline',
      'icon': LucideIcons.clipboardList,
      'route': '/admin/projects',
      'title': 'Projects Hub',
    },
    {
      'id': 'broadcast',
      'label': 'Compose Platform Broadcast',
      'icon': LucideIcons.megaphone,
      'route': '/admin/broadcast',
      'title': 'Broadcast Control',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final itemTitleSize = clampDouble(screenWidth * 0.035, 12.5, 14.0);
    final inputFontSize = clampDouble(screenWidth * 0.035, 13.0, 14.5);

    final filtered = _commands
        .where((cmd) =>
            cmd['label'].toString().toLowerCase().contains(_query.toLowerCase()) ||
            cmd['title'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Center(
        child: Container(
          width: clampDouble(screenWidth * 0.90, 320, 500),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryLight, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Input Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.search,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: inputFontSize,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (val) => setState(() => _query = val),
                          decoration: InputDecoration(
                            hintText:
                                'Search students, colleges, or recruiters...',
                            hintStyle: TextStyle(
                              fontSize: inputFontSize,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          LucideIcons.x,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.border, height: 1),

                // Commands List
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No matching commands found',
                              style: TextStyle(
                                fontSize: itemTitleSize,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length,
                          separatorBuilder: (_, index) =>
                              const Divider(color: AppColors.border, height: 1),
                          itemBuilder: (context, idx) {
                            final item = filtered[idx];
                            return ListTile(
                              leading: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                              ),
                              title: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: itemTitleSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: const Icon(
                                LucideIcons.chevronRight,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                                widget.onSelectRoute(
                                  item['route'] as String,
                                  item['title'] as String,
                                );
                              },
                            );
                          },
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
