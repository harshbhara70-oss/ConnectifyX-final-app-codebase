import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Horizontal Sub-Category Tabs for Admin Settings matching web SettingsView.tsx categories
class AdminSettingsCategoryTabs extends StatelessWidget {
  final String activeCategory;
  final Function(String categoryId) onSelectCategory;

  const AdminSettingsCategoryTabs({
    super.key,
    required this.activeCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'id': 'ai', 'label': 'AI Config', 'icon': LucideIcons.brain, 'alert': false},
      {'id': 'integrations', 'label': 'Integrations', 'icon': LucideIcons.plug, 'alert': false},
      {'id': 'security', 'label': 'Security Audit', 'icon': LucideIcons.lock, 'alert': false},
      {'id': 'maintenance', 'label': 'Maintenance', 'icon': LucideIcons.alertOctagon, 'alert': true},
      {'id': 'policies', 'label': 'Policies', 'icon': LucideIcons.shield, 'alert': false},
      {'id': 'general', 'label': 'General', 'icon': LucideIcons.settings, 'alert': false},
      {'id': 'notifications', 'label': 'Notifications', 'icon': LucideIcons.bell, 'alert': false},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final id = cat['id'] as String;
          final label = cat['label'] as String;
          final icon = cat['icon'] as IconData;
          final alert = cat['alert'] as bool;
          final isSelected = activeCategory == id;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: isSelected ? const Color(0xFF6D28D9) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelectCategory(id);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6D28D9) : AppColors.border,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? const Color(0x186D28D9) : const Color(0x03000000),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : const Color(0xFF6D28D9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                      if (alert) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFECACA) : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
