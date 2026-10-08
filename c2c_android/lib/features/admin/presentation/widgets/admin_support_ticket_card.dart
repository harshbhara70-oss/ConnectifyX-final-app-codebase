import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_support_models.dart';

/// Single Ticket Feed Card matching web SupportCenter.tsx left feed
/// Features zero-overflow constraints, priority color tokens, SLA counters, and full-card InkWell ripple.
class AdminSupportTicketCard extends StatelessWidget {
  final AdminSupportTicketModel ticket;
  final bool isSelected;
  final VoidCallback onTap;

  const AdminSupportTicketCard({
    super.key,
    required this.ticket,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final titleSize = (screenWidth * 0.038).clamp(13.5, 15.0);
    final subtitleSize = (screenWidth * 0.030).clamp(11.0, 12.5);
    final badgeSize = (screenWidth * 0.026).clamp(10.0, 11.0);

    // Priority Tokens
    Color priorityBg;
    Color priorityText;
    Color priorityBorder;
    if (ticket.priority.contains('Critical')) {
      priorityBg = const Color(0xFFFEF2F2);
      priorityText = const Color(0xFFEF4444);
      priorityBorder = const Color(0xFFFECACA);
    } else if (ticket.priority.contains('Escalated')) {
      priorityBg = const Color(0xFFFFFBEB);
      priorityText = const Color(0xFFD97706);
      priorityBorder = const Color(0xFFFDE68A);
    } else {
      priorityBg = const Color(0xFFF1F5F9);
      priorityText = AppColors.textSecondary;
      priorityBorder = const Color(0xFFE2E8F0);
    }

    return RepaintBoundary(
      child: Material(
        color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF8B5CF6) : AppColors.border,
                width: isSelected ? 1.2 : 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x106D28D9) : const Color(0x04000000),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ticket ID + Unread Dot + Priority & Type Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (ticket.unread) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6D28D9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          '#${ticket.id}',
                          style: GoogleFonts.firaCode(
                            fontSize: badgeSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFDDD6FE), width: 0.6),
                          ),
                          child: Text(
                            ticket.type.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: badgeSize,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6D28D9),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: priorityBorder, width: 0.6),
                          ),
                          child: Text(
                            ticket.priority.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: badgeSize,
                              fontWeight: FontWeight.w800,
                              color: priorityText,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Title
                Text(
                  ticket.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 10),

                // Bottom Subtitle Row: Requester & SLA Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(LucideIcons.user, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${ticket.requester} • ${ticket.organization}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 11,
                          color: ticket.sla.contains('remaining') ? const Color(0xFFEF4444) : const Color(0xFF6D28D9),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          ticket.sla,
                          style: GoogleFonts.firaCode(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w700,
                            color: ticket.sla.contains('remaining') ? const Color(0xFFEF4444) : const Color(0xFF6D28D9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
